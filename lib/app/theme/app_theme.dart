import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Brand colours that Material's [ColorScheme] does not model. Widgets read
/// them via `Theme.of(context).extension<AppSemanticColors>()` (or the
/// `context.colors` shortcut), so a dark theme only needs to register a dark
/// instance here — feature code never touches raw [AppColors].
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.gold,
    required this.silver,
    required this.bronze,
    required this.templeSand,
    required this.templeStone,
    required this.sky,
    required this.mapGreen,
    required this.border,
    required this.divider,
    required this.card,
    required this.textSecondary,
    required this.textDisabled,
    required this.splashCanvas,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color gold;
  final Color silver;
  final Color bronze;
  final Color templeSand;
  final Color templeStone;
  final Color sky;
  final Color mapGreen;
  final Color border;
  final Color divider;
  final Color card;
  final Color textSecondary;
  final Color textDisabled;
  final Color splashCanvas;

  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    gold: AppColors.gold,
    silver: AppColors.silver,
    bronze: AppColors.bronze,
    templeSand: AppColors.templeSand,
    templeStone: AppColors.templeStone,
    sky: AppColors.sky,
    mapGreen: AppColors.mapGreen,
    border: AppColors.border,
    divider: AppColors.divider,
    card: AppColors.card,
    textSecondary: AppColors.textSecondary,
    textDisabled: AppColors.textDisabled,
    splashCanvas: AppColors.splashCanvas,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? gold,
    Color? silver,
    Color? bronze,
    Color? templeSand,
    Color? templeStone,
    Color? sky,
    Color? mapGreen,
    Color? border,
    Color? divider,
    Color? card,
    Color? textSecondary,
    Color? textDisabled,
    Color? splashCanvas,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      bronze: bronze ?? this.bronze,
      templeSand: templeSand ?? this.templeSand,
      templeStone: templeStone ?? this.templeStone,
      sky: sky ?? this.sky,
      mapGreen: mapGreen ?? this.mapGreen,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      card: card ?? this.card,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      splashCanvas: splashCanvas ?? this.splashCanvas,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      gold: Color.lerp(gold, other.gold, t) ?? gold,
      silver: Color.lerp(silver, other.silver, t) ?? silver,
      bronze: Color.lerp(bronze, other.bronze, t) ?? bronze,
      templeSand: Color.lerp(templeSand, other.templeSand, t) ?? templeSand,
      templeStone: Color.lerp(templeStone, other.templeStone, t) ?? templeStone,
      sky: Color.lerp(sky, other.sky, t) ?? sky,
      mapGreen: Color.lerp(mapGreen, other.mapGreen, t) ?? mapGreen,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      card: Color.lerp(card, other.card, t) ?? card,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      splashCanvas: Color.lerp(splashCanvas, other.splashCanvas, t) ?? splashCanvas,
    );
  }
}

/// App-wide [ThemeData]. Version 1 ships light only; `dark` is added here
/// (dark [ColorScheme] + dark [AppSemanticColors]) without touching features.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.lightColorScheme);

  static ThemeData _build(ColorScheme scheme) {
    final textTheme = AppTypography.textTheme(scheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      extensions: <ThemeExtension<dynamic>>[
        AppSemanticColors.light,
        AppTypography.brandText(scheme),
        AppTypography.displayText(scheme),
        AppPalette.light,
      ],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: AppColors.card,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          minimumSize: const Size.fromHeight(48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.border),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
        // Selected chips use the saffron selection language (wash + border +
        // check) shared with the onboarding tiles, not Material's blue-grey.
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.border,
          ),
        ),
        selectedColor: AppColors.primaryContainer,
        checkmarkColor: AppColors.primary,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: AppTypography.semiBold,
        ),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      // Board toggles: a white thumb on the logo's navy (on) or warm-stone
      // (off) track with no outline — not Material's dark-thumb outlined off
      // state, and calmer than saffron beside the saffron icon chips.
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.card),
        // A blank thumb icon keeps the off thumb full-size, like the on one.
        thumbIcon: const WidgetStatePropertyAll(Icon(null)),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.secondary : AppColors.border,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      // Sliders match the toggles: navy fill and thumb on a warm-stone track.
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.secondary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.secondary,
        overlayColor: AppColors.secondary.withValues(alpha: 0.12),
        valueIndicatorColor: AppColors.secondary,
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      // Inputs share the search pill's family: white surface, hairline border,
      // card rounding, saffron focus ring.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.topXl),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
      ),
    );
  }
}
