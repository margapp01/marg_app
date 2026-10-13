import 'package:flutter/material.dart';

/// A centred circular spinner with an optional [size] and [color].
class CircularLoader extends StatelessWidget {
  const CircularLoader({
    this.size = 28,
    this.color,
    this.strokeWidth = 3,
    super.key,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(strokeWidth: strokeWidth, color: color),
    ),
  );
}

/// A slim indeterminate progress bar (top-of-content loading).
class LinearLoader extends StatelessWidget {
  const LinearLoader({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) =>
      LinearProgressIndicator(minHeight: 3, color: color);
}
