# Samsung TV install (Android TV / Google TV)

> **Full guide (phone + TV):** [`samsung-install.md`](samsung-install.md)

MonVlog’s Samsung living-room path is the same Flutter **Android** APK used on phones, with leanback so it appears on the TV Apps row. Pure **Tizen-only** Samsung TVs are not supported by this APK.

## Build

```sh
flutter pub get
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# optional Play bundle
flutter build appbundle --release

./scripts/build-android-release.sh   # same APK (+ AAB if bundle tools OK)
```

## Sideload on Samsung Google TV / Android TV

1. On the TV: enable **Developer options** + **USB debugging**  
   (often **Settings → Device Preferences → About → Build number** — tap until developer mode unlocks; then enable USB debugging).
2. Put the TV and your computer on the **same Wi‑Fi**. Note the TV’s IP (Network / About).
3. From your computer:

```sh
adb connect TV_IP:5555
adb devices          # confirm the TV is listed
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

4. Open **MonVlog** from the TV **Apps** row (leanback banner 320×180).
5. Splash detects Android TV / wide landscape → Netflix-style **`/tv`** shell (left rail: Home · Creators · Search · Library · Settings).
6. D-pad: move focus on shelves / creator list → **Select** opens detail → **Play** starts the in-app YouTube player (`/play`). Back exits player → detail → catalog.

**USB stick:** some Google TV builds allow installing an APK from a USB drive via a file manager. Prefer ADB when possible.

## Manifest (TV)

- `LEANBACK_LAUNCHER` + `android:banner` (`tv_banner` 320×180)
- `touchscreen` / `leanback` features with `required="false"` (so phones still install)
- Native `UiModeManager` television check so the app opens the TV shell on leanback devices

## Limits

- Works on Samsung TVs that run **Android TV / Google TV** (Google Play present).
- **Not** stock Tizen-only models — Flutter has no Tizen target; see [`samsung-install.md`](samsung-install.md) §5.
- Galaxy Store is not the TV path; use ADB or Google Play on the TV.
