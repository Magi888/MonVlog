# MonVlog

Phone-first Flutter UI **zagvar** (visual mockup) for MonVlog, plus the existing
Android TV leanback shell and curated YouTube catalog (mock without API keys).

**Product:** MonVlog / Monvlog.com  
**Tagline:** Монголчуудын нэгдэл  
**Brand red:** `#D32F2F`  
**Price (later):** **$3.99/month** via RevenueCat (stubbed)  
**Repo:** [Magi888/MonVlog](https://github.com/Magi888/MonVlog)

## What this tree demos

| Surface | Route | Notes |
|---|---|---|
| **Phone community** (primary) | `/phone` | Full-bleed EUROPE TOUR hero, overlapping white profile card, red logo, Invite / Оператор |
| **Phone watch shelves** | Watch tab | Reuses mock/live catalog — no API key required |
| **TV leanback home** | `/home` or `/tv` | M0/M2 dark shelves + focus rings intact |
| Splash | `/splash` | Brand gate → phone shell |

YouTube Data API and RevenueCat stay **stubbed/mocked** for the visual demo.

## Requirements

- Flutter **stable** (3.35+ / Dart 3.9+)
- Chrome (fastest phone mockup) or Android emulator / iOS simulator
- Optional: Android TV emulator for leanback (`/tv`)
- Optional: YouTube Data API key for live shelves (not required)

## Getting started (mockup — no API keys)

```sh
flutter pub get
```

### Phone UI on Chrome (recommended demo)

```sh
flutter run -d chrome --web-browser-flag "--window-size=390,844"
```

Or open DevTools device toolbar after launch and pick a phone size.

Flow: splash → **Community** (reference look) → **Watch** tab for video shelves.

### Phone UI on Android emulator

```sh
flutter devices
flutter run -d <android-phone-emulator-id>
```

### TV leanback (unchanged)

```sh
flutter run -d <android-tv-emulator-id>
# then open /tv, or temporarily change splash to context.go('/tv')
```

From a running phone build you can deep-link:

```sh
flutter run -d chrome --web-browser-flag "--window-size=1280,720"
# navigate to http://localhost:<port>/tv  (path URL strategy may vary)
```

Or in Dart: `context.go('/tv')`.

### Live YouTube shelves (optional)

```sh
flutter run -d chrome \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY_HERE
```

Without a key, Watch uses the in-app **mock catalog**.

## Project layout

```
lib/
  app/                 # theme (phone light + TV dark), router, MaterialApp
  features/
    phone/             # Community zagvar + Watch shelves + shell
    home/              # TV leanback shelves (preserved)
    splash/            # brand splash → /phone
    detail/            # video detail (shared)
  data/                # curated JSON, YouTube client, mock catalog
  billing/             # RevenueCat stub — no API keys
  platform/            # Android YouTube intent helper
assets/
  promo/europe-tour-hero.jpg
  brand/monvlog-logo-mark.jpg
  config/curated_channels.json
docs/
  tvos.md
```

## Design notes (phone)

- Brand-first: red hero + overlapping **MonVlog** mark before body copy
- Full-bleed EUROPE TOUR promo (no inset hero card clutter)
- Navy type (`#0D1B2A`), outlined **Invite**, solid red **Оператор**
- Typography: Bebas Neue (display) + Manrope (UI) via `google_fonts`
- Motion: hero fade, profile card slide-up, logo elastic scale

## Secrets policy

- **Do not** commit YouTube or RevenueCat keys.
- Mock demo needs **zero** secrets.
- Pass YouTube key only via `--dart-define=YOUTUBE_API_KEY=...` when testing live.

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
| **UI mock** | **Phone community zagvar + Watch tab (this)** |
| M3 | In-app player |
| M4 | RevenueCat $3.99/mo gate |
| M5–M6 | Store readiness & soft launch |
