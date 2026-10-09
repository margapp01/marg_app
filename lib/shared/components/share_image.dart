import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Renders the [RepaintBoundary] behind [boundaryKey] to a PNG and opens the
/// system share sheet with it (plus [text]). Throws if nothing could be
/// captured, so callers can show their own error.
Future<void> shareBoundaryImage(
  GlobalKey boundaryKey, {
  required String text,
  required String fileName,
  double pixelRatio = 3,
}) async {
  final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) throw StateError('Nothing to capture');
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) throw StateError('Capture failed');
  final file = XFile.fromData(bytes.buffer.asUint8List(), name: fileName, mimeType: 'image/png');
  await SharePlus.instance.share(ShareParams(files: [file], text: text));
}
