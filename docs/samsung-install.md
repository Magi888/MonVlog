# Install MonVlog on Samsung phone + Samsung TV

One Flutter **Android** build (`APK` or Play **AAB**) covers:

| Device | Launcher | How it appears |
|---|---|---|
| **Samsung phone / tablet** | `LAUNCHER` | Normal home-screen icon |
| **Samsung Android TV / Google TV** | `LEANBACK_LAUNCHER` | TV Apps row + `tv_banner` (320×180) |

Stock Flutter **does not** ship a Tizen target. Pure Tizen Samsung TVs (no Google Play) need a later Tizen / web path — not this APK.

**Package ID:** `com.monvlog.monvlog`  
**Min SDK:** Flutter default (≥ **API 21**). Android TV leanback officially starts at API 21; modern Google TV Samsung sets are usually API 29+.

Related: [`samsung-tv-install.md`](samsung-tv-install.md) (TV-focused short link) · [`tvos.md`](tvos.md) (Apple TV)

---

## 1. Build the release APK / AAB

From the repo root (Flutter stable 3.35+):

```sh
flutter pub get

# Sideload-friendly APK (USB / ADB)
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# Or use the helper script
./scripts/build-android-release.sh

# Play Console / Internal testing (preferred for phones)
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

Release currently signs with the **debug** keystore in `android/app/build.gradle.kts` so local installs work. For Play / Galaxy Store production, add a real upload keystore before shipping.

Optional dart-defines (same as README):

```sh
flutter build apk --release \
  --dart-define=ADMIN_PASSWORD=YOUR_SECRET \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY
```

---

## 2. Samsung phone (Galaxy)

### A) USB debugging + ADB (fast for testers)

1. On the phone: **Settings → About phone → Software information** → tap **Build number** 7 times (Developer mode).
2. **Settings → Developer options** → enable **USB debugging**.
3. Plug USB (use a data cable). Allow the RSA prompt on the phone.
4. On your computer:

```sh
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

5. Open **MonVlog** from the app drawer. Phone UI uses the community / Watch shell (`/phone`).

**“Install blocked” / unknown sources:** on newer One UI, ADB installs are usually allowed when USB debugging is on. If you copy the APK via file share instead, enable install from that source when Android asks.

### B) Google Play Internal testing (recommended for friends / QA)

1. Upload `app-release.aab` to [Google Play Console](https://play.google.com/console) → **Testing → Internal testing**.
2. Add tester Gmail accounts (or a Google Group).
3. Testers open the opt-in link on the **Samsung phone** → install from Play.
4. Updates flow through Play; no USB needed after the first invite.

### C) Galaxy Store?

Galaxy Store is optional for Samsung **phones**. This MVP path is **Google Play** (Internal → closed → production). Galaxy Store needs a separate Samsung Seller Portal listing and is not required for sideload / Play testing.

---

## 3. Samsung TV (Android TV / Google TV)

Only TVs that run **Android TV or Google TV** (Google Play present) can install this APK. Many recent Samsung living-room models with Google TV qualify; older **Tizen-only** sets do **not**.

### A) Developer / ADB on the TV

1. On the TV: open **Settings** and enable **Developer options** (often: About → Build number taps, or **Device Preferences → About → Build** — menus vary by Google TV / Android TV skin).
2. Enable **USB debugging** (and **Stay awake** if offered).
3. Note the TV’s IP: **Network / About** (example `192.168.1.40`).
4. On your computer (same Wi‑Fi):

```sh
adb connect 192.168.1.40:5555
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

5. On the TV Apps / Games row you should see **MonVlog** with the leanback **banner**. Open it — splash routes to the Netflix-style `/tv` shell on a wide display.

**USB stick sideload:** some Google TV builds allow installing an APK from a USB drive via a file manager. Prefer ADB when possible (clearer permissions).

### B) Play on TV

If the app is published (or Internal testing includes the TV’s Google account), install from the **Play Store app on the TV**. Leanback + banner are required for a proper TV listing; this project already declares them in `AndroidManifest.xml`.

### C) Galaxy Store on TV?

Samsung **Galaxy Store** is phone-centric. Living-room Google TV Samsung devices use **Google Play**, not Galaxy Store, for this Flutter Android build.

---

## 4. Manifest checklist (already in repo)

| Item | Status |
|---|---|
| `android.intent.category.LAUNCHER` | Yes — phone home icon |
| `android.intent.category.LEANBACK_LAUNCHER` | Yes — TV Apps row |
| `android.hardware.touchscreen` `required="false"` | Yes |
| `android.software.leanback` `required="false"` | Yes (false = phone **and** TV) |
| `android:banner` `@drawable/tv_banner` | Yes — 320×180 xhdpi PNG |
| Internet permission | Yes |

If `leanback` were `required="true"`, Play would hide the app from phones — keep it **false** for the dual Samsung phone + TV APK.

---

## 5. Limitations vs pure Tizen

| | This Flutter Android build | Pure Tizen |
|---|---|---|
| Samsung phone | Yes (APK / Play) | N/A |
| Samsung TV with Google Play / Google TV | Yes (leanback APK) | Alternate native path |
| Older Tizen-only Samsung TV | **No** | Needs Tizen Web / community Flutter-Tizen later |
| Stock `flutter create` Tizen target | **No** | Not shipped by Flutter |
| Focus / D-pad | Flutter TV shell (`/tv`) | Tizen remote APIs |

---

## 6. Quick troubleshoot

| Problem | Fix |
|---|---|
| `adb devices` empty | Same Wi‑Fi; accept debug prompt; `adb kill-server` then reconnect |
| App missing on TV Apps row | Confirm `LEANBACK_LAUNCHER` + banner; reinstall APK |
| Phone install OK, TV rejects | TV may be Tizen-only (no Google Play) — APK will not run |
| Play says device not compatible | Check minSdk / leanback flags; Internal track must include the tester account |
| Wrong UI (phone chrome on TV) | Open `/tv` or use a wide display; splash uses viewport form-factor |

---

## 7. Exact install steps (copy/paste)

**Build once:**

```sh
cd MonVlog
flutter pub get
./scripts/build-android-release.sh
```

**Samsung phone:**

```sh
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

**Samsung Google TV / Android TV:**

```sh
adb connect TV_IP:5555
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Then open **MonVlog** on the device.
