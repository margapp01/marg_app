import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../images/placeholder_image.dart';

/// Cached remote image with uniform loading/error states (via
/// [PlaceholderImage]). The base image primitive — avatars, banners, temple
/// imagery build on this.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon,
    this.fallback,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData? placeholderIcon;

  /// Branded surface shown while loading and when the image can't be loaded
  /// (e.g. a gradient behind a banner) instead of the neutral placeholder.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) =>
          fallback ?? PlaceholderImage(width: width, height: height, icon: placeholderIcon),
      errorWidget: (_, _, _) =>
          fallback ?? PlaceholderImage(width: width, height: height, isError: true),
    );
    return borderRadius == null
        ? image
        : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
