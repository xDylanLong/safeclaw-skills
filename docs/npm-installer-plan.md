# npm Installer Plan

The npm package should be a small installer, not the runtime payload.

Package name:

```text
@safeclaw/browser-use-skill
```

Expected CLI:

```bash
npx @safeclaw/browser-use-skill install --target codex
npx @safeclaw/browser-use-skill install --target safeclaw
npx @safeclaw/browser-use-skill install --dir ~/.codex/skills
```

Responsibilities:

1. Detect platform: `darwin-arm64` or `win32-x64`.
2. Resolve the matching GitHub Release asset.
3. Download the `.tar.gz` and `.sha256` files.
4. Verify SHA256 before extraction.
5. Extract the archive into the selected skill directory.
6. Refuse to overwrite an existing install unless `--force` is passed.

The npm package should not embed `runtime/`, Python, Browser Harness wheels, or platform binaries. Keeping the package small makes installs faster and avoids forcing every user to download every platform runtime.

