# SafeClaw Browser Use Skill

让 Codex / SafeClaw 接管你真正想用的 Chrome profile，而不是误开一个错误账号或干净浏览器。

我们是 SnapSnap 团队，正在开发 AI 浏览器自动化产品 SafeClaw。开发过程中，我们大量使用了 [browser-use/browser-harness](https://github.com/browser-use/browser-harness)：它能接管真实 Chrome、复用登录态，并完成截图、点击、输入和页面检查。

但在多账号场景里，我们遇到一个很具体的问题：用户本机通常有多个 Chrome profile，agent 如果直接接管浏览器，很容易用错账号，或者不清楚当前任务到底运行在哪个 profile 里。

所以我们做了 `safeclaw-browser-use`：一个基于 Browser Harness 的 Codex / SafeClaw skill，核心增强是 **profile gate**。

每次执行浏览器任务前，它会先识别本机 Chrome profiles，让用户明确选择要接管哪个 profile，然后后续所有操作都绑定到这个 profile 上。

## Setup Prompt

把下面这段话发给 Codex，让 agent 帮你安装：

```text
请帮我安装 safeclaw-browser-use skill。
在 macOS 上执行：
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash
安装完成后提醒我重启 Codex。
```

Windows 用户把这段发给 agent：

```text
请帮我安装 safeclaw-browser-use skill。
在 PowerShell 中执行：
irm https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.ps1 | iex
安装完成后提醒我重启 Codex。
```

安装后重启 Codex，让 Codex 重新加载 skill。

## Direct Install

macOS:

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.ps1 | iex
```

安装到 SafeClaw：

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --target safeclaw
```

安装到指定目录：

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --dir ~/.codex/skills
```

不要只下载 `skills/safeclaw-browser-use` 源码目录。源码目录只包含 `SKILL.md` 和元信息，不包含完整运行时。请使用 Release 安装脚本，它会下载完整 runtime 包并校验 SHA256。

## Why

很多浏览器自动化工具默认会开一个干净浏览器，或者直接接管默认浏览器。这在真实工作流里经常不够：

- 登录态没有了
- 工作号和个人号容易串
- agent 不知道当前接管的是哪个 Chrome profile
- 多个 Chrome profile 同时存在时，自动化结果不可信

`safeclaw-browser-use` 的目标很简单：让 agent 在接管真实 Chrome 前，先问清楚“这次用哪个 profile”。

## What It Adds

Browser Harness 提供底层真实浏览器接管能力。

`safeclaw-browser-use` 在它之上增加了一层更适合 agent 使用的工作流：

- 启动前读取本机 Chrome profiles
- 展示 profiles，让用户选择目标 profile
- 后续任务绑定到这个 profile
- 避免误用默认账号、个人账号或测试账号
- 内置 macOS arm64 / Windows x64 运行时
- 安装脚本自动下载 Release asset、校验 SHA256、解压到 skills 目录

一句话：

> Browser Harness 负责接管真实 Chrome；`safeclaw-browser-use` 负责让接管过程更明确、更安全、更适合多账号用户。

## What You Can Ask It To Do

选择 profile 后打开网页：

```text
使用 safeclaw-browser-use，列出我本机的 Chrome profiles，让我选择一个 profile，然后打开 https://example.com 并截图。
```

复用登录态检查后台页面：

```text
使用 safeclaw-browser-use，接管我的工作 Chrome profile，打开我已经登录的后台页面，截图并告诉我当前页面标题和主要按钮。
```

避免多账号串号：

```text
使用 safeclaw-browser-use，先让我选择 Chrome profile。不要使用默认 profile。选定后打开目标网站，确认页面上当前登录的是哪个账号。
```

执行页面操作：

```text
使用 safeclaw-browser-use，打开目标网页，在搜索框输入关键词，点击搜索，等待页面加载，然后截图并总结搜索结果。
```

做页面调试和信息提取：

```text
使用 safeclaw-browser-use，打开这个页面，检查当前 URL、页面标题、可点击按钮和主要表单字段，并输出一份简短报告。
```

## How It Works

1. 读取本机 Chrome `Local State`，找出可用 profiles。
2. 展示 profile 列表，让用户选择本次任务要使用的 profile。
3. 对选定 profile 运行 Browser Harness doctor 和 CDP 连接检查。
4. 接管真实 Chrome tab，执行导航、截图、点击、输入和页面检查。
5. 如果 Chrome 需要远程调试权限，引导用户在目标 profile 中开启。

## Health Check

macOS:

```bash
~/.codex/skills/safeclaw-browser-use/scripts/browser-harness --doctor
```

Windows:

```powershell
~\.codex\skills\safeclaw-browser-use\scripts\browser-harness.cmd --doctor
```

如果 doctor 提示需要打开 Chrome 远程调试权限，按照提示在目标 Chrome profile 里开启即可。

## Platforms

当前 Release 包支持：

- macOS arm64
- Windows x64

Linux 暂未打包。

## Release Package

完整运行时不直接提交到 git，而是放在 GitHub Release 里：

```text
safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz
```

Release asset 包含：

- `SKILL.md`
- `skill.json`
- macOS / Windows launcher
- macOS arm64 runtime
- Windows x64 runtime

## License

免费用于个人、学习、研究、评估和其他非商业用途。

未经事先书面许可，不允许商用，包括但不限于：

- 用于收费产品或服务
- 集成到商业 SaaS / 工具 / 自动化服务
- 公司内部生产业务使用
- 转售、二次打包或作为商业交付的一部分

详见 [`LICENSE`](LICENSE)。

