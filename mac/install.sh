#!/bin/bash
# WorkBuddy Plain Router Portable - Mac版本
# 适配自 Windows 版本的 unlock-all-in-one.ps1

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/install-log.txt"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

show_msg() {
    osascript -e "display dialog \"$2\" with title \"$1\" buttons {\"确定\"} default button 1"
}

log "==== WorkBuddy Mac 安装开始 ===="
log "脚本目录: $SCRIPT_DIR"

# 查找 WorkBuddy.app 路径
WORKBUDDY_APP=""
POSSIBLE_PATHS=(
    "/Applications/WorkBuddy.app"
    "$HOME/Applications/WorkBuddy.app"
    "/Applications/CodeBuddy.app"
    "$HOME/Applications/CodeBuddy.app"
)

log "---- 查找 WorkBuddy 安装位置 ----"
for app_path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$app_path" ]; then
        WORKBUDDY_APP="$app_path"
        log "找到应用: $WORKBUDDY_APP"
        break
    fi
done

if [ -z "$WORKBUDDY_APP" ]; then
    log "ERROR: 未找到 WorkBuddy.app 或 CodeBuddy.app"
    show_msg "安装失败" "未找到 WorkBuddy.app，请确认已安装 WorkBuddy"
    exit 1
fi

# 定位模板目录 (app.asar.unpacked)
RESOURCES_DIR="$WORKBUDDY_APP/Contents/Resources"
TEMPLATE_DIR="$RESOURCES_DIR/app.asar.unpacked/resources/templates"

if [ ! -d "$TEMPLATE_DIR" ]; then
    log "ERROR: 模板目录不存在: $TEMPLATE_DIR"
    show_msg "安装失败" "未找到模板目录，WorkBuddy 版本可能不兼容"
    exit 1
fi

log "模板目录: $TEMPLATE_DIR"

# 备份原始模板
BACKUP_DIR="$TEMPLATE_DIR.backup-$(date +%Y%m%d-%H%M%S)"
if [ ! -d "$TEMPLATE_DIR.backup-original" ]; then
    log "创建原始备份: $BACKUP_DIR"
    cp -r "$TEMPLATE_DIR" "$BACKUP_DIR"
    ln -s "$BACKUP_DIR" "$TEMPLATE_DIR.backup-original"
else
    log "原始备份已存在，创建本次备份: $BACKUP_DIR"
    cp -r "$TEMPLATE_DIR" "$BACKUP_DIR"
fi

# Part 1: 复制模板文件到安装目录
log "---- Part 1: 同步模板文件 ----"
if [ -d "$SCRIPT_DIR/templates" ]; then
    for tpl_file in "$SCRIPT_DIR/templates"/*.tpl; do
        if [ -f "$tpl_file" ]; then
            filename=$(basename "$tpl_file")
            log "复制: $filename"
            cp "$tpl_file" "$TEMPLATE_DIR/"
        fi
    done

    # 复制 style 子目录
    if [ -d "$SCRIPT_DIR/templates/style" ]; then
        mkdir -p "$TEMPLATE_DIR/style"
        cp "$SCRIPT_DIR/templates/style"/*.md "$TEMPLATE_DIR/style/" 2>/dev/null || true
        log "复制: style/*.md"
    fi
else
    log "ERROR: templates 目录不存在"
fi

# 复制主模板
if [ -f "$SCRIPT_DIR/my-template.tpl" ]; then
    log "复制主模板: my-template.tpl -> workbuddy-prompt.tpl"
    cp "$SCRIPT_DIR/my-template.tpl" "$TEMPLATE_DIR/workbuddy-prompt.tpl"
fi

# Part 2: 处理用户数据目录 (welcomemode 插件模板)
log "---- Part 2: 用户数据目录 ----"
USER_DATA_DIR="$HOME/Library/Application Support/WorkBuddy"
if [ ! -d "$USER_DATA_DIR" ]; then
    USER_DATA_DIR="$HOME/Library/Application Support/CodeBuddy"
fi

if [ -d "$USER_DATA_DIR" ]; then
    log "用户数据目录: $USER_DATA_DIR"

    # 查找 welcomemode 插件缓存目录
    PLUGIN_CACHE=$(find "$USER_DATA_DIR" -type d -name "welcomemode*" 2>/dev/null | head -1)

    if [ -n "$PLUGIN_CACHE" ] && [ -d "$PLUGIN_CACHE" ]; then
        log "找到 welcomemode 缓存: $PLUGIN_CACHE"

        if [ -f "$SCRIPT_DIR/my-prompt.txt" ]; then
            # 查找 prompt.tpl 文件
            PROMPT_TPL=$(find "$PLUGIN_CACHE" -name "prompt.tpl" -type f 2>/dev/null | head -1)
            if [ -n "$PROMPT_TPL" ]; then
                log "更新 prompt.tpl: $PROMPT_TPL"
                cp "$SCRIPT_DIR/my-prompt.txt" "$PROMPT_TPL"
            else
                log "WARN: 未找到 welcomemode 的 prompt.tpl"
            fi
        fi
    else
        log "WARN: 未找到 welcomemode 插件缓存（可能需要先打开 WorkBuddy 新建对话）"
    fi
else
    log "WARN: 用户数据目录不存在"
fi

# Part 3: 处理 v3 配置（如果存在）
if [ -f "$SCRIPT_DIR/v3/product-config-v3.json" ]; then
    log "---- Part 3: V3 配置 ----"
    V3_CONFIG="$SCRIPT_DIR/v3/product-config-v3.json"

    # 替换路径为 Mac 路径
    sed "s|C:\\\\Users\\\\wei\\\\Desktop\\\\workb破甲|$SCRIPT_DIR|g" "$V3_CONFIG" > "$SCRIPT_DIR/v3/product-config-v3-mac.json"
    log "已生成 Mac 版 V3 配置"
fi

log "==== 安装完成 ===="
log "备份位置: $BACKUP_DIR"
log "请重启 WorkBuddy 使更改生效"

show_msg "安装完成" "WorkBuddy 模板已更新，请重启应用使更改生效。\n\n备份位置：\n$BACKUP_DIR"

echo ""
echo "安装完成！详细日志: $LOG_FILE"
echo "备份位置: $BACKUP_DIR"
echo "请重启 WorkBuddy"
