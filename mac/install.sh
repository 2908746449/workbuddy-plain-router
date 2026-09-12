#!/bin/bash
# WorkBuddy Plain Router - macOS Installer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER="大白话技术任务路由器"
STATE_DIR="$HOME/Library/Application Support/WorkBuddy Plain Router"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$STATE_DIR/backups/$STAMP"
CONFIG_FILE="$SCRIPT_DIR/v3/product-config-v3.json"
LEGACY_PLIST="$HOME/Library/LaunchAgents/com.workbuddy.plain-router-env.plist"

log() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
die() { printf '[FAIL] %s\n' "$*"; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "This script is designed for macOS only."

# 1. Detect WorkBuddy App
WORKBUDDY_APP="${WORKBUDDY_APP:-}"
if [ -z "$WORKBUDDY_APP" ]; then
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

[ -n "$WORKBUDDY_APP" ] && [ -d "$WORKBUDDY_APP" ] || die "WorkBuddy or CodeBuddy application not found. You can set WORKBUDDY_APP to the application bundle path."

APP_TPL="$WORKBUDDY_APP/Contents/Resources/app.asar.unpacked/resources/templates"
APP_WELCOME="$WORKBUDDY_APP/Contents/Resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/welcomemode"
APP_INFO_PLIST="$WORKBUDDY_APP/Contents/Info.plist"

[ -d "$APP_TPL" ] || die "Template directory not found at $APP_TPL (app version may be incompatible)."
[ -f "$SCRIPT_DIR/my-template.tpl" ] || die "Missing my-template.tpl in $SCRIPT_DIR"
[ -d "$SCRIPT_DIR/templates" ] || die "Missing templates directory in $SCRIPT_DIR"

echo "============================================================"
echo " WorkBuddy Plain Router - macOS Installer"
echo "============================================================"
echo "Application: $WORKBUDDY_APP"
echo "Templates:   $APP_TPL"

# Generate V3 config from my-template.tpl
mkdir -p "$SCRIPT_DIR/v3"
python3 - "$SCRIPT_DIR/my-template.tpl" "$CONFIG_FILE" <<'PY'
import json, pathlib, sys
src, dst = map(pathlib.Path, sys.argv[1:])
text = src.read_text(encoding="utf-8-sig")
dst.parent.mkdir(parents=True, exist_ok=True)
dst.write_text(json.dumps({"prompts": [{"name": "cli-agent-prompt", "template": text}]}, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
PY

# 1. Close application
log "Step 1/6: Closing application..."
APP_BUNDLE_ID=$(defaults read "$APP_INFO_PLIST" CFBundleIdentifier 2>/dev/null || echo "com.workbuddy.workbuddy-ai")
/usr/bin/osascript -e "tell application id \"$APP_BUNDLE_ID\" to quit" >/dev/null 2>&1 || true
for _ in {1..20}; do
    pgrep -f "$WORKBUDDY_APP/Contents/MacOS" >/dev/null 2>&1 || break
    sleep 0.2
done
pkill -TERM -f "$WORKBUDDY_APP/Contents/MacOS" >/dev/null 2>&1 || true
sleep 1

# 2. Backup
log "Step 2/6: Backing up baseline..."
mkdir -p "$STATE_DIR"
if grep -q "$MARKER" "$APP_TPL/workbuddy-prompt.tpl" 2>/dev/null \
   && [ -f "$STATE_DIR/latest-backup" ] \
   && [ -d "$(cat "$STATE_DIR/latest-backup")/app-templates" ]; then
    BACKUP_DIR="$(cat "$STATE_DIR/latest-backup")"
    log "  Existing baseline backup retained: $BACKUP_DIR"
else
    mkdir -p "$BACKUP_DIR/app-templates" "$BACKUP_DIR/welcome"
    cp -R "$APP_TPL/." "$BACKUP_DIR/app-templates/"
    if [ -d "$APP_WELCOME" ]; then cp -R "$APP_WELCOME/." "$BACKUP_DIR/welcome/"; fi
    if [ -f "$APP_INFO_PLIST" ]; then cp "$APP_INFO_PLIST" "$BACKUP_DIR/Info.plist"; fi
    printf '%s\n' "$BACKUP_DIR" > "$STATE_DIR/latest-backup"
    printf '%s\n' "$WORKBUDDY_APP" > "$BACKUP_DIR/app-path"
    log "  Created new backup: $BACKUP_DIR"
fi

# 3. Install template files
log "Step 3/6: Installing template resources..."
cp -R "$SCRIPT_DIR/templates/." "$APP_TPL/"
cp "$SCRIPT_DIR/my-template.tpl" "$APP_TPL/workbuddy-prompt.tpl"

# 4. Patch welcome-mode prompt copies if present
log "Step 4/6: Updating welcome-mode prompt copies..."
python3 - "$SCRIPT_DIR/my-template.tpl" "$APP_WELCOME" "$HOME" <<'PY'
import pathlib, re, sys
source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8-sig")
home = pathlib.Path(sys.argv[3])
m = re.search(r"<content_policy>.*?</content_policy>", source, re.S)
if not m:
    sys.exit(0)
block = m.group(0)
roots = [
    pathlib.Path(sys.argv[2]),
    home / ".workbuddy-ai/plugins/cache/workbuddy-builtin",
    home / ".workbuddy-ai/plugins/marketplaces/workbuddy-builtin/welcomemode",
    home / ".workbuddy/plugins/cache/workbuddy-builtin",
    home / ".workbuddy/plugins/marketplaces/workbuddy-builtin/welcomemode",
]
seen, changed = set(), 0
for root in roots:
    if not root.exists():
        continue
    for path in root.rglob("prompt.tpl"):
        if path in seen or "welcomemode" not in str(path).lower():
            continue
        seen.add(path)
        try:
            text = path.read_text(encoding="utf-8-sig")
            new, count = re.subn(r"<content_policy>.*?</content_policy>", lambda _: block, text, count=1, flags=re.S)
            if count:
                path.write_text(new, encoding="utf-8")
                changed += 1
        except Exception:
            pass
if changed:
    print(f"  Patched {changed} welcome-mode prompt file(s).")
PY

# 5. Activate V3 product config in Info.plist & launchctl
log "Step 5/6: Activating V3 configuration..."
/bin/launchctl bootout "gui/$(id -u)/com.workbuddy.plain-router-env" >/dev/null 2>&1 || true
if [ -f "$LEGACY_PLIST" ]; then mv "$LEGACY_PLIST" "$LEGACY_PLIST.disabled"; fi
/bin/launchctl unsetenv ACC_PRODUCT_CONFIG_PATH >/dev/null 2>&1 || true
/bin/launchctl setenv ACC_PRODUCT_CONFIG_V3 "$(cat "$CONFIG_FILE")"

python3 - "$APP_INFO_PLIST" "$CONFIG_FILE" <<'PY'
import pathlib, plistlib, sys
plist_path, config_path = map(pathlib.Path, sys.argv[1:])
with plist_path.open("rb") as f:
    data = plistlib.load(f)
env = data.setdefault("LSEnvironment", {})
env.pop("ACC_PRODUCT_CONFIG_PATH", None)
env["ACC_PRODUCT_CONFIG_V3"] = config_path.read_text(encoding="utf-8")
with plist_path.open("wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_XML, sort_keys=False)
PY
plutil -lint "$APP_INFO_PLIST" >/dev/null

# 6. Re-sign and verify
log "Step 6/6: Re-signing and verifying application..."
/usr/bin/codesign --force --deep --sign - "$WORKBUDDY_APP" >/dev/null
/usr/bin/codesign --verify --deep --strict "$WORKBUDDY_APP"

grep -q "$MARKER" "$APP_TPL/workbuddy-prompt.tpl" || die "Installed marker verification failed."
plutil -extract LSEnvironment.ACC_PRODUCT_CONFIG_V3 raw -o - "$APP_INFO_PLIST" | grep -q "$MARKER" || die "Persistent Info.plist configuration verification failed."

echo "============================================================"
echo "[SUCCESS] WorkBuddy Plain Router deployed successfully!"
echo "Backup location: $BACKUP_DIR"
echo "You can now launch WorkBuddy and start a new task to test."
echo "============================================================"
