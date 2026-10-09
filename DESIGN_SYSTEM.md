# MARG Design System

The reusable UI foundation for `marg_app`. Every feature composes these widgets and tokens — it never re-implements them, hardcodes a colour/size, or forks a shared widget. One import gives you everything:

```dart
import 'package:marg_app/shared/design_system.dart';
```

Built on: `google_fonts` (**Noto Sans** UI + **Cinzel** brand + **Noto Sans Devanagari** fallback), `material_symbols_icons` (Rounded), `shimmer`, `pinput`, `cached_network_image`. Light theme ships now; the architecture (raw palette → `ColorScheme` + `AppSemanticColors` extension, brand type → `AppBrandText` extension) makes a dark theme a one-file addition.

## Folder structure

```
lib/app/
  constants/
    app_constants.dart        AppConstants (non-visual)
    brand_assets.dart         BrandAssets — official logo / app icon / featured banner paths
  theme/
    theme.dart                barrel for all tokens
    app_colors.dart           AppColors — raw palette (theme-only)
    app_typography.dart       AppTypography (Noto Sans + Devanagari, full scale) + AppBrandText (Cinzel, branding-only)
    app_spacing.dart          AppSpacing (2→96) + Gap
    app_radius.dart           AppRadius (xs→full) + BorderRadius consts
    app_shadows.dart          AppShadows (xs→xl)
    app_icons.dart            AppIcons — semantic Material Symbols Rounded
    app_durations.dart        AppDurations
    app_curves.dart           AppCurves
    app_breakpoints.dart      AppBreakpoints + ScreenSize
    app_theme.dart            AppTheme.light + AppSemanticColors (ThemeExtension)

lib/core/extensions/
    context_extensions.dart   context.colors / scheme / textTheme / responsive() / sizeClass

lib/shared/
  design_system.dart          ⭐ single barrel — import this
  animations/                 AppEntrance, FadeIn/ScaleIn/SlideIn, .fadeIn()/.scaleIn()/.slideIn(),
                              AnimatedCount/AnimatedNumber, AppLinearProgress/AppCircularProgress,
                              StaggeredList, ExpandableSection, AppPageTransitions
  buttons/                    AppButton (+.primary/.secondary/.outlined/.ghost/.danger), AppIconButton, AppFab
  inputs/                     PasswordField, OtpField, AppDropdown, DateField, PhoneField, MultilineField
  cards/                      InfoCard, StatCard, SelectableCard, AnimatedCard, ProfileCard,
                              TempleCardBase, EmptyCard
  badges/                     AppBadge (+ tones), StatusBadge, VerificationBadge, TrustBadge,
                              PointsBadge, AchievementBadge, AnimatedBadge
  chips/                      AppFilterChip, AppChoiceChip, AnimatedChip
  tiles/                      AppListTile, SettingsTile, ProfileTile, InfoTile, ActionTile, NavigationTile
  dividers/                   AppDivider, AppVerticalDivider, SectionDivider, LabelDivider
  dialogs/                    AppDialog, AppDialogs.confirm/delete/success/failure/info/loading
  sheets/                     AppSheets.actions/select/confirm (+ SheetAction/SheetOption)
  feedback/                   AppSnackbar (success/error/warning/info), AppToast, FeedbackType
  loaders/                    AppShimmer, SkeletonBox/Line/Circle, SkeletonCard/List/Avatar/Banner,
                              CircularLoader, LinearLoader, AnimatedLoader, LoadingView
  empty/                      EmptyView + SearchEmpty/NotificationsEmpty/PassportEmpty/VisitsEmpty/
                              RoutesEmpty/CardsEmpty/LeaderboardEmpty/ReferralsEmpty
  error/                      ErrorView + OfflineError/TimeoutError/ServerError/UnknownError/
                              PermissionDeniedError
  app_bar/                    AppAppBar, AppSliverAppBar, SearchAppBar
  navigation/                 AppBottomNav (+ AppNavItem)
  images/                     AppNetworkImage, AppAvatar, AppHeroImage, BannerImage, PlaceholderImage
  components/                 base widgets shared subfolders build on: AppCard, AppTextField,
                              AppSearchBar, AppNetworkImage, AppScaffold (+ legacy PrimaryButton/
                              SecondaryButton delegating to AppButton, placeholder_scaffold)
```

Each subfolder has a barrel (`buttons/buttons.dart`, etc.); `design_system.dart` re-exports them all.

## Conventions

- **Colours** — `context.scheme.*` for Material roles; `context.colors.*` for brand roles (`gold`, `silver`, `bronze`, `templeSand`, `templeStone`, `sky`, `mapGreen`, `border`, `divider`, `textSecondary`, …). Never reference `AppColors` outside `app/theme/`.
- **Spacing** — `AppSpacing.*` or `Gap(AppSpacing.lg)`; screen gutters via `AppSpacing.screenAll`. No literal `EdgeInsets` numbers.
- **Icons** — `AppIcons.*` only. Add a semantic name there rather than referencing `Symbols.*` at call sites.
- **Type** — two families only. **Noto Sans** for all UI via `context.textTheme.*` (+ `context.caption/button/overline`); Hindi renders via the Devanagari fallback automatically. **Cinzel** for branding **only** via `context.brandText.*` (splash/logo/marketing/About/festival/promo) — never in forms, cards, buttons, lists, or paragraphs. Weights limited to Regular/Medium/SemiBold/Bold (`style.regular/.medium/.semiBold/.bold`). Sizes scale responsively (device size × OS text-scale, clamped) — applied once at the app root; never set `fontSize`/`fontWeight`/`fontFamily` in a widget.
- **Motion** — durations from `AppDurations`, easing from `AppCurves`. Prefer the entrance widgets / `.fadeIn()` extension over ad-hoc `AnimationController`s. Purposeful, not decorative.
- **Responsive** — `context.responsive(compact:…, expanded:…)` / `context.isTablet`; cap reading width with `AppBreakpoints.maxContentWidth`. No fixed pixel widths.
- **Accessibility** — icon-only buttons require a `tooltip` (doubles as the semantic label); tap targets ≥48dp; progress widgets expose semantic values.

## Async / state pattern

Every API-backed view should cover: **loading** (`SkeletonList` / `LoadingView`), **empty** (a per-feature preset), **error** (a typed preset), **success**, **refreshing** (`AppScaffold(onRefresh:)`), **offline** (`OfflineError`).

## Verified

`flutter analyze lib` → clean. `test/design_system_smoke_test.dart` renders a representative slice under `AppTheme.light` and passes with no widget exceptions.
