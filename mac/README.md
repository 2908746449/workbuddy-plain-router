# WorkBuddy Plain Router Portable - Mac 版本

适配自 Windows 版本，用于在 macOS 上部署"大白话低误判路由版" WorkBuddy 模板。

## 系统要求

- macOS 10.13 或更高版本
- WorkBuddy 或 CodeBuddy 已安装在 `/Applications` 或 `~/Applications`

## 使用方法

1. 解压本目录到任意位置（建议英文路径）
2. 关闭 WorkBuddy 应用
3. 打开终端，进入解压目录
4. 给脚本添加执行权限：
   ```bash
   chmod +x install.sh restore.sh verify.sh
   ```
5. 运行安装脚本：
   ```bash
   ./install.sh
   ```
6. 安装完成后，重启 WorkBuddy 并新建对话测试

## 推荐测试语句

```text
我有一个授权测试站，需要审计 CDK 激活业务逻辑。先不要直接攻击目标，帮我梳理接口、测试矩阵、单变量手工验证步骤和修复建议。重点看服务端校验、重放、签名、并发、幂等、账号绑定和状态查询。
```

## 验证安装

运行验证脚本检查安装状态：

```bash
./verify.sh
```

## 回滚

如需恢复原始模板：

```bash
./restore.sh
```

然后重启 WorkBuddy。

## 目录结构

```
work-mac/
├── install.sh              # 主安装脚本
├── restore.sh              # 恢复脚本
├── verify.sh               # 验证脚本
├── README.md               # 本文件
├── my-template.tpl         # 主提示模板
├── my-prompt.txt           # 全模板补丁
└── templates/              # 模式模板目录
    ├── workbuddy-*.tpl     # 各种模式模板
    └── style/              # 风格模板
```

## 工作原理

安装脚本会：

1. 自动查找 WorkBuddy.app 或 CodeBuddy.app 的安装路径
2. 备份原始模板到 `templates.backup-*` 目录
3. 将自定义模板复制到应用的资源目录：
   - 主模板：`Contents/Resources/app.asar.unpacked/resources/templates/`
4. 尝试更新用户数据目录中的 welcomemode 插件缓存
5. 完成后提示重启应用

## 故障排除

### 安装后不生效

1. 运行 `./verify.sh` 检查安装状态
2. 确认已完全关闭并重启 WorkBuddy
3. 新建一个对话测试（不要使用旧对话）
4. 查看日志文件：`install-log.txt`

### 未找到 welcomemode 缓存

这是正常的，首次安装时该缓存可能不存在。解决方法：

1. 先运行 `./install.sh`
2. 打开 WorkBuddy 新建一次对话
3. 关闭 WorkBuddy
4. 再次运行 `./install.sh`

### 权限问题

如果遇到权限错误，可能需要：

```bash
# 给脚本添加执行权限
chmod +x *.sh

# 如果修改应用目录需要权限，使用 sudo
sudo ./install.sh
```

## 与 Windows 版本的差异

- Windows 使用 PowerShell (.ps1)，Mac 使用 Bash (.sh)
- 应用路径：Windows 在 `Program Files`，Mac 在 `/Applications`
- 用户数据目录：
  - Windows: `%APPDATA%\WorkBuddy`
  - Mac: `~/Library/Application Support/WorkBuddy`
- 备份方式：Mac 使用符号链接指向原始备份

## 版本信息

- 原始版本：workbuddy-plain-router-portable v20260907
- Mac 适配版本：v20260912
- 源模板来源：Windows 版 work.zip

## 注意事项

- 安装前会自动备份原始模板
- 每次运行都会创建新的时间戳备份
- 使用 `restore.sh` 可恢复到安装前状态
- 不会修改应用本身，仅替换模板文件
