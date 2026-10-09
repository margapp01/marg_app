/// Device-local app preferences (not backend-persisted). Stored via the
/// KeyValueStore. Theme is intentionally omitted — the app is Light-only for
/// this release (the architecture stays ready for a future dark mode).
enum DistanceUnit { kilometers, miles }

class AppPreferences {
  const AppPreferences({
    this.units = DistanceUnit.kilometers,
    this.reduceAnimations = false,
    this.dataSaver = false,
    this.highQualityImages = true,
  });

  final DistanceUnit units;
  final bool reduceAnimations;
  final bool dataSaver;
  final bool highQualityImages;

  AppPreferences copyWith({
    DistanceUnit? units,
    bool? reduceAnimations,
    bool? dataSaver,
    bool? highQualityImages,
  }) =>
      AppPreferences(
        units: units ?? this.units,
        reduceAnimations: reduceAnimations ?? this.reduceAnimations,
        dataSaver: dataSaver ?? this.dataSaver,
        highQualityImages: highQualityImages ?? this.highQualityImages,
      );

  static const defaults = AppPreferences();
}
