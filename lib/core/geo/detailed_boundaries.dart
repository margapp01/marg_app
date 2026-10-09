import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../network/dio_client.dart';
import 'bharat_boundaries.dart';

/// The optional detailed map outline (`GET /geo/bharat-boundaries`, ~3 MB),
/// kept in app storage. Maps use it in place of the bundled, simplified
/// outline once downloaded.
class DetailedBoundariesStore {
  DetailedBoundariesStore(this._dio);

  final Dio _dio;

  static const String _path = '/geo/bharat-boundaries';
  static const String _fileName = 'bharat_boundaries_detailed.geojson';

  Future<File> _file() async => File('${(await getApplicationSupportDirectory()).path}/geo/$_fileName');

  /// The downloaded GeoJSON, or null when there is none (or storage is
  /// unavailable).
  Future<String?> readOrNull() async {
    try {
      final file = await _file();
      return file.existsSync() ? await file.readAsString() : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> exists() async {
    try {
      return (await _file()).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Streams the file to storage, reporting 0–1 progress; validates it parses
  /// before replacing anything, so a broken download never breaks the map.
  Future<void> download({void Function(double progress)? onProgress, CancelToken? cancelToken}) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final partial = File('${file.path}.part');
    final res = await _dio.get<ResponseBody>(
      _path,
      cancelToken: cancelToken,
      options: Options(responseType: ResponseType.stream),
    );
    final total = int.tryParse(res.headers.value('x-raw-size') ?? '') ?? 0;
    final sink = partial.openWrite();
    var received = 0;
    try {
      await for (final chunk in res.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call((received / total).clamp(0, 1));
      }
    } finally {
      await sink.close();
    }
    await compute(BharatBoundaries.parse, await partial.readAsString());
    await partial.rename(file.path);
  }

  Future<void> remove() async {
    final file = await _file();
    if (file.existsSync()) await file.delete();
  }
}

final detailedBoundariesStoreProvider = Provider<DetailedBoundariesStore>(
  (ref) => DetailedBoundariesStore(ref.watch(dioProvider)),
);

/// Whether the detailed outline is on the device, and download progress.
sealed class DetailedMapStatus {
  const DetailedMapStatus();
}

class DetailedMapAbsent extends DetailedMapStatus {
  const DetailedMapAbsent();
}

class DetailedMapDownloading extends DetailedMapStatus {
  const DetailedMapDownloading(this.progress);
  final double progress;
}

class DetailedMapReady extends DetailedMapStatus {
  const DetailedMapReady();
}

class DetailedMapController extends AsyncNotifier<DetailedMapStatus> {
  @override
  Future<DetailedMapStatus> build() async =>
      await ref.read(detailedBoundariesStoreProvider).exists() ? const DetailedMapReady() : const DetailedMapAbsent();

  /// Downloads the outline and switches every map to it. False on failure.
  Future<bool> download() async {
    if (state.valueOrNull is DetailedMapDownloading) return false;
    state = const AsyncData(DetailedMapDownloading(0));
    try {
      await ref.read(detailedBoundariesStoreProvider).download(
            onProgress: (p) => state = AsyncData(DetailedMapDownloading(p)),
          );
      state = const AsyncData(DetailedMapReady());
      ref.invalidate(bharatBoundariesProvider);
      return true;
    } catch (_) {
      state = const AsyncData(DetailedMapAbsent());
      return false;
    }
  }

  /// Back to the bundled outline.
  Future<void> remove() async {
    await ref.read(detailedBoundariesStoreProvider).remove();
    state = const AsyncData(DetailedMapAbsent());
    ref.invalidate(bharatBoundariesProvider);
  }
}

final detailedMapProvider = AsyncNotifierProvider<DetailedMapController, DetailedMapStatus>(DetailedMapController.new);
