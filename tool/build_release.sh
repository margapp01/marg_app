#!/usr/bin/env bash
# Builds the Play Store bundle with the production configuration baked in.
#
# Compile-time settings (the Mapbox token) live in the git-ignored
# dart_defines.local.json. A release built without it silently falls back to
# OpenStreetMap tiles and can't name the user's city, so this script refuses
# to build without the token and checks the finished bundle really carries it.
#
#   tool/build_release.sh            # → build/app/outputs/bundle/release/app-release.aab
#
# Bump `version:` in pubspec.yaml (the +build number) before each upload.
set -euo pipefail
cd "$(dirname "$0")/.."

DEFINES=dart_defines.local.json
AAB=build/app/outputs/bundle/release/app-release.aab

[ -f "$DEFINES" ] || { echo "✗ Missing $DEFINES (needs MAPBOX_TOKEN)."; exit 1; }
[ -f android/key.properties ] || { echo "✗ Missing android/key.properties (upload signing key)."; exit 1; }

python3 -I - "$DEFINES" <<'PY'
import json, sys
defines = json.load(open(sys.argv[1]))
if not str(defines.get("MAPBOX_TOKEN", "")).startswith("pk."):
    sys.exit("✗ MAPBOX_TOKEN is missing or not a public (pk.) token in dart_defines.local.json.")
api = defines.get("API_BASE_URL")
if api and not str(api).startswith("https://api.margapp.in/"):
    sys.exit(f"✗ API_BASE_URL in dart_defines.local.json points at {api} — remove it for a store build.")
print("✓ Release defines look right.")
PY

flutter build appbundle --release --dart-define-from-file="$DEFINES" "$@"

python3 -I - "$AAB" <<'PY'
import sys, zipfile
bundle = zipfile.ZipFile(sys.argv[1])
libs = [n for n in bundle.namelist() if n.endswith("/libapp.so")]
if not libs or not all(b"pk.eyJ" in bundle.read(n) for n in libs):
    sys.exit("✗ The Mapbox token is NOT in the bundle — do not upload it.")
print(f"✓ Mapbox token present in {len(libs)} ABI(s). Ready to upload: {sys.argv[1]}")
PY
