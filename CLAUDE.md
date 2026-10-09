# marg_app — Engineering Rules

Permanent rules for **every** implementation in this Flutter app. These are non-negotiable. Before any phase is "done", the checklist at the bottom must pass.

## Audience & feel
For devotees of all ages. Calm, premium, trustworthy. Clarity over visual complexity. Obvious interactions, intuitive navigation, visually prominent primary actions. Animations guide — they never decorate.

## 1. Shared-first — check before you create
Before creating **any** widget, dialog, sheet, card, list item, button, badge, chip, loader, empty/error state, extension, service, or util: **search for an existing one first.** Reuse it. If it needs to differ, make it configurable — do **not** fork it.

Never create per-feature duplicates (no `TempleCard`/`RouteCard`/`AchievementCard`). One configurable widget, specialized by parameters.

If something could serve another feature, it lives in `shared/` or `core/` — not inside a feature.

### The design system — import one barrel, reuse everything
**`import 'package:marg_app/shared/design_system.dart';`** exposes all tokens + widgets below. Feature code builds screens by composing these; it never re-implements them. Full map in [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

- **Tokens** `lib/app/theme/` → `AppColors` (raw) · `AppSpacing` (+`Gap`) · `AppRadius` · `AppShadows` · `AppTypography` (**Noto Sans** UI + **Cinzel** brand + Noto Devanagari fallback; full M3 scale, weights Regular/Medium/SemiBold/Bold; responsive scaler wired at app root) · `AppIcons` (Material Symbols Rounded) · `AppDurations` · `AppCurves` · `AppBreakpoints` · `AppTheme` + `AppSemanticColors`. Access via `context.colors/scheme/textTheme/caption/button/overline/brandText/responsive()` (`core/extensions/context_extensions.dart`).
- **Buttons** `shared/buttons/` → `AppButton` (`.primary/.secondary/.outlined/.ghost/.danger`, sizes, busy/success), `AppIconButton`, `AppFab`.
- **Inputs** `shared/inputs/` + `components/` → `AppTextField`, `AppSearchBar`, `PasswordField`, `OtpField`, `AppDropdown`, `DateField`, `PhoneField`, `MultilineField`.
- **Cards** `shared/cards/` → `AppCard` (base), `InfoCard`, `StatCard`, `SelectableCard`, `AnimatedCard`, `ProfileCard`, `TempleCardBase`, `EmptyCard`.
- **Badges/Chips** `shared/badges/`, `shared/chips/` → `AppBadge`, `StatusBadge`, `VerificationBadge`, `TrustBadge`, `PointsBadge`, `AchievementBadge`, `AppFilterChip`, `AppChoiceChip`, `AnimatedChip`.
- **Tiles/Dividers** `shared/tiles/`, `shared/dividers/` → `AppListTile`, `SettingsTile`, `ProfileTile`, `InfoTile`, `ActionTile`, `NavigationTile`, `AppDivider`, `LabelDivider`.
- **Overlays** `shared/dialogs/`, `shared/sheets/`, `shared/feedback/` → `AppDialogs.confirm/delete/success/failure/info/loading`, `AppSheets.actions/select/confirm`, `AppSnackbar`, `AppToast`.
- **States** `shared/loaders/`, `shared/empty/`, `shared/error/` → `AppShimmer` + `Skeleton*`, `AnimatedLoader`, `LoadingView`, `EmptyView` (+ per-feature presets), `ErrorView` (+ `OfflineError`/`TimeoutError`/`ServerError`/`UnknownError`/`PermissionDeniedError`).
- **Chrome/Images** `shared/app_bar/`, `shared/navigation/`, `shared/images/`, `components/app_scaffold.dart` → `AppAppBar`/`AppSliverAppBar`/`SearchAppBar`, `AppBottomNav`, `AppScaffold` (refresh + loading overlay), `AppNetworkImage`, `AppAvatar`, `AppHeroImage`, `BannerImage`.
- **Animations** `shared/animations/` → `FadeIn`/`ScaleIn`/`SlideIn` + `.fadeIn()/.scaleIn()/.slideIn()`, `AnimatedCount`, `AppLinearProgress`/`AppCircularProgress`, `StaggeredList`, `ExpandableSection`, `AppPageTransitions`.

Not sure if something exists? Check [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) or grep `lib/shared/`. Never fork a shared widget — extend it.

## 2. Design system — never hardcode
Colors, spacing, radius, shadow, typography, icons, durations, curves, breakpoints come **only** from `lib/app/theme/` (one import: `app/theme/theme.dart`). Icons come **only** from `AppIcons` (Material Symbols Rounded) — never raw `Icons.*` or `Symbols.*`. Read brand colours Material doesn't model via `context.colors` (e.g. `context.colors.gold`), never `AppColors.*` directly in features.

**Type**: never set `fontSize`/`fontWeight`/`fontFamily` in a widget. Two families only — **Noto Sans** for all UI (via `context.textTheme.*`, `context.caption/button/overline`; Hindi renders through the Devanagari fallback automatically), and **Cinzel** for **branding only** (`context.brandText.*` — splash/logo/marketing/About/festival/promo). Never use Cinzel in forms, cards, buttons, lists, or paragraphs. Weights limited to Regular/Medium/SemiBold/Bold (`style.regular/.medium/.semiBold/.bold`).
Constants that aren't visual → `lib/app/constants/app_constants.dart`. No magic numbers, no inline hex, no literal `EdgeInsets`/`Duration` where a token exists. If a token is missing, add it to the theme, then use it.

## 3. Responsive first
Must look right on small/normal/large phones, foldables, tablets, and landscape. No fixed widths. Use `LayoutBuilder`, `Expanded`, `Flexible`, and `MediaQuery` breakpoints.

## 4. Every async state is designed
No blank screens. Every API-backed view covers: loading, skeleton, empty, error, success, refreshing, offline — reusing the shared state views above.

## 5. Purposeful micro-animations
Fade/scale/slide/hero, `Animated*` widgets, shimmer skeletons, animated counters/progress/badges, page & expansion transitions, pull-to-refresh, list insert/remove. Smooth and lightweight. Durations from the theme. No distracting motion.

## 6. Performance
Prefer `const`. Split large widgets into small reusable pieces. Watch Riverpod granularly (`select`) to avoid needless rebuilds. Lazy `builder` lists. Cache expensive work. `RepaintBoundary` only where it measurably helps. Riverpod is the state layer (`flutter_riverpod`) — follow its best practices.

## 7. Accessibility
Semantic labels, screen-reader support, respect large text, ≥48dp touch targets, visible focus, adequate contrast.

## 8. Code quality
Small composed widgets over inheritance. No duplicated logic, dead code, commented-out code, unused imports, TODOs, or needless abstraction.

## Feature layout
Features follow `feature/{data,domain,presentation}` (see `lib/features/*`). Shared/core code never imports from a feature.

## Source of truth — the MARG ecosystem
The Flutter app is **one more client** of an existing platform. It never redesigns workflows, invents terminology, changes business logic, or alters API contracts. Two mature apps are authoritative:
- **`../marg_backend`** (Node + Express + Prisma) — the source of truth for all behaviour.
- **`../marg_admin`** (React + TS) — the operational/UX reference (understand intent, then redesign for mobile — never copy desktop layouts).

**Before implementing any feature:** read the backend module, then the admin feature, understand the business rule and the exact API, check for reusable shared widgets — *then* build the mobile UI. If backend/admin define behaviour, follow it. If something looks missing, say so explicitly — never invent it.

### Where the truth lives (backend)
- Domains: `marg_backend/src/modules/<name>/` — one per feature: `auth`, `users`, `temples`, `passport`, `visits`, `routes`, `cards`, `achievements`, `leaderboards`, `referrals`, `notifications`, `locations`, `media`, plus admin/intelligence/audit modules. Endpoints live in each module's `routes/*.routes.ts`.
- **Enums / status values: `marg_backend/prisma/schema.prisma`** (`enum` blocks — e.g. `TempleStatus`, `VisitStatus`, `CardRarity`, `RankTier`, `ReferralStatus`, `TrustChangeReason`, `NotificationType`). Mirror these exactly in Dart; never assume enum values.
- Response envelope: `marg_backend/src/shared/utils/response.ts`; errors: `marg_backend/src/shared/middlewares/error.middleware.ts`.
- Full API reference: `marg_backend/marg_backend.postman_collection.json`.

### API contract (exact — do not guess or rename)
- **Success:** `{ "success": true, "message": string, "data": T }`
- **Paginated:** adds `"pagination": { page, limit, total, totalPages }`
- **Error:** `{ "success": false, "message": string, "errors": [...] }` (validation errors are `{ path, message }`). Clients key off HTTP status + `message`; the generic error body does not include a machine `code`.
- Client base config: `marg_app/lib/core/network/dio_client.dart` (`config.apiBaseUrl`). Never hardcode endpoints — never invent fields, never rename response properties.

### Terminology (use verbatim)
Temple · Passport · Visits · Routes · Cards · Achievements · Leaderboards · Referrals · Trust Score · Temple Completion · Verified Visit · Nearby Temples · Pandit Services. Do not rename these concepts.

### Mobile-first
Reduce complexity vs. the admin desktop view: one primary action per screen, logically grouped info, thumb-friendly targets — while keeping the same product feel (spacing, typography, brand/status colors, icons, badges, terminology).

## Brand consistency
The official MARG assets are the **only** source of truth. Never redesign, recreate, or replace them. Paths are centralized in `lib/app/constants/brand_assets.dart` (`BrandAssets`) — **never hardcode an asset path in a widget.**
- `BrandAssets.logo` → splash, auth, setup, about, settings, drawer, loading (where appropriate)
- `BrandAssets.appIcon` → launcher, notifications, app info, share previews
- `BrandAssets.featuredBanner` → auth, onboarding, marketing, empty states (where appropriate)

Don't overuse branding: content screens (home, temples, passport, cards, achievements, routes) focus on the journey and content, not the logo. Need a branded graphic? Reuse an existing asset before creating any new one. New illustrations must follow the same visual language, palette, and premium devotional aesthetic. Add new asset paths to `BrandAssets`; declare new asset dirs in `pubspec.yaml` (Flutter does **not** recurse into subfolders).

## Before any phase is complete — verify
- [ ] No duplicated widgets; maximum reuse (checked `shared/`/`core/` first)
- [ ] Anything reusable promoted to `shared/`/`core/`
- [ ] Responsive across phone/foldable/tablet/landscape
- [ ] All values from theme/constants — nothing hardcoded
- [ ] Loading / skeleton / empty / error / refreshing / offline states present
- [ ] Smooth, purposeful animations
- [ ] Accessibility (labels, touch targets, large text)
- [ ] Riverpod used efficiently (const, granular watches)
- [ ] No dead code / TODOs / unused imports
- [ ] `flutter analyze` clean and the app builds
