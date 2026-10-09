import 'package:flutter/widgets.dart';

import '../../app/constants/brand_assets.dart';

/// The official MARG wordmark ([BrandAssets.wordmark]). The asset is an opaque
/// image on a white field; here the white is keyed out to transparency at
/// render time, so the unmodified brand mark sits cleanly on any background
/// (illustrations, gradients) without a visible box.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({this.width, this.semanticLabel = 'MARG', super.key});

  final double? width;
  final String semanticLabel;

  /// alpha = 3·A − (R + G + B): opaque white → transparent, brand navy and
  /// saffron → fully opaque, already-transparent pixels stay transparent;
  /// colours are left untouched. No translation term, so it behaves the same
  /// on Skia and Impeller (which differ on the offset column's range).
  static const ColorFilter _whiteToAlpha = ColorFilter.matrix(<double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    -1,
    -1,
    -1,
    3,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: _whiteToAlpha,
      child: Image.asset(BrandAssets.wordmark, width: width, semanticLabel: semanticLabel),
    );
  }
}
