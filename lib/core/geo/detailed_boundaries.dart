import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../network/dio_client.dart';
import 'bharat_boundaries.dart';

/// The two optional map outline downloads, sharper than the bundled copy.
enum MapDetail {
  /// Simplified at ~30 m: crisp at every zoom, light to draw (~3 MB).
  detailed('detailed', 'bharat_boundaries_detailed.geojson'),

  /// Every surveyed point (~14 MB on the device, ~3 MB to download).
  full('full', 'bharat_boundaries_full.geojson');

  const MapDetail(this.query, this.fileName);

  /// The `detail` query value for `GET /geo/bharat-boundaries`.
  final String query;
  final String fileName;
}

/// The optional detailed map outline (`GET /geo/bharat-boundaries`), kept in
/// app storage — at most one [MapDetail] at a time. Maps use it in place of
/// the bundled, simplified outline once downloaded.
class DetailedBoundariesStore {
  DetailedBoundariesStore(this._dio);

  final Dio _dio;

  static const String _path = '/geo/bharat-boundaries';

  Future<File> _file(MapDetail detail) async =>
      File('${(await getApplicationSupportDirectory()).path}/geo/${detail.fileName}');

  /// Which outline is on the device, finest first; null when none (or
  /// storage is unavailable).
  Future<MapDetail?> current() async {
    try {
      for (final detail in MapDetail.values.reversed) {
        if ((await _file(detail)).existsSync()) return detail;
      }
    } catch (_) {/* treat unreadable storage as no download */}
    return null;
  }

  /// The downloaded GeoJSON, or null when there is none.
  Future<String?> readOrNull() async {
    final detail = await current();
    if (detail == null) return null;
    try {
      return await (await _file(detail)).readAsString();
    } catch (_) {
      return null;
    }
  }

  /// Streams [detail] to storage, reporting 0–1 progress; validates it parses
  /// before replacing anything, so a broken download never breaks the map.
  /// The other tier is removed once the new one is in place.
  Future<void> download(MapDetail detail, {void Function(double progress)? onProgress, CancelToken? cancelToken}) async {
    final file = await _file(detail);
    await file.parent.create(recursive: true);
    final partial = File('${file.path}.part');
    final res = await _dio.get<ResponseBody>(
      _path,
      queryParameters: {'detail': detail.query},
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
    for (final other in MapDetail.values.where((d) => d != detail)) {
      final stale = await _file(other);
      if (stale.existsSync()) await stale.delete();
    }
  }

  Future<void> remove() async {
    for (final detail in MapDetail.values) {
      final file = await _file(detail);
      if (file.existsSync()) await file.delete();
    }
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
  const DetailedMapDownloading(this.detail, this.progress);
  final MapDetail detail;
  final double progress;
}

class DetailedMapReady extends DetailedMapStatus {
  const DetailedMapReady(this.detail);
  final MapDetail detail;
}

class DetailedMapController extends AsyncNotifier<DetailedMapStatus> {
  @override
  Future<DetailedMapStatus> build() async {
    final detail = await ref.read(detailedBoundariesStoreProvider).current();
    return detail == null ? const DetailedMapAbsent() : DetailedMapReady(detail);
  }

  /// Downloads [detail] and switches every map to it. False on failure, which
  /// keeps whatever outline was there before.
  Future<bool> download(MapDetail detail) async {
    final before = state.valueOrNull ?? const DetailedMapAbsent();
    if (before is DetailedMapDownloading) return false;
    state = AsyncData(DetailedMapDownloading(detail, 0));
    try {
      await ref.read(detailedBoundariesStoreProvider).download(
            detail,
            onProgress: (p) => state = AsyncData(DetailedMapDownloading(detail, p)),
          );
      state = AsyncData(DetailedMapReady(detail));
      ref.invalidate(bharatBoundariesProvider);
      return true;
    } catch (_) {
      state = AsyncData(before);
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
