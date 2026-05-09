#!/usr/bin/env bash
# Nepali Calendar — one-command installer.
#
# Usage:
#   curl -fsSL https://calendar.nabinkhair.com.np/install.sh | bash
#
# What it does:
#   1. Downloads the latest .dmg
#   2. Mounts it
#   3. Copies Nepali Calendar.app into /Applications
#   4. Removes the macOS quarantine attribute so Gatekeeper won't block
#      first launch (the build is ad-hoc signed, not Developer-ID signed)
#   5. Detaches the disk image and cleans up
#   6. Optionally launches the app
#
# Safe to re-run — it overwrites any existing /Applications/Nepali Calendar.app.

set -euo pipefail

DMG_URL="${NEPALI_CALENDAR_DMG_URL:-https://calendar.nabinkhair.com.np/downloads/NepaliCalendar.dmg}"
APP_NAME="NepaliCalendar.app"
APP_DISPLAY="Nepali Calendar"
APPLICATIONS_DIR="/Applications"

cyan()   { printf "\033[36m%s\033[0m" "$1"; }
green()  { printf "\033[32m%s\033[0m" "$1"; }
red()    { printf "\033[31m%s\033[0m" "$1"; }
gray()   { printf "\033[2m%s\033[0m"  "$1"; }
say()    { printf "%s %s\n" "$(cyan '→')"  "$1"; }
ok()     { printf "%s %s\n" "$(green '✓')" "$1"; }
fail()   { printf "%s %s\n" "$(red   '✗')" "$1" >&2; exit 1; }

# Sanity: only macOS.
[ "$(uname)" = "Darwin" ] || fail "Nepali Calendar is macOS-only."

TMP_DIR=$(mktemp -d -t nepali-calendar)
TMP_DMG="$TMP_DIR/NepaliCalendar.dmg"
MOUNT_POINT=""

cleanup() {
    [ -n "$MOUNT_POINT" ] && hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo
echo "$(cyan 'Nepali Calendar') $(gray 'installer')"
echo

say "Downloading…"
curl -fSL --progress-bar "$DMG_URL" -o "$TMP_DMG" \
    || fail "Download failed. Check your connection or grab the .dmg manually:
   $DMG_URL"

say "Mounting disk image…"
MOUNT_POINT=$(hdiutil attach "$TMP_DMG" -nobrowse -readonly -mountrandom /tmp 2>/dev/null \
    | awk '/\/tmp\// { for (i=3; i<=NF; i++) printf "%s ", $i; print "" }' \
    | sed 's/ *$//' \
    | tail -n 1)
[ -d "$MOUNT_POINT" ] || fail "Could not mount the disk image."

[ -d "$MOUNT_POINT/$APP_NAME" ] || fail "Image did not contain '$APP_NAME'. Was the download corrupted?"

# If it's already running, quit it before overwriting — otherwise the
# Mach-O is in use and `cp -R` may produce a broken bundle.
if pgrep -f "$APP_NAME/Contents/MacOS/" >/dev/null 2>&1; then
    say "Quitting running instance…"
    osascript -e "tell application \"$APP_DISPLAY\" to quit" 2>/dev/null || true
    sleep 1
fi

say "Installing to $APPLICATIONS_DIR…"
if [ ! -w "$APPLICATIONS_DIR" ]; then
    fail "Cannot write to $APPLICATIONS_DIR. Re-run with: sudo bash …"
fi
rm -rf "$APPLICATIONS_DIR/$APP_NAME"
cp -R "$MOUNT_POINT/$APP_NAME" "$APPLICATIONS_DIR/"

# Strip the quarantine attribute so first launch doesn't trigger the
# "Apple cannot check this app for malicious software" prompt. By running
# this script you've already vouched for the source.
xattr -dr com.apple.quarantine "$APPLICATIONS_DIR/$APP_NAME" 2>/dev/null || true

ok "Installed Nepali Calendar."
echo
echo "  $(gray 'Launch with:')  open '/Applications/$APP_NAME'"
echo "  $(gray 'Or find it in') Spotlight."
echo

# Auto-launch if running in an interactive shell with a TTY available.
# Skips silently when piped from curl in a non-interactive context.
if [ -t 0 ] || [ -t 1 ]; then
    open "$APPLICATIONS_DIR/$APP_NAME" 2>/dev/null || true
fi
