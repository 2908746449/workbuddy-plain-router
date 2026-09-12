#!/bin/bash
# WorkBuddy 恢复脚本 - Mac版本

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/restore-log.txt"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

show_msg() {
    osascript -e "display dialog \"$2\" with title \"$1\" buttons {\"确定\"} default button 1"
}

log "==== WorkBuddy 恢复开始 ===="

# 查找 WorkBuddy.app
WORKBUDDY_APP=""
POSSIBLE_PATHS=(
    "/Applications/WorkBuddy.app"
    "$HOME/Applications/WorkBuddy.app"
    "/Applications/CodeBuddy.app"
    "$HOME/Applications/CodeBuddy.app"
)

for app_path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$app_path" ]; then
        WORKBUDDY_APP="$app_path"
        log "找到应用: $WORKBUDDY_APP"
        break
    fi
done

if [ -z "$WORKBUDDY_APP" ]; then
    log "ERROR: 未找到 WorkBuddy.app"
    show_msg "恢复失败" "未找到 WorkBuddy.app"
    exit 1
fi

RESOURCES_DIR="$WORKBUDDY_APP/Contents/Resources"
TEMPLATE_DIR="$RESOURCES_DIR/app.asar.unpacked/resources/templates"

# 查找最近的备份
BACKUP_ORIGINAL="$TEMPLATE_DIR.backup-original"

if [ -L "$BACKUP_ORIGINAL" ]; then
    BACKUP_DIR=$(readlink "$BACKUP_ORIGINAL")
    if [ -d "$BACKUP_DIR" ]; then
        log "找到原始备份: $BACKUP_DIR"
        log "正在恢复..."

        # 删除当前模板目录
        rm -rf "$TEMPLATE_DIR"

        # 恢复备份
        cp -r "$BACKUP_DIR" "$TEMPLATE_DIR"

        log "恢复完成"
        show_msg "恢复完成" "WorkBuddy 模板已恢复到原始状态\n请重启 WorkBuddy"
    else
        log "ERROR: 备份目录不存在: $BACKUP_DIR"
        show_msg "恢复失败" "备份目录不存在"
        exit 1
    fi
else
    log "ERROR: 未找到备份"
    show_msg "恢复失败" "未找到原始备份，可能未运行过安装脚本"
    exit 1
fi

echo ""
echo "恢复完成！详细日志: $LOG_FILE"
echo "请重启 WorkBuddy"
