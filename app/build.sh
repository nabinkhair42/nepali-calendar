#!/usr/bin/env bash
# Build NepaliCalendar.app from the Swift Package and bundle it as a status-bar app.
set -euo pipefail

# Default to debug — works on Command Line Tools without an Xcode license.
# Override with CONFIG=release once you have full Xcode installed.
CONFIG="${CONFIG:-debug}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="NepaliCalendar"
APP_DIR="$ROOT/build/$APP_NAME.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RES="$CONTENTS/Resources"

echo "==> swift build (-c $CONFIG)"
cd "$ROOT"
swift build -c "$CONFIG"

BIN="$(swift build -c "$CONFIG" --show-bin-path)/$APP_NAME"
[ -f "$BIN" ] || { echo "binary not found at $BIN"; exit 1; }

echo "==> assembling .app bundle"
rm -rf "$APP_DIR"
mkdir -p "$MACOS" "$RES"
cp "$BIN" "$MACOS/$APP_NAME"
cp "$ROOT/Info.plist" "$CONTENTS/Info.plist"

# Optional resources (icons etc.)
if [ -d "$ROOT/Resources" ] && [ -n "$(ls -A "$ROOT/Resources" 2>/dev/null || true)" ]; then
    cp -R "$ROOT/Resources/." "$RES/"
fi

# SPM resource bundles (BSCore festival JSON, future fonts, etc.)
SPM_BIN_DIR="$(swift build -c "$CONFIG" --show-bin-path)"
for bundle in "$SPM_BIN_DIR"/*.bundle; do
    [ -d "$bundle" ] && cp -R "$bundle" "$RES/"
done

# Ad-hoc sign so macOS will run the bundle locally.
echo "==> ad-hoc signing"
codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "==> built: $APP_DIR"
echo "    open $APP_DIR   # launch"
