import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';

/// Night-navy surface with a faint golden temple watermark — stands in for a
/// hero/banner/route image that is missing or fails to load, so immersive
/// cards stay on-brand instead of showing a grey placeholder.
///
/// Short cards that overlay text and actions on it should pass a smaller,
/// fainter watermark ([iconSize], [opacity]) placed clear of their controls
/// ([alignment]).
class BrandedImageFallback extends StatelessWidget {
  const BrandedImageFallback({
    this.iconSize = 96,
    this.alignment = const Alignment(0.85, -0.2),
    this.opacity = 0.35,
    super.key,
  });

  final double iconSize;
  final AlignmentGeometry alignment;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.navy),
      child: Align(
        alignment: alignment,
        child: Icon(
          AppIcons.temple,
          size: iconSize,
          color: context.colors.gold.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
