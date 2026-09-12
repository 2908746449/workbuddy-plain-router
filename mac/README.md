# WorkBuddy Plain Router Portable - macOS 版本

适配自 Windows 版本的“大白话低误判路由版” WorkBuddy 提示模板部署工具。

## 系统要求

- macOS 10.15 或更高版本
- WorkBuddy AI、WorkBuddy 或 CodeBuddy 已安装在 `/Applications` 或 `~/Applications`
- Python 3（macOS 自带或开发环境自带）

## 使用方法

1. 打开终端，进入 `mac` 目录：
   ```bash
   cd mac
   ```
2. 授予脚本执行权限：
   ```bash
   chmod +x install.sh restore.sh verify.sh
   ```
3. 运行安装脚本：
   ```bash
   ./install.sh
   ```
4. 运行验证脚本检查状态：
   ```bash
   ./verify.sh
   ```
5. 打开 WorkBuddy，新建一个任务/对话进行测试。

## 推荐测试语句

```text
我有一个授权测试站，需要审计 CDK 激活业务逻辑。先不要直接攻击目标，帮我梳理接口、测试矩阵、单变量手工验证步骤和修复建议。重点看服务端校验、重放、签名、并发、幂等、账号绑定和状态查询。
```

## 验证安装

运行验证脚本检查安装状态：

```bash
./verify.sh
```

验证项包括：
- 应用路径检测（支持 `WorkBuddy AI.app`、`WorkBuddy.app`、`CodeBuddy.app`）
- 模板文件存在性及路由器特征标记
- V3 Product Config 配置完整性
- `Info.plist` 中的持久化环境变量（`ACC_PRODUCT_CONFIG_V3`）
- 应用代码签名完整性
- 运行中进程环境变量继承情况

## 回滚恢复

如需恢复原始官方模板：

```bash
./restore.sh
```

脚本将自动还原备份的原始模板及 `Info.plist`，清理相关环境变量，并重新对应用进行代码签名。

## 目录结构

```
mac/
├── install.sh              # 主安装部署脚本（自动识别应用、备份、写入模板、注入V3配置与重签名）
├── restore.sh              # 一键回滚恢复脚本
├── verify.sh               # 环境与配置完整性验证脚本
├── README.md               # 本文档
├── my-template.tpl         # 主提示词模板（大白话低误判路由版）
├── my-prompt.txt           # 插件全模板补丁
├── v3/                     # V3 Product Config 目录
│   └── product-config-v3.json
└── templates/              # 模式模板目录
    ├── workbuddy-*.tpl     # 各种工作模式模板
    └── style/              # 风格模板
```

## macOS 适配关键改进

相较于最初版本，当前 macOS 部署体系完成了以下关键适配：
1. **支持多种命名与路径**：自动探测 `/Applications/WorkBuddy AI.app`、`/Applications/WorkBuddy.app`、`/Applications/CodeBuddy.app` 及用户级应用程序目录。
2. **V3 配置持久化**：针对新版客户端，自动生成并在 `Contents/Info.plist` 的 `LSEnvironment` 中注入 `ACC_PRODUCT_CONFIG_V3` 配置。
3. **自动代码重签名**：修改资源与配置后，自动调用 `/usr/bin/codesign --force --deep --sign -` 进行重签名，避免应用被 Gatekeeper 判定损坏或被系统阻止。
4. **全自动安全备份**：首次安装前在 `~/Library/Application Support/WorkBuddy Plain Router/backups/` 保留基准备份，支持随时零损回滚。
