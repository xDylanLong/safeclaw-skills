# SafeClaw Browser Use Skill

我们是 SnapSnap 团队，正在开发一个 AI 浏览器自动化产品 SafeClaw。

在开发过程中，我们大量使用了 [browser-use/browser-harness](https://github.com/browser-use/browser-harness)。它可以接管真实 Chrome，复用登录态，并完成截图、点击、输入和页面检查，是一个非常实用的底层能力。

但我们发现一个实际问题：当用户本机有多个 Chrome profile 时，agent 很容易接管错账号，或者不清楚当前自动化到底运行在哪个 profile 里。

所以我们做了这个 skill：`safeclaw-browser-use`。

它基于 Browser Harness 打包，并强化了 Chrome profile 选择流程。每次执行浏览器任务前，skill 会先识别本机 Chrome profiles，让用户明确选择要接管哪个 profile，然后后续所有浏览器操作都绑定到这个 profile 上。

我们把这套能力整理成 Codex / SafeClaw 可安装的 skill，并开放出来给大家免费非商用使用。

## 它是什么

`safeclaw-browser-use` 是一个浏览器自动化 skill，用来让 agent 使用用户真实 Chrome 环境完成网页任务。

它可以做：

- 打开真实 Chrome
- 复用已登录账号
- 选择指定 Chrome profile
- 打开网页
- 截图
- 点击、输入、提交表单
- 检查页面信息

## 相比 Browser Harness 增强了什么

Browser Harness 提供的是底层真实浏览器接管能力。

这个 skill 在它之上增加了一层更适合 agent 使用的工作流：

- 启动前先检测本机 Chrome profiles
- 让用户明确选择目标 profile
- 后续任务绑定到这个 profile
- 避免误用默认账号或其他账号
- 内置 macOS arm64 / Windows x64 运行时，降低安装门槛

核心改进可以概括为一句话：

> Browser Harness 负责接管真实 Chrome；`safeclaw-browser-use` 负责让接管过程更明确、更安全、更适合多账号用户。

## 解决什么问题

如果没有明确的 profile 选择流程，浏览器自动化很容易遇到这些问题：

- 登录态没有了
- 账号 profile 用错了
- 多个 Chrome profile 之间容易串
- 自动化脚本看起来能跑，但实际不是用户正在使用的浏览器环境

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

## 让 agent 帮你安装

如果你正在使用 Codex，可以直接把下面这段话发给 agent：

```text
请帮我安装 safeclaw-browser-use skill。
在 macOS 上执行：
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash
安装完成后提醒我重启 Codex。
```

Windows 可以发：

```text
请帮我安装 safeclaw-browser-use skill。
在 PowerShell 中执行：
irm https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.ps1 | iex
安装完成后提醒我重启 Codex。
```

如果你想安装到指定目录，可以让 agent 执行：

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --dir ~/.codex/skills
```

注意：不建议只让 agent 从 GitHub 拉取 `skills/safeclaw-browser-use` 源码目录，因为源码目录只包含 `SKILL.md` 和元信息，不包含完整运行时。正确方式是使用 Release 里的安装脚本，它会下载完整 runtime 包并校验 SHA256。

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

## 功能演示

### 1. 选择 Chrome profile 后打开网页

```text
使用 safeclaw-browser-use，列出我本机的 Chrome profiles，让我选择一个 profile，然后打开 https://example.com 并截图。
```

适合展示 profile gate：agent 会先找 profiles，再让用户确认要接管哪个账号环境。

### 2. 复用登录态检查后台页面

```text
使用 safeclaw-browser-use，接管我的工作 Chrome profile，打开我已经登录的后台页面，截图并告诉我当前页面标题和主要按钮。
```

适合展示它不是开一个干净浏览器，而是复用真实 Chrome 登录态。

### 3. 多账号场景避免串号

```text
使用 safeclaw-browser-use，先让我选择 Chrome profile。不要使用默认 profile。选定后打开目标网站，确认页面上当前登录的是哪个账号。
```

适合展示相比直接 Browser Harness 调用，多了一步明确的用户确认，减少误接管账号。

### 4. 页面操作和验证

```text
使用 safeclaw-browser-use，打开目标网页，在搜索框输入关键词，点击搜索，等待页面加载，然后截图并总结搜索结果。
```

适合展示截图、点击、输入、等待加载和结果检查。

### 5. 页面调试和信息提取

```text
使用 safeclaw-browser-use，打开这个页面，检查当前 URL、页面标题、可点击按钮和主要表单字段，并输出一份简短报告。
```

适合展示基于真实页面状态的 CDP 检查能力。

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
