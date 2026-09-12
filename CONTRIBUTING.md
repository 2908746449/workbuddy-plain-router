# 贡献指南

感谢你对 WorkBuddy Plain Router 项目的关注！

## 如何贡献

### 报告问题

如果你发现了 Bug 或有功能建议，请：

1. 先搜索 [Issues](../../issues) 确认问题未被报告
2. 创建新 Issue，提供：
   - 操作系统版本（Windows/macOS）
   - WorkBuddy 版本
   - 详细的复现步骤
   - 预期行为和实际行为
   - 相关日志（如有）

### 提交代码

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m 'Add some feature'`
4. 推送到分支：`git push origin feature/your-feature`
5. 提交 Pull Request

### 开发规范

#### Windows 脚本 (PowerShell)

- 使用 UTF-16LE 编码（与原版保持一致）
- 兼容 PowerShell 2.0+
- 添加详细的日志输出
- 处理错误并提供友好提示

#### macOS 脚本 (Bash)

- 使用 UTF-8 编码
- 兼容 macOS 10.13+
- 遵循 POSIX 标准
- 添加错误处理

#### 模板文件

- 保持 `.tpl` 文件的结构完整性
- 测试前后兼容性
- 文档化所有重要修改

### 测试

提交 PR 前请确保：

- [ ] 在目标平台上完整测试
- [ ] 验证脚本运行验证通过
- [ ] 恢复脚本能正确回滚
- [ ] 更新相关文档

## 开发环境

### Windows

- Windows 7+ / PowerShell 2.0+
- WorkBuddy/CodeBuddy 5.3.11+

### macOS

- macOS 10.13+
- Bash 3.2+
- WorkBuddy/CodeBuddy 5.3.11+

## 项目结构

```
workbuddy-plain-router/
├── windows/              # Windows 版本
│   ├── unlock-all-in-one.ps1  # 主部署脚本
│   ├── tools/                 # 工具脚本
│   ├── templates/             # 模板文件
│   └── *.bat                  # 批处理入口
└── mac/                  # macOS 版本
    ├── install.sh             # 安装脚本
    ├── restore.sh             # 恢复脚本
    ├── verify.sh              # 验证脚本
    └── templates/             # 模板文件
```

## 待改进的方向

- [ ] 支持 Linux 平台
- [ ] 支持更多 WorkBuddy 版本
- [ ] 添加自动化测试
- [ ] 提供 GUI 安装界面
- [ ] 模板热重载功能
- [ ] 配置文件管理

## 问题讨论

欢迎在 [Discussions](../../discussions) 中：

- 分享使用经验
- 讨论改进建议
- 提出新功能想法
- 帮助其他用户

## 行为准则

请遵守基本的开源社区行为准则：

- 尊重所有贡献者
- 提供建设性的反馈
- 专注于项目目标
- 欢迎新手参与

---

再次感谢你的贡献！🎉
