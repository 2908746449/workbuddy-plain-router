#!/bin/bash
# WorkBuddy 安装验证脚本 - Mac版本

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==== WorkBuddy 安装验证 ===="
echo ""

# 查找 WorkBuddy.app
WORKBUDDY_APP=""
POSSIBLE_PATHS=(
    "/Applications/WorkBuddy.app"
    "$HOME/Applications/WorkBuddy.app"
    "/Applications/CodeBuddy.app"
    "$HOME/Applications/CodeBuddy.app"
)

echo "1. 检查 WorkBuddy 安装..."
for app_path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$app_path" ]; then
        WORKBUDDY_APP="$app_path"
        echo "   ✓ 找到: $WORKBUDDY_APP"
        break
    fi
done

if [ -z "$WORKBUDDY_APP" ]; then
    echo "   ✗ 未找到 WorkBuddy.app"
    exit 1
fi

echo ""
echo "2. 检查模板目录..."
TEMPLATE_DIR="$WORKBUDDY_APP/Contents/Resources/app.asar.unpacked/resources/templates"

if [ -d "$TEMPLATE_DIR" ]; then
    echo "   ✓ 模板目录存在: $TEMPLATE_DIR"
else
    echo "   ✗ 模板目录不存在"
    exit 1
fi

echo ""
echo "3. 检查主模板文件..."
if [ -f "$TEMPLATE_DIR/workbuddy-prompt.tpl" ]; then
    echo "   ✓ workbuddy-prompt.tpl 存在"

    # 检查是否包含特征内容
    if grep -q "大白话技术任务路由器" "$TEMPLATE_DIR/workbuddy-prompt.tpl" 2>/dev/null; then
        echo "   ✓ 已应用自定义模板（包含特征内容）"
    else
        echo "   ⚠ 文件存在但可能未应用自定义内容"
    fi
else
    echo "   ✗ workbuddy-prompt.tpl 不存在"
fi

echo ""
echo "4. 检查备份..."
if [ -L "$TEMPLATE_DIR.backup-original" ]; then
    BACKUP_DIR=$(readlink "$TEMPLATE_DIR.backup-original")
    echo "   ✓ 备份存在: $BACKUP_DIR"
else
    echo "   ⚠ 未找到备份链接"
fi

echo ""
echo "5. 检查用户数据目录..."
USER_DATA_DIR="$HOME/Library/Application Support/WorkBuddy"
if [ ! -d "$USER_DATA_DIR" ]; then
    USER_DATA_DIR="$HOME/Library/Application Support/CodeBuddy"
fi

if [ -d "$USER_DATA_DIR" ]; then
    echo "   ✓ 用户数据目录: $USER_DATA_DIR"

    PLUGIN_CACHE=$(find "$USER_DATA_DIR" -type d -name "welcomemode*" 2>/dev/null | head -1)
    if [ -n "$PLUGIN_CACHE" ]; then
        echo "   ✓ welcomemode 插件缓存: $PLUGIN_CACHE"
    else
        echo "   ⚠ 未找到 welcomemode 插件缓存（需要先打开 WorkBuddy 新建对话）"
    fi
else
    echo "   ⚠ 用户数据目录不存在"
fi

echo ""
echo "==== 验证完成 ===="
echo ""
echo "建议测试语句："
echo "我有一个授权测试站，需要审计 CDK 激活业务逻辑。先不要直接攻击目标，"
echo "帮我梳理接口、测试矩阵、单变量手工验证步骤和修复建议。"
echo ""
