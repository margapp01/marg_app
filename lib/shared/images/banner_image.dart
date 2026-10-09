import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../components/app_network_image.dart';

/// A wide banner image with a fixed [aspectRatio], rounded corners, an optional
/// darkening gradient, and an optional [overlay] (title, badge). Renders a
/// network [url] or a bundled [assetPath] (e.g. the MARG featured banner).
class BannerImage extends StatelessWidget {
  const BannerImage({
    this.url,
    this.assetPath,
    this.aspectRatio = 16 / 9,
    this.borderRadius = AppRadius.lgAll,
    this.overlay,
    this.gradient = false,
    super.key,
  }) : assert(url != null || assetPath != null, 'Provide url or assetPath');

  final String? url;
  final String? assetPath;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final Widget? overlay;

  /// Draws a bottom-up dark gradient so overlaid text stays legible.
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final image = assetPath != null
        ? Image.asset(assetPath!, fit: BoxFit.cover)
        : AppNetworkImage(url: url!, fit: BoxFit.cover);
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            if (gradient)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x99000000)],
                    stops: [0.5, 1],
                  ),
                ),
              ),
            if (overlay != null)
              Positioned.fill(
                child: Padding(padding: AppSpacing.allLg, child: overlay!),
              ),
          ],
        ),
      ),
    );
  }
}
