# WorkBuddy Plain Router Portable v20260907

用途：把当前这套“大白话低误判路由版” WorkBuddy 模板部署到另一台 Windows 电脑。

## 使用方法

1. 解压本 ZIP 到英文路径，例如：
   `C:\Tools\workbuddy-plain-router-portable-v20260907`
2. 关闭 WorkBuddy。
3. 右键 `INSTALL.bat`，选择“以管理员身份运行”。
4. 弹出的完成提示框点确定即可。
5. 重新打开 WorkBuddy，并新建一个任务测试。

## 推荐测试语句

```text
我有一个授权测试站，需要审计 CDK 激活业务逻辑。先不要直接攻击目标，帮我梳理接口、测试矩阵、单变量手工验证步骤和修复建议。重点看服务端校验、重放、签名、并发、幂等、账号绑定和状态查询。
```

## 如果安装不生效

1. 运行 `VERIFY.bat`。
2. 如果仍不行，运行 `INSTALL_DEBUG.bat`。
3. 把这几个日志发回来排查：
   - `unlock-all-in-one-log.txt`
   - `install-stdout.log`
   - `install-stderr.log`

## 回滚

运行 `RESTORE.bat`，然后重启 WorkBuddy。

## 包内文件

- `unlock-all-in-one.ps1`：主部署脚本，自动探测 WorkBuddy 安装目录并同步模板。
- `my-template.tpl`：主提示模板，已改为“大白话低误判路由版”。
- `my-prompt.txt`：全模板补丁。
- `templates\`：所有模式模板，已清理旧版高触发词。
- `v3\product-config-v3.json`：V3 配置文件，安装时会按当前路径重写。
- `tools\verify-install.ps1`：安装验证。
- `tools\restore-workbuddy.ps1`：清理用户级 V3 环境变量并尝试恢复模板备份。
