# safeclaw-browser-use

SafeClaw browser automation entrypoint with bundled Browser Harness runtime.

License: free for non-commercial use only. Commercial use is not permitted
without prior written permission. See [`../../LICENSE`](../../LICENSE).

This source directory contains the skill definition files:

```text
SKILL.md
skill.json
```

The full installable package is distributed as a GitHub Release asset:

```text
safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz
```

Install from the repository release instead of installing this source directory directly, because the release archive includes the platform runtime directories required by the launchers.

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash
```

Windows:

```powershell
irm https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.ps1 | iex
```
