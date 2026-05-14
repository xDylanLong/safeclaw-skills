# SafeClaw Skills

SafeClaw 可复用 skill 的公开分发仓库。

License: free for non-commercial use only. Commercial use is not permitted
without prior written permission. See [`LICENSE`](LICENSE).

当前第一个 skill 是 `safeclaw-browser-use`：内置 Browser Harness 运行时，用于在 macOS arm64 和 Windows x64 上接管真实 Chrome，复用登录态并完成截图、点击、表单填写和 CDP 页面检查。

## Skills

| Skill | Version | Platforms | Source | Release asset |
| --- | --- | --- | --- | --- |
| `safeclaw-browser-use` | `0.13.0` | `darwin-arm64`, `win32-x64` | [`skills/safeclaw-browser-use`](skills/safeclaw-browser-use) | `safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz` |

## License

This repository is free for personal, educational, research, evaluation, and
other non-commercial use. Commercial use is prohibited unless you receive prior
written permission from the copyright holder.

This is a source-available, non-commercial license, not an OSI-approved open
source license.

## Install

推荐从 GitHub Release 安装。源码仓库保留 `SKILL.md` 和元信息，完整 runtime 作为 Release asset 分发，避免把 50MB+ 二进制 runtime 直接塞进 git 或 npm 包。

Codex:

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash
```

SafeClaw:

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --target safeclaw
```

Windows PowerShell:

```powershell
irm https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.ps1 | iex
```

Custom directory:

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --dir ~/.codex/skills
```

After installing into Codex, restart Codex to pick up the new skill.

## Distribution Model

This repository uses a two-track distribution model:

1. GitHub is the source of truth for source files, docs, install scripts, checksum files, and release notes.
2. GitHub Releases host the bundled skill archive:
   `safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz`.
3. A future npm package should stay as a lightweight installer:

```bash
npx @safeclaw/browser-use-skill install --target codex
npx @safeclaw/browser-use-skill install --target safeclaw
```

The npm package should detect the platform, download the matching GitHub Release asset, verify SHA256, and unpack into the selected skill directory. It should not embed the full runtime payload.

## Release Assets

Attach these files to each GitHub Release:

```text
safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz
safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz.sha256
install.sh
install.ps1
```

Current checksum:

```text
a3ee61cfe548803c3e3dc1b6b5d86d39d88a6de43dcb54086365f11c734e3d78  safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz
```

The current local bundle is expected at:

```text
/Users/thawingx/SnapSnap/Tec/safeclaw-browser-use-skill/dist/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz
```

## Manual Verification

Before publishing a release:

```bash
shasum -a 256 /Users/thawingx/SnapSnap/Tec/safeclaw-browser-use-skill/dist/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz
tar -tzf /Users/thawingx/SnapSnap/Tec/safeclaw-browser-use-skill/dist/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz | sed -n '1,20p'
```

The archive should contain `safeclaw-browser-use/SKILL.md`, `safeclaw-browser-use/skill.json`, launchers under `safeclaw-browser-use/scripts/`, and bundled runtime files under `safeclaw-browser-use/runtime/`.
