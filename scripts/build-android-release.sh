#!/usr/bin/env bash
# Build MonVlog Android release artifacts for Samsung phone + Android TV / Google TV.
# Usage (from repo root):
#   ./scripts/build-android-release.sh
#   ./scripts/build-android-release.sh --bundle-only
#   ./scripts/build-android-release.sh --apk-only
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DO_APK=1
DO_BUNDLE=1
EXTRA_ARGS=()

for arg in "$@"; do
  case "$arg" in
    --apk-only) DO_BUNDLE=0 ;;
    --bundle-only) DO_APK=0 ;;
    *) EXTRA_ARGS+=("$arg") ;;
  esac
done

if ! command -v flutter >/dev/null 2>&1; then
  echo "error: flutter not on PATH" >&2
  exit 1
fi

echo "==> flutter pub get"
flutter pub get

if [[ "$DO_APK" -eq 1 ]]; then
  echo "==> flutter build apk --release ${EXTRA_ARGS[*]:-}"
  flutter build apk --release "${EXTRA_ARGS[@]}"
  echo "APK: $ROOT/build/app/outputs/flutter-apk/app-release.apk"
fi

if [[ "$DO_BUNDLE" -eq 1 ]]; then
  echo "==> flutter build appbundle --release ${EXTRA_ARGS[*]:-}"
  flutter build appbundle --release "${EXTRA_ARGS[@]}"
  echo "AAB: $ROOT/build/app/outputs/bundle/release/app-release.aab"
fi

echo "Done. Sideload APK via adb (phone or TV); upload AAB to Play Internal testing."
echo "Guide: docs/samsung-install.md"
