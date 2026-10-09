# MARG — image assets

The app works without any of the art below: every slot falls back to a tinted
Material Symbol (`IllustratedIcon`) or to nothing (`StateArtImage`). All paths
live in `lib/app/constants/brand_assets.dart` (`BrandAssets`).

## House style (for every new image)

Match the empty-state set in `docs/empty-states/`: watercolour, saffron +
navy palette, temple arch / lotus motifs, soft white backdrop, square
(~1254 × 1254). **No text in the image** — titles are rendered in-app so they
work in English and Hindi. Icons: 512 × 512, transparent PNG, soft 3D glossy.

Drop the source into `docs/empty-states/` (any name) and ask Claude to run the
pipeline below — or add the JOB yourself.

## Pipeline (`tool/art/`)

- `make_states.py` — crops the baked-in title/subtitle/button off a state
  illustration, turns the white paper into alpha (colour-to-alpha + edge
  vignette) and exports an 800 px WebP to `assets/images/illustrations/`.
  Add a line to `JOBS` with the crop bottom (first row of the title).
- `board_cutouts.py` — cuts 3D graphics out of the `/docs` UI boards with
  GrabCut, upscales ×3 and feathers the edge. Use for interim art only — the
  boards are low-resolution.

Both need `numpy pillow opencv-python-headless` (a throwaway venv is fine).

## Done

| Asset | Source (`docs/empty-states/` unless noted) | Used by |
|---|---|---|
| `state_journey.webp` | Your Journey Awaits | Yatra / route empty states |
| `state_no_visits.webp` | No Bookings Yet (suitcase) | Passport visits, timeline, map |
| `state_bookmarks.webp` | Nothing Saved Yet (bookmark) | reserved for blog / quote bookmarks |
| `state_saved_places.webp` | No Saved Places | Saved Places |
| `state_no_results.webp` | No Results Found | Search, filters, galleries |
| `state_not_found.webp` | No Bookings Found (scroll) | unknown deep links (404) |
| `state_location.webp` | Location Not Available | Nearby Temples |
| `state_notifications.webp` | No Notifications Yet | Notification Center / History / Activity |
| `state_offline.webp` | Temple Serenity – No Internet Connection | `OfflineError`, Home / Search offline |
| `state_error.webp` | Temple Lamp Error Screen | every `ErrorView` by default, `ServerError` |
| `state_unexpected.webp` | Something Went Wrong at the Temple | `UnknownError` |
| `state_timeout.webp` | Ornate Temple Hourglass – Please Wait | `TimeoutError` |
| `state_permission.webp` | No Access Yet – Temple Treasure Chest | `PermissionDeniedError` |
| `state_coming_soon.webp` | Coming Soon – Temple Sanctuary | `PlaceholderScaffold` (not-yet screens) |
| `state_empty.webp` | Nothing Here Yet – Temple Serenity | Compare prompt, devices, statistics, empty pages, collection groups |
| `state_cards.webp` | No Sacred Cards Yet | Cards: recently unlocked, series, seasons |
| `state_collection.webp` | Sacred Temple Card Collection | `CardsEmpty` (no cards collected) |
| `state_achievements.webp` | Temple Medal Empty State | Achievements: recent, milestones |
| `state_leaderboard.webp` | Temple Leaderboard Empty State | Leaderboards, Community ranking |
| `state_referrals.webp` | No Invites or Rewards Yet | Referral timeline, rewards |
| `state_certificates.webp` | No Passport Certificates Yet | Passport certificates |
| `state_festivals.webp` | No Upcoming Festivals at the Temple | Festival updates, Knowledge festivals |
| `state_knowledge.webp` | Temple Wisdom Empty State | Daily quote ×2, Announcements |
| `setup_complete.webp` | onboarding board (`docs/image copy.png`), enhanced ×3 | "You're all set!" after setup |
| `invite_gift.png`, `support_headset.png` | cut from boards 15 / 4 | Home Invite & Help cards |
| `checkin_success.png`, `checkin_failed.png` | cut from board 7 | Visit verified / failed |
| `medal_trishul.png` | cut from board 7 | default achievement badge, visit achievement step |
| `points_coins.png` | cut from board 15 | Referral rewards balance |

Unused source: `Golden Temple Leaderboard Podium.png` (dark backdrop doesn't
fit the light empty-state style).

## Still wanted

1. Higher-resolution replacements (same names) for the board cut-outs above.

Icons (512 × 512, transparent):
- `assets/images/icons/` — `qa_routes` (map with dotted path + pins), `qa_nearby`
  (pin with temple), `qa_cards` (gold-bordered temple card), `qa_achievements`
  (shield medal with lotus), `qa_passport` (navy passport with Om), `qa_saved`
  (bookmark ribbon), `qa_festivals` (diya), `qa_knowledge` (open book),
  `qa_invite` (gift box), `qa_support` (headset)
- `assets/images/deities/` — `deity_shiva` (trishul + damaru), `deity_devi`
  (lotus + crown), `deity_vishnu` (conch + chakra), `deity_ganesha` (modak),
  `deity_hanuman` (gada), `deity_surya` (sun disc) — symbols, no faces
- `assets/images/categories/` — `cat_jyotirlinga`, `cat_shakti_peeth`, `cat_char_dham`

## Seeded photographs

Temple, route, card, festival and blog images in the dev database come from
Wikimedia Commons (credited in each temple image caption) via
`marg_backend/prisma/seed-showcase.ts`. They are demo content, not app assets.
