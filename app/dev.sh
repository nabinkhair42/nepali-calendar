#!/usr/bin/env bash
# Watch Sources/ and rebuild + relaunch NepaliCalendar on every save.
# Pure shell — no fswatch / entr / Xcode required.
#
#   ./dev.sh
#
# Press Ctrl-C to quit. The running app instance is killed on exit.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

APP_PID=""

cleanup() {
    if [ -n "$APP_PID" ] && kill -0 "$APP_PID" 2>/dev/null; then
        kill "$APP_PID" 2>/dev/null || true
    fi
    pkill -f ".build/.*/debug/NepaliCalendar" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

snapshot() {
    # mtime sum of every Swift source — cheap fingerprint.
    find Sources -type f -name '*.swift' -exec stat -f '%m' {} \; \
        | awk '{s+=$1} END {print s}'
}

rebuild_and_launch() {
    echo
    echo "==> $(date +%H:%M:%S) rebuilding…"
    if swift build -c debug 2>&1; then
        if [ -n "$APP_PID" ] && kill -0 "$APP_PID" 2>/dev/null; then
            kill "$APP_PID" 2>/dev/null || true
            wait "$APP_PID" 2>/dev/null || true
        fi
        echo "==> launching"
        ./.build/debug/NepaliCalendar &
        APP_PID=$!
        echo "==> running (pid $APP_PID) — look at your menu bar"
    else
        echo "==> build failed; keeping previous instance running"
    fi
}

echo "Watching $ROOT/Sources for changes. Ctrl-C to stop."
rebuild_and_launch
LAST=$(snapshot)

while true; do
    sleep 1
    NOW=$(snapshot)
    if [ "$NOW" != "$LAST" ]; then
        LAST=$NOW
        rebuild_and_launch
    fi
done
