# MonVlog

Flutter **phone + TV** app for MonVlog / Monvlog.com — Mongolian creator vlogs
with a Wix Spaces–style community shell on phone and a **Netflix-style** dark
UI on Android TV / Google TV (Samsung living-room path).

**Product:** MonVlog / Monvlog.com  
**Tagline:** Монголчуудын нэгдэл  
**Brand red:** `#D32F2F` · coral accents `#E58A8A`  
**Price (later):** **$3.99/month** via RevenueCat (stubbed)  
**Repo:** [Magi888/MonVlog](https://github.com/Magi888/MonVlog)

## Surfaces

| Surface | Route | Notes |
|---|---|---|
| **Phone community** | `/phone` | EUROPE TOUR hero, Invite / Оператор, tabs incl. **МОНГОЛ ВЛОГ & КОНТЕНТ**, All Video Channels cards |
| **Phone Watch** | Watch tab / `/phone/watch` | Netflix-style dark horizontal rails (mock catalog) |
| **TV / Samsung living room** | `/tv` or `/home` | Left rail + focusable shelves; **no** phone bottom bar |
| **Admin login** | `/admin/login` | Seeded admin email + password (see below) |
| **Admin catalog** | `/admin/catalog` | Search YouTube channels/playlists → add to curated catalog (admin only) |
| Splash | `/splash` | Routes phone vs TV by viewport |

YouTube Data API and RevenueCat stay **stubbed/mocked** for the visual demo — **no API keys required**.
Without `YOUTUBE_API_KEY`, admin channel search shows **mock results** with a clear UI banner.

## Samsung / Android TV / Tizen

- **Target for Samsung TVs in this MVP:** **Android TV / Google TV** leanback
  (`LEANBACK_LAUNCHER`, `android.software.leanback` already in the Android
  manifest). Many Samsung living-room devices that run Google TV / Android TV
  can install this Flutter Android build.
- **Stock Flutter does not ship a Tizen target.** Native Tizen (older Samsung
  Tizen-only models) would need a community / third-party **Tizen Flutter
  plugin** or a separate Tizen Web app later — not included here.
- Apple TV (tvOS) notes remain in [`docs/tvos.md`](docs/tvos.md).

## Requirements

- Flutter **stable** (3.35+ / Dart 3.9+)
- Chrome (fast phone + TV viewport demos) or Android emulator / iOS simulator
- Optional: Android TV emulator for leanback (`/tv`)
- Optional: YouTube Data API key for live shelves (not required)

## Getting started (mock — no API keys)

```sh
flutter pub get
```

### Phone UI on Chrome

```sh
flutter run -d chrome --web-browser-flag "--window-size=390,844"
```

Flow: splash → **Community** (Wix-like) → **Watch** tab for Netflix rails.

### TV Netflix shell on Chrome

```sh
flutter run -d chrome --web-browser-flag "--window-size=1280,720"
```

Wide viewport splash routes to `/tv` (left rail + shelves). Or open `/tv` directly.

### Live YouTube shelves (optional)

```sh
flutter run -d chrome \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY_HERE
```

### Admin catalog (curate channels)

Seeded admin identity: **`maag888@gmail.com`**.

**Never commit the password.** Pass it only at run/build time:

```sh
flutter run -d chrome \
  --dart-define=ADMIN_PASSWORD=YOUR_SECRET_HERE \
  --web-browser-flag "--window-size=390,844"
```

On first launch the password is **hashed into flutter_secure_storage**. Later runs can authenticate from that stored hash without re-supplying the define (until storage is cleared). You may still pass `ADMIN_PASSWORD` every run if you prefer.

Optional live search (otherwise mock search with an on-screen note):

```sh
flutter run -d chrome \
  --dart-define=ADMIN_PASSWORD=YOUR_SECRET_HERE \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY_HERE
```

- Open **Admin** from the phone top-right icon, TV **Settings → Admin sign-in**, or `/admin/login`.
- Only the admin session can open `/admin/catalog` (role gate). Everyone else browses shelves read-only.
- Added channels/playlists merge into local JSON overrides (`SharedPreferences`) on top of `assets/config/curated_channels.json` (same shape as optional remote `CURATED_CHANNELS_URL`).
- Videos are auto-categorized into Travel / Food / Daily / Featured shelves via title/description heuristics.

## Project layout

```
lib/
  app/                 # theme, router, form-factor
  auth/                # admin login, seed email, secure password bootstrap
  features/
    admin/             # login + catalog search/add UI
    phone/             # Community (Wix-like) + Watch rails + shell
    tv/                # Netflix left-rail shell + billboard
    home/              # shared focusable shelf / poster widgets
    splash/            # brand splash → /phone or /tv
    detail/            # video detail (shared)
  data/                # curated JSON, catalog store, categorizer, YouTube client
  billing/             # RevenueCat stub — no API keys
  platform/            # Android YouTube intent helper
assets/
  promo/europe-tour-hero.jpg
  brand/monvlog-logo-mark.jpg
  config/curated_channels.json
docs/
  tvos.md
  screenshots/
```

## Design notes

### Phone
- Dark community shell matching Wix Spaces refs
- Full-bleed EUROPE TOUR hero + overlapping logo / Monvlog.com / Invite · Оператор
- Horizontal tabs including **МОНГОЛ ВЛОГ & КОНТЕНТ**
- **All Video Channels** cards with View Channel
- Watch tab: dark Netflix poster rails

### TV
- Near-black Netflix canvas, large posters, white D-pad focus rings
- Left rail: Home · Creators · Search · Library · Settings
- Featured billboard + horizontal shelves from mock/live catalog

### Screenshots

![Community](docs/screenshots/community.png)

![Watch](docs/screenshots/watch.png)

![TV home](docs/screenshots/tv-home.png)

## Secrets policy

- **Do not** commit YouTube, RevenueCat, or **admin passwords**.
- Mock demo needs **zero** secrets.
- Pass YouTube key only via `--dart-define=YOUTUBE_API_KEY=...` when testing live.
- Pass admin password only via `--dart-define=ADMIN_PASSWORD=...` (or rely on the one-time secure-storage bootstrap from that define).

## Tests / analyze

```sh
flutter analyze
flutter test
```

## Milestone map

| # | Outcome |
|---|---|
| M0 | Flutter TV shell |
| M1 | Full TV IA / focus nav |
| M2 | YouTube curated catalog → shelves → detail |
| **UI** | Phone community + Netflix phone Watch + TV left rail |
| **Admin** | Admin login + YouTube channel/playlist catalog curation |
| M3 | In-app player |
| M4 | RevenueCat $3.99/mo gate |
| M5–M6 | Store readiness & soft launch |
