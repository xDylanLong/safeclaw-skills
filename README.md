# SafeClaw Browser Use Skill

一个给 Codex / SafeClaw 使用的浏览器自动化 skill。

它基于 [browser-use/browser-harness](https://github.com/browser-use/browser-harness) 打包，重点增强了真实 Chrome 的 profile 选择流程：在执行浏览器任务前，先识别本机 Chrome profiles，让用户明确选择要接管哪个 profile，再用这个 profile 继续完成网页打开、截图、点击、表单填写和页面检查。

## 解决什么问题

很多浏览器自动化工具默认会开一个干净浏览器，这会导致：

- 登录态没有了
- 账号 profile 用错了
- 多个 Chrome profile 之间容易串
- 自动化脚本看起来能跑，但实际不是用户正在使用的浏览器环境

`safeclaw-browser-use` 的目标是让 agent 使用用户真实 Chrome 环境，并且在接管之前先确认 profile。

## 主要特点

- 基于 Browser Harness 接管真实 Chrome
- 启动前检测并展示本机 Chrome profiles
- 要求用户选择目标 profile，避免误用默认账号
- 支持复用登录态、Cookie、已登录网站
- 支持截图、点击、输入、页面信息检查
- 内置 macOS arm64 和 Windows x64 运行时
- 不要求用户自己配置 Python 环境

## 支持平台

当前 release 包支持：

- macOS arm64
- Windows x64

Linux 暂未打包。

## 安装到 Codex

macOS:

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.ps1 | iex
```

安装后重启 Codex，让 Codex 重新加载 skill。

## 安装到 SafeClaw

macOS:

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --target safeclaw
```

也可以安装到指定目录：

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --dir ~/.codex/skills
```

## 安装后检查

macOS:

```bash
~/.codex/skills/safeclaw-browser-use/scripts/browser-harness --doctor
```

Windows:

```powershell
~\.codex\skills\safeclaw-browser-use\scripts\browser-harness.cmd --doctor
```

如果 doctor 提示需要打开 Chrome 远程调试权限，按照提示在目标 Chrome profile 里开启即可。

## 使用方式

安装后，在 Codex 里请求浏览器相关任务时，可以明确让它使用这个 skill，例如：

```text
使用 safeclaw-browser-use 打开我的 Chrome profile，帮我检查这个网页并截图。
```

skill 会先做 profile gate：

1. 读取本机 Chrome profiles
2. 展示可用 profile
3. 让用户选择本次任务要使用哪个 profile
4. 绑定该 profile 后再执行浏览器自动化

## Release 包

完整运行时不直接提交到 git，而是放在 GitHub Release 里：

```text
safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz
```

安装脚本会自动下载 release asset、校验 SHA256、解压到目标 skills 目录。

## 许可证

免费用于个人、学习、研究、评估和其他非商业用途。

未经事先书面许可，不允许商用，包括但不限于：

- 用于收费产品或服务
- 集成到商业 SaaS / 工具 / 自动化服务
- 公司内部生产业务使用
- 转售、二次打包或作为商业交付的一部分

详见 [`LICENSE`](LICENSE)。

