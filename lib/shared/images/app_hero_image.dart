import 'package:flutter/material.dart';

import '../components/app_network_image.dart';

/// A network image wrapped in a [Hero], for smooth shared-element transitions
/// (list thumbnail → detail header). The [tag] must match on both screens.
class AppHeroImage extends StatelessWidget {
  const AppHeroImage({
    required this.tag,
    required this.url,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    super.key,
  });

  final Object tag;
  final String url;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: AppNetworkImage(url: url, width: width, height: height, fit: fit, borderRadius: borderRadius),
    );
  }
}
