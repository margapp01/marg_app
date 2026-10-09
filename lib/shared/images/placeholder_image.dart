import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../core/extensions/context_extensions.dart';

/// A neutral placeholder surface shown while an image loads or when none is
/// set. Also the error fallback ([isError] swaps the glyph). Shared by
/// [AppNetworkImage] and any local image slot so empty imagery is consistent.
class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({this.width, this.height, this.icon, this.isError = false, super.key});

  final double? width;
  final double? height;
  final IconData? icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: context.scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(icon ?? (isError ? AppIcons.brokenImage : AppIcons.temple), color: context.colors.textDisabled),
    );
  }
}
