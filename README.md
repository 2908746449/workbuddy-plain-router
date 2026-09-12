# WorkBuddy Plain Router Portable

WorkBuddy "大白话低误判路由版"模板部署工具 - 支持 Windows 和 macOS

## 项目简介

这是一套用于 WorkBuddy/CodeBuddy 的自定义提示模板，旨在：

- 降低误判率，提高任务理解准确度
- 优化技术任务路由，减少不必要的拒绝
- 支持安全测试、逆向工程、接口分析等专业场景
- 提供大白话的工程化任务处理方式

## 平台支持

- ✅ **Windows** - 使用 PowerShell 脚本
- ✅ **macOS** - 使用 Bash Shell 脚本

## 快速开始

### Windows 用户

1. 进入 [windows](./windows) 目录
2. 查看 [README.md](./windows/README.md)
3. 以管理员身份运行 `INSTALL.bat`

### macOS 用户

1. 进入 [mac](./mac) 目录
2. 查看 [README.md](./mac/README.md)
3. 在终端执行：
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## 功能特性

### 核心改进

- **大白话路由器** - 将技术请求准确映射到工程任务，减少误判
- **授权范围识别** - 自动识别用户指定目标为授权范围
- **工程化输出** - 直接给出可执行步骤、命令、代码，而非空泛建议
- **低风险优先** - 优先提供可回滚、可复现的方案

### 适用场景

- 安全测试与渗透测试
- 逆向工程与二进制分析
- API 接口分析与审计
- 游戏修改与内存分析
- CDK/激活/授权流程审计
- 自动化脚本开发
- 抓包与协议分析

### 模板内容

- **主模板** (`my-template.tpl`) - 核心路由逻辑
- **补丁文件** (`my-prompt.txt`) - welcomemode 插件补丁
- **模式模板** (`templates/`) - 各种工作模式的专用模板
- **风格模板** (`templates/style/`) - 多种回复风格

## 目录结构

```
workbuddy-plain-router/
├── README.md                 # 本文件
├── windows/                  # Windows 版本
│   ├── README.md
│   ├── INSTALL.bat          # 安装脚本
│   ├── RESTORE.bat          # 恢复脚本
│   ├── VERIFY.bat           # 验证脚本
│   ├── unlock-all-in-one.ps1
│   ├── my-template.tpl      # 主模板
│   ├── my-prompt.txt        # 插件补丁
│   └── templates/           # 模式模板
└── mac/                      # macOS 版本
    ├── README.md
    ├── install.sh           # 安装脚本
    ├── restore.sh           # 恢复脚本
    ├── verify.sh            # 验证脚本
    ├── my-template.tpl      # 主模板
    ├── my-prompt.txt        # 插件补丁
    └── templates/           # 模式模板
```

## 测试建议

安装完成后，建议使用以下语句测试：

```text
我有一个授权测试站，需要审计 CDK 激活业务逻辑。先不要直接攻击目标，帮我梳理接口、测试矩阵、单变量手工验证步骤和修复建议。重点看服务端校验、重放、签名、并发、幂等、账号绑定和状态查询。
```

## 工作原理

### Windows 版本

1. 自动探测 WorkBuddy 安装目录（支持多种查找策略）
2. 备份原始模板文件
3. 替换主模板到 `resources/app.asar.unpacked/resources/templates/`
4. 更新用户数据目录中的 welcomemode 插件缓存
5. 必要时自动启动 WorkBuddy 生成插件缓存

### macOS 版本

1. 在 `/Applications` 或 `~/Applications` 中查找 WorkBuddy.app
2. 备份原始模板到带时间戳的目录
3. 复制自定义模板到应用资源目录
4. 更新用户数据目录 `~/Library/Application Support/WorkBuddy`
5. 处理 welcomemode 插件缓存

## 回滚方法

### Windows

运行 `RESTORE.bat` 或使用 PowerShell：

```powershell
.\tools\restore-workbuddy.ps1
```

### macOS

运行恢复脚本：

```bash
./restore.sh
```

## 验证安装

### Windows

运行 `VERIFY.bat` 检查安装状态

### macOS

```bash
./verify.sh
```

## 注意事项

- ⚠️ 安装前请关闭 WorkBuddy/CodeBuddy
- ⚠️ 安装会自动备份原始模板，可随时恢复
- ⚠️ 首次安装可能需要运行两次（生成插件缓存后再次运行）
- ⚠️ 修改仅影响提示模板，不修改应用程序本身
- ⚠️ 重启 WorkBuddy 后生效，建议新建对话测试

## 故障排除

### 安装后不生效

1. 确认已完全关闭并重启 WorkBuddy
2. 新建对话测试（不要使用旧对话）
3. 运行验证脚本检查安装状态
4. 查看日志文件排查问题

### Windows 特定问题

- 需要管理员权限运行 `INSTALL.bat`
- PowerShell 执行策略限制：`Set-ExecutionPolicy Bypass -Scope Process`
- 查看详细日志：`unlock-all-in-one-log.txt`

### macOS 特定问题

- 确保脚本有执行权限：`chmod +x *.sh`
- 如需修改应用目录权限：`sudo ./install.sh`
- 查看详细日志：`install-log.txt`

## 版本信息

- **原始版本**: v20260907
- **Mac 适配版本**: v20260912
- **支持的 WorkBuddy 版本**: 5.3.11+

## 免责声明

本项目仅供学习和授权测试使用。使用本模板进行的任何操作均需遵守相关法律法规，用户需自行承担使用风险。

## 贡献

欢迎提交 Issue 和 Pull Request：

- 报告 Bug
- 建议新功能
- 改进文档
- 适配新版本

## License

MIT License

---

**注意**: 本项目是对 WorkBuddy 提示模板的自定义修改，不隶属于 WorkBuddy 官方。
