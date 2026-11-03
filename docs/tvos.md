# Apple TV (tvOS) path for MonVlog

Official Flutter **does not** ship a first-class `tvos` target in `flutter create`
(platforms are `android`, `ios`, `web`, `macos`, `linux`, `windows`). App Store
Connect docs still note that Flutter apps leave the tvOS checkbox unchecked for
stock Flutter.

MonVlog still targets **Apple TV** for the product. For M0 we keep the standard
`ios/` runner (shared Darwin family) and document the community toolchain used
to produce a real `tvos/` embedder.

## Recommended toolchain: [flutter-tvos](https://github.com/fluttertv/flutter-tvos)

Requires **macOS + Xcode** (not available in this Linux CI/agent environment).

```sh
git clone https://github.com/fluttertv/flutter-tvos.git
cd flutter-tvos
export PATH="$PATH:$PWD/bin"
flutter-tvos precache
flutter-tvos doctor

# From the MonVlog repo root (after Flutter project exists):
# flutter-tvos create can refresh / add a tvos/ platform folder on macOS.
# Prefer aligning the flutter-tvos release line with this project's Flutter
# SDK (see pubspec / .metadata) via `flutter-tvos versions` / `flutter-tvos use`.
flutter-tvos devices
flutter-tvos run -d <apple-tv-simulator-or-device-id>
```

Notes from the flutter-tvos project:

- tvOS is treated as its **own** platform (`tvos/` folder, separate plugin key).
- Plugins must declare a `tvos:` entry under `flutter.plugin.platforms` to load.
- `Platform.isIOS` is `true` on tvOS; check `Platform.operatingSystem == 'tvos'`
  (or their `Platform.isTvOS`) when branching.
- There is **no** Android-style Intent to open the YouTube app — stay in-app for
  playback (M3) or use an allowed web presentation after ToS review.

## In-repo stubs (this repo)

| Path | Role |
|---|---|
| `ios/` | Stock Flutter iOS runner — baseline until `tvos/` is generated on macOS |
| `lib/platform/youtube_intent.dart` | Android-only; no-ops / logs on non-Android |
| `lib/billing/purchases_stub.dart` | RevenueCat placeholders for StoreKit later |

When a Mac with Xcode is available, generate/add the `tvos/` platform with
`flutter-tvos` and commit the resulting folder in a follow-up PR. Do not invent a
hand-written Xcode tvOS project that the stock Flutter tool cannot build.

## Verification checklist (macOS)

1. `flutter-tvos doctor` clean
2. Boot Apple TV simulator; D-pad / Siri Remote focus reaches Home posters
3. Confirm lean-back focus rings (see `PosterCard`)
4. Defer real IAP / YouTube player until M3–M4
