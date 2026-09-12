#!/bin/bash
# WorkBuddy Plain Router - macOS Verification Script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER="大白话技术任务路由器"
CONFIG_FILE="$SCRIPT_DIR/v3/product-config-v3.json"
fail=0

check() {
    if "$@"; then
        echo "  [OK] $*"
    else
        echo "  [FAIL] $*"
        fail=1
    fi
}

echo "=== WorkBuddy Plain Router - macOS Verification ==="

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

if [ -z "$WORKBUDDY_APP" ] || [ ! -d "$WORKBUDDY_APP" ]; then
    echo "[FAIL] WorkBuddy application not found."
    exit 1
fi
echo "[INFO] Detected Application: $WORKBUDDY_APP"

APP_TPL="$WORKBUDDY_APP/Contents/Resources/app.asar.unpacked/resources/templates"
APP_INFO_PLIST="$WORKBUDDY_APP/Contents/Info.plist"

check test -d "$WORKBUDDY_APP"
check test -f "$APP_TPL/workbuddy-prompt.tpl"
check grep -q "$MARKER" "$APP_TPL/workbuddy-prompt.tpl"

if [ -f "$CONFIG_FILE" ]; then
    if python3 -m json.tool "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "  [OK] V3 config JSON is valid"
    else
        echo "  [FAIL] V3 config JSON is invalid"
        fail=1
    fi
fi

ACTIVE_PATH="$(launchctl getenv ACC_PRODUCT_CONFIG_PATH 2>/dev/null || true)"
if [ -z "$ACTIVE_PATH" ]; then
    echo "  [OK] Legacy file-mode environment is clear"
else
    echo "  [WARN] Stale file-mode environment: $ACTIVE_PATH"
fi

PLIST_JSON="$(plutil -extract LSEnvironment.ACC_PRODUCT_CONFIG_V3 raw -o - "$APP_INFO_PLIST" 2>/dev/null || true)"
if printf '%s' "$PLIST_JSON" | python3 -c 'import json,sys; x=json.load(sys.stdin); assert x["prompts"][0]["name"] == "cli-agent-prompt"; assert "大白话技术任务路由器" in x["prompts"][0]["template"]' 2>/dev/null; then
    echo "  [OK] Persistent app V3 config in Info.plist is valid and contains marker"
else
    echo "  [FAIL] Persistent app V3 config in Info.plist is missing or invalid"
    fail=1
fi

COUNT="$(grep -rl "$MARKER" "$APP_TPL" --include='*.tpl' 2>/dev/null | wc -l | tr -d ' ')"
echo "  [INFO] Installed templates containing router marker: $COUNT"

if codesign --verify --deep --strict "$WORKBUDDY_APP" 2>/dev/null; then
    echo "  [OK] Application code signature is valid"
else
    echo "  [FAIL] Application code signature verification failed"
    fail=1
fi

if pgrep -f "$WORKBUDDY_APP/Contents/MacOS" >/dev/null 2>&1; then
    PID="$(pgrep -f "$WORKBUDDY_APP/Contents/MacOS" | head -1)"
    if ps eww -p "$PID" -o command= 2>/dev/null | grep -q 'ACC_PRODUCT_CONFIG_V3={[^ ]'; then
        echo "  [OK] Running WorkBuddy process inherited V3 config"
    else
        echo "  [WARN] Running WorkBuddy process did not inherit V3 config (restart WorkBuddy to load)"
    fi
else
    echo "  [INFO] WorkBuddy is currently closed"
fi

echo ""
if [ "$fail" -eq 0 ]; then
    echo "=== All verification checks passed! ==="
else
    echo "=== Verification encountered errors ==="
fi
exit "$fail"
