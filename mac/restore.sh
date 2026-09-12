#!/bin/bash
# WorkBuddy Plain Router - macOS Restore Script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_DIR="$HOME/Library/Application Support/WorkBuddy Plain Router"
LATEST="$STATE_DIR/latest-backup"
LEGACY_PLIST="$HOME/Library/LaunchAgents/com.workbuddy.plain-router-env.plist"

log() { printf '[INFO] %s\n' "$*"; }
die() { printf '[FAIL] %s\n' "$*"; exit 1; }

[ -f "$LATEST" ] || die "No backup record found at $LATEST."
BACKUP_DIR="$(cat "$LATEST")"
[ -d "$BACKUP_DIR/app-templates" ] || die "Incomplete backup at $BACKUP_DIR."

WORKBUDDY_APP="${WORKBUDDY_APP:-}"
if [ -z "$WORKBUDDY_APP" ] && [ -f "$BACKUP_DIR/app-path" ]; then
    WORKBUDDY_APP="$(cat "$BACKUP_DIR/app-path")"
fi
if [ -z "$WORKBUDDY_APP" ] || [ ! -d "$WORKBUDDY_APP" ]; then
    POSSIBLE_PATHS=(
        "/Applications/WorkBuddy AI.app"
        "/Applications/WorkBuddy.app"
        "$HOME/Applications/WorkBuddy AI.app"
        "$HOME/Applications/WorkBuddy.app"
        "/Applications/CodeBuddy.app"
        "$HOME/Applications/CodeBuddy.app"
    )
    for app_path in "${POSSIBLE_PATHS[@]}"; do
        if [ -d "$app_path" ]; then
            WORKBUDDY_APP="$app_path"
            break
        fi
    done
fi

[ -n "$WORKBUDDY_APP" ] && [ -d "$WORKBUDDY_APP" ] || die "WorkBuddy application not found."

APP_TPL="$WORKBUDDY_APP/Contents/Resources/app.asar.unpacked/resources/templates"
APP_WELCOME="$WORKBUDDY_APP/Contents/Resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/welcomemode"
APP_INFO_PLIST="$WORKBUDDY_APP/Contents/Info.plist"

log "Closing application..."
APP_BUNDLE_ID=$(defaults read "$APP_INFO_PLIST" CFBundleIdentifier 2>/dev/null || echo "com.workbuddy.workbuddy-ai")
/usr/bin/osascript -e "tell application id \"$APP_BUNDLE_ID\" to quit" >/dev/null 2>&1 || true
sleep 1
pkill -TERM -f "$WORKBUDDY_APP/Contents/MacOS" >/dev/null 2>&1 || true

log "Restoring templates..."
cp -R "$BACKUP_DIR/app-templates/." "$APP_TPL/"
if [ -d "$BACKUP_DIR/welcome" ] && [ -d "$APP_WELCOME" ]; then
    cp -R "$BACKUP_DIR/welcome/." "$APP_WELCOME/"
fi
if [ -f "$BACKUP_DIR/Info.plist" ]; then
    cp "$BACKUP_DIR/Info.plist" "$APP_INFO_PLIST"
else
    python3 - "$APP_INFO_PLIST" <<'PY'
import pathlib, plistlib, sys
plist_path = pathlib.Path(sys.argv[1])
with plist_path.open("rb") as f:
    data = plistlib.load(f)
env = data.get("LSEnvironment", {})
env.pop("ACC_PRODUCT_CONFIG_PATH", None)
env.pop("ACC_PRODUCT_CONFIG_V3", None)
with plist_path.open("wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_XML, sort_keys=False)
PY
fi

/bin/launchctl unsetenv ACC_PRODUCT_CONFIG_PATH >/dev/null 2>&1 || true
/bin/launchctl unsetenv ACC_PRODUCT_CONFIG_V3 >/dev/null 2>&1 || true
/bin/launchctl bootout "gui/$(id -u)/com.workbuddy.plain-router-env" >/dev/null 2>&1 || true
if [ -f "$LEGACY_PLIST" ]; then mv "$LEGACY_PLIST" "$LEGACY_PLIST.disabled"; fi

log "Re-signing application..."
/usr/bin/codesign --force --deep --sign - "$WORKBUDDY_APP" >/dev/null
/usr/bin/codesign --verify --deep --strict "$WORKBUDDY_APP"

echo "============================================================"
echo "[SUCCESS] Restored original WorkBuddy configuration from: $BACKUP_DIR"
echo "============================================================"
