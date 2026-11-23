# Samsung TV install (Android TV / Google TV)

> **Full guide (phone + TV):** [`samsung-install.md`](samsung-install.md)

MonVlog’s Samsung living-room path is the same Flutter **Android** APK used on phones, with leanback so it appears on the TV Apps row.

## Build

```sh
flutter pub get
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# optional Play bundle
flutter build appbundle --release

./scripts/build-android-release.sh   # same APK (+ AAB if bundle tools OK)
```

## Install on Samsung Google TV / Android TV

1. Enable **Developer options** + **USB debugging** on the TV.
2. Same Wi‑Fi as your computer; note the TV IP.
3. Install:

```sh
adb connect TV_IP:5555
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

4. Open **MonVlog** from the TV Apps row (leanback banner).

## Manifest (TV)

- `LEANBACK_LAUNCHER` + `android:banner` (`tv_banner` 320×180)
- `touchscreen` / `leanback` features with `required="false"` (so phones still install)

## Limits

- Works on Samsung TVs that run **Android TV / Google TV** (Google Play).
- **Not** stock Tizen-only models — Flutter has no Tizen target; see [`samsung-install.md`](samsung-install.md) §5.
- Galaxy Store is not the TV path; use ADB or Google Play on the TV.
