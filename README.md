# MonVlog

Lean TV-first subscription app that aggregates Mongolian creators’ YouTube vlogs
for Android TV / Google TV and Apple TV.

**Product:** MonVlog  
**Price (later):** **$3.99/month** via store IAP through **RevenueCat**  
(`monvlog_premium_monthly` → entitlement `premium`)  
**Repo:** [Magi888/MonVlog](https://github.com/Magi888/MonVlog)

This tree is **M2 — YouTube curated catalog**: splash → home shelves loaded from
YouTube Data API v3 (or mock fallback) → video detail with metadata. TV focus
rings from M0 are preserved. No YouTube or RevenueCat secrets are committed.

## Requirements

- Flutter **stable** (scaffold built with 3.35.x / Dart 3.9+)
- Android Studio / SDK for Android TV emulator
- macOS + Xcode for Apple TV (see [docs/tvos.md](docs/tvos.md))
- Optional: a **YouTube Data API v3** key (Google Cloud Console)

## Getting started

```sh
flutter pub get
```

### Run without an API key (mock catalog)

```sh
flutter run -d <device>
```

Home shelves use the in-app mock catalog. Posters open the **detail** screen.

### Run with YouTube Data API (live shelves)

1. Create a Google Cloud project → enable **YouTube Data API v3**.
2. Create an API key. Restrict it by Android package (`com.monvlog.monvlog`) /
   iOS bundle ID when you can.
3. Pass the key at build time — **never** commit it:

```sh
flutter run -d <device> \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY_HERE
```

Optional remote allowlist (same JSON shape as the in-repo file):

```sh
flutter run -d <device> \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY_HERE \
  --dart-define=CURATED_CHANNELS_URL=https://example.com/curated_channels.json
```

### Android TV emulator

1. In Android Studio → Device Manager → Create Device → **TV** category  
   (e.g. Television 1080p, API 34).
2. Start the emulator.
3. From the repo root:

```sh
flutter devices
flutter run -d <android-tv-emulator-id> \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY_HERE
```

D-pad / keyboard arrows move focus across shelf posters; Enter/Select opens
detail. Back returns to home.

### Apple TV (tvOS)

Official Flutter does not include a `tvos` platform in `flutter create`. MonVlog
uses the community **flutter-tvos** toolchain on macOS. Full steps:
**[docs/tvos.md](docs/tvos.md)**.

### Desktop / Chrome (shell only)

```sh
flutter run -d chrome
# or
flutter run -d linux
```

## Curated channel allowlist

Seed list (≈25 entries): [`assets/config/curated_channels.json`](assets/config/curated_channels.json)

- **`verified: true`** — public `UC…` IDs resolved from YouTube handles.
- **`verified: false` / `STUB` in `channelId` or notes** — editorial placeholders;
  replace before production. Stubs are skipped by the live API client.
- Edit the JSON in-repo, or host the same shape and point
  `CURATED_CHANNELS_URL` at it.

Live shelves:

1. `channels.list` → uploads playlist ID  
2. `playlistItems.list` → recent uploads (fallback: `search.list` by `channelId`)  
3. `videos.list` → duration, description, view count  

If the key is missing or the request fails, shelves fall back to the mock catalog.

## Project layout

```
lib/
  app/           # theme, router, MaterialApp
  features/      # splash, home, detail
  data/          # curated JSON loader, YouTube client, catalog repo, mock
  billing/       # RevenueCat stub — no API keys
  platform/      # Android YouTube intent helper
assets/config/
  curated_channels.json
docs/
  tvos.md
```

## Secrets policy

- **Do not** commit YouTube Data API keys or RevenueCat public SDK keys.
- Pass YouTube key via `--dart-define=YOUTUBE_API_KEY=...` only.
- `.env`, `secrets/`, and store config files are gitignored.
- RevenueCat placeholders live in `lib/billing/purchases_stub.dart` (M4).

## Tests / analyze

```sh
flutter analyze
flutter test
```

## Milestone map

| # | Outcome |
|---|---|
| M0 | Flutter TV shell on Android TV + tvOS path documented |
| M1 | Full IA / focus nav |
| **M2** | **YouTube curated catalog → shelves → detail (this)** |
| M3 | In-app player (+ Android intent fallback) |
| M4 | RevenueCat $3.99/mo gate |
| M5–M6 | Store readiness & soft launch |
