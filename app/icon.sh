#!/usr/bin/env bash
# Render web/public/icon.svg into a macOS AppIcon.icns.
#
# Pipeline: qlmanage rasterizes the SVG to a 1024 PNG (using QuickLook's
# SVG renderer + system Devanagari font), then `sips` resizes that to all
# macOS icon-set sizes, and `iconutil` bundles them into AppIcon.icns.
#
# Output: app/AppIcon.icns (committed; rebuild after editing icon.svg).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SVG="$ROOT/../web/public/icon.svg"
WORK="$ROOT/build/icon-work"
ICONSET="$WORK/AppIcon.iconset"
ICNS_OUT="$ROOT/AppIcon.icns"

[ -f "$SVG" ] || { echo "✗ source SVG not found: $SVG"; exit 1; }

rm -rf "$WORK"
mkdir -p "$ICONSET"

echo "==> rendering SVG @ 1024…"
qlmanage -t -s 1024 -o "$WORK" "$SVG" >/dev/null 2>&1
SRC_PNG="$WORK/$(basename "$SVG").png"
[ -f "$SRC_PNG" ] || { echo "✗ qlmanage did not produce a PNG"; exit 1; }

# macOS .iconset requires both @1x and @2x. Map each logical size to
# the actual pixel resolution we need to produce.
#
#   logical_size  filename                pixel_size
declare -a sizes=(
    "16   icon_16x16.png        16"
    "16   icon_16x16@2x.png     32"
    "32   icon_32x32.png        32"
    "32   icon_32x32@2x.png     64"
    "128  icon_128x128.png      128"
    "128  icon_128x128@2x.png   256"
    "256  icon_256x256.png      256"
    "256  icon_256x256@2x.png   512"
    "512  icon_512x512.png      512"
    "512  icon_512x512@2x.png   1024"
)

echo "==> resizing to iconset…"
for entry in "${sizes[@]}"; do
    read -r _ filename px <<< "$entry"
    sips -z "$px" "$px" "$SRC_PNG" --out "$ICONSET/$filename" >/dev/null
done

echo "==> packaging AppIcon.icns…"
iconutil -c icns "$ICONSET" -o "$ICNS_OUT"

# Cleanup intermediate work — keep the .iconset folder briefly handy
# for debugging by leaving it in build/.
rm -f "$SRC_PNG"

echo "✓ wrote $ICNS_OUT"
ls -lh "$ICNS_OUT" | awk '{print "  " $5 "  " $9}'
