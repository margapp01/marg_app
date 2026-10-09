import 'package:flutter/widgets.dart';

import '../../app/constants/brand_assets.dart';
import '../../core/extensions/context_extensions.dart';

/// A stable accent colour per backend `DeityType`, drawn from the palette —
/// shared so a deity looks the same in Explore, onboarding and profile.
Color deityColor(BuildContext context, String? wire) {
  switch (wire?.toUpperCase()) {
    case 'SHIVA':
      return context.scheme.primary;
    case 'VISHNU':
      return context.colors.info;
    case 'DEVI':
      return context.colors.gold;
    case 'HANUMAN':
      return context.colors.warning;
    case 'GANESHA':
      return context.colors.success;
    case 'SURYA':
      return context.palette.accentAmber;
    default:
      return context.colors.textSecondary;
  }
}

/// Illustrated art per backend `DeityType` (null → callers show a tinted icon).
String? deityAsset(String? wire) => switch (wire?.toUpperCase()) {
      'SHIVA' => BrandAssets.deityShiva,
      'VISHNU' => BrandAssets.deityVishnu,
      'DEVI' => BrandAssets.deityDevi,
      'HANUMAN' => BrandAssets.deityHanuman,
      'GANESHA' => BrandAssets.deityGanesha,
      'SURYA' => BrandAssets.deitySurya,
      _ => null,
    };
