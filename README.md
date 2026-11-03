# MonVlog

Lean TV-first subscription app that aggregates Mongolian creators’ YouTube vlogs
for Android TV / Google TV and Apple TV.

**Product:** MonVlog  
**Price (later):** **$3.99/month** via store IAP through **RevenueCat**  
(`monvlog_premium_monthly` → entitlement `premium`)  
**Repo:** [Magi888/MonVlog](https://github.com/Magi888/MonVlog)

This tree is **M0 — Flutter TV bootstrap**: splash → home shelves with focusable
mock posters. No YouTube or RevenueCat secrets are committed.

## Requirements

- Flutter **stable** (scaffold built with 3.35.x / Dart 3.9)
- Android Studio / SDK for Android TV emulator
- macOS + Xcode for Apple TV (see [docs/tvos.md](docs/tvos.md))

## Getting started

```sh
flutter pub get
```

### Android TV emulator

1. In Android Studio → Device Manager → Create Device → **TV** category  
   (e.g. Television 1080p, API 34).
2. Start the emulator.
3. From the repo root:

```sh
flutter devices
flutter run -d <android-tv-emulator-id>
```

D-pad / keyboard arrows move focus across shelf posters; Enter/Select activates.

The Android app declares:

- `LEANBACK_LAUNCHER` intent filter
- `android.software.leanback` (`required="false"`)
- `android.hardware.touchscreen` (`required="false"`)
- TV banner at `android/app/src/main/res/drawable/tv_banner.png`

### Apple TV (tvOS)

Official Flutter does not include a `tvos` platform in `flutter create`. MonVlog
uses the community **flutter-tvos** toolchain on macOS. Full steps:
**[docs/tvos.md](docs/tvos.md)**.

The `ios/` folder is the stock Flutter iOS runner kept as the Darwin baseline
until `tvos/` is generated on a Mac.

### Desktop / Chrome (shell only)

For quick UI iteration without a TV emulator:

```sh
flutter run -d chrome
# or
flutter run -d linux
```

Focus rings still respond to keyboard arrows.

## Project layout

```
lib/
  app/           # theme, router, MaterialApp
  features/      # splash, home (+ shelf / poster widgets)
  data/          # mock catalog + models (YouTube API later)
  billing/       # RevenueCat stub — no API keys
  platform/      # Android YouTube intent helper
docs/
  tvos.md        # Apple TV / flutter-tvos notes
```

## Dependencies (M0)

| Package | Role |
|---|---|
| `go_router` | splash → home |
| `flutter_riverpod` | app DI / router provider |
| `dio` | reserved for YouTube Data API |
| `purchases_flutter` | RevenueCat (stubbed configure) |
| `cached_network_image` | poster thumbnails |
| `shared_preferences` | continue-watching (wired later) |
| `android_intent_plus` | YouTube TV/app fallback |

## Secrets policy

- **Do not** commit YouTube Data API keys or RevenueCat public SDK keys.
- Placeholders live in `lib/billing/purchases_stub.dart`.
- M4 will load keys via `--dart-define` / secure store config.

## Milestone map

| # | Outcome |
|---|---|
| **M0** | This shell on Android TV emulator + tvOS path documented |
| M1 | Full IA / focus nav |
| M2 | YouTube curated catalog |
| M3 | In-app player (+ Android intent fallback) |
| M4 | RevenueCat $3.99/mo gate |
| M5–M6 | Store readiness & soft launch |
