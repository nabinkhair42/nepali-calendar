#!/usr/bin/env bash
# Build a distributable .dmg of NepaliCalendar.app and copy it into the
# Next.js public/ tree so Vercel serves it from /downloads/.
#
#   bash release.sh                   → debug build, dist/NepaliCalendar.dmg + web/public/downloads/
#   CONFIG=release bash release.sh    → release build (requires Xcode license)
#
# Notes:
#   - Ad-hoc signed. macOS Gatekeeper will warn on first launch; users
#     need to right-click → Open the first time. For a smoother UX you
#     need a Developer ID Application certificate + notarization.
#   - The .dmg name encodes only the marketing version (e.g. 0.1.0) so
#     the public URL stays stable across builds. If you ever need
#     simultaneous old/new artifacts, switch to `<name>-<version>.dmg`.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="NepaliCalendar"
DISPLAY_NAME="Nepali Calendar"
APP_DIR="$ROOT/build/$APP_NAME.app"

DIST_DIR="$ROOT/dist"
PUBLIC_DIR="$ROOT/../web/public/downloads"

# 1. Build the .app
echo "==> building .app"
bash "$ROOT/build.sh"
[ -d "$APP_DIR" ] || { echo "✗ $APP_DIR not produced"; exit 1; }

# 2. Stage a fresh DMG source folder so we get a clean filesystem layout
#    inside the disk image (just the .app, no build artefacts).
STAGE="$ROOT/build/dmg-stage"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -R "$APP_DIR" "$STAGE/$APP_NAME.app"
# Symlink to /Applications so the user can drag-install.
ln -s /Applications "$STAGE/Applications"

# 3. Pull version for the volume label.
VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_DIR/Contents/Info.plist")"

# 4. Build the .dmg (UDZO = compressed read-only).
mkdir -p "$DIST_DIR"
DMG="$DIST_DIR/$APP_NAME.dmg"
rm -f "$DMG"
echo "==> packaging $DMG (v$VERSION)"
hdiutil create \
    -volname "$DISPLAY_NAME $VERSION" \
    -srcfolder "$STAGE" \
    -ov \
    -format UDZO \
    -fs HFS+ \
    "$DMG" >/dev/null

# 5. Mirror to the Next.js public/ tree so it ships with the next deploy.
mkdir -p "$PUBLIC_DIR"
cp "$DMG" "$PUBLIC_DIR/$APP_NAME.dmg"

# 6. Cleanup stage
rm -rf "$STAGE"

SIZE=$(du -h "$DMG" | awk '{print $1}')
echo ""
echo "✓ built $APP_NAME.dmg ($SIZE)"
echo "  → $DMG"
echo "  → $PUBLIC_DIR/$APP_NAME.dmg"
echo ""
echo "  Next: deploy the web/ project to publish at"
echo "        https://calendar.nabinkhair.com.np/downloads/$APP_NAME.dmg"
