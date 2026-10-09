import 'package:flutter/widgets.dart';

import '../../app/constants/brand_assets.dart';

/// The official MARG logo ([BrandAssets.logo]). The asset is a full-bleed
/// square, so it is shown with app-icon corner rounding that scales with
/// [size]. Renders nothing if the asset can't be decoded.
class BrandLogo extends StatelessWidget {
  const BrandLogo({required this.size, this.semanticLabel = 'MARG', super.key});

  final double size;
  final String semanticLabel;

  /// Corner radius as a fraction of the side — the app-icon ratio.
  static const double _cornerRatio = 0.2237;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * _cornerRatio),
      child: Image.asset(
        BrandAssets.logo,
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
