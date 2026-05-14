# Release Checklist

Use this checklist for each `safeclaw-browser-use` release.

## 1. Verify the bundle

```bash
ARCHIVE=/Users/thawingx/SnapSnap/Tec/safeclaw-browser-use-skill/dist/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz

shasum -a 256 "$ARCHIVE"
tar -tzf "$ARCHIVE" | sed -n '1,40p'
```

Confirm the archive contains:

```text
safeclaw-browser-use/SKILL.md
safeclaw-browser-use/skill.json
safeclaw-browser-use/scripts/browser-harness
safeclaw-browser-use/scripts/browser-harness.cmd
safeclaw-browser-use/runtime/darwin-arm64/...
safeclaw-browser-use/runtime/win32-x64/...
```

## 2. Update repository metadata

Update these files when the version, asset name, or checksum changes:

```text
README.md
skills.json
checksums/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz.sha256
install.sh
install.ps1
skills/safeclaw-browser-use/SKILL.md
skills/safeclaw-browser-use/skill.json
```

Confirm the release notes mention the non-commercial license:

```text
Free for non-commercial use only. Commercial use requires prior written permission.
```

## 3. Create the GitHub release

```bash
TAG=v0.13.0
ARCHIVE=/Users/thawingx/SnapSnap/Tec/safeclaw-browser-use-skill/dist/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz

gh release create "$TAG" \
  "$ARCHIVE#safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz" \
  "checksums/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz.sha256#safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz.sha256" \
  "install.sh#install.sh" \
  "install.ps1#install.ps1" \
  --repo xDylanLong/safeclaw-skills \
  --title "safeclaw-browser-use 0.13.0" \
  --notes "Initial public release of safeclaw-browser-use."
```

## 4. Smoke test install

Before publishing the GitHub Release, you can simulate the Release download locally:

```bash
TMP_ASSETS=$(mktemp -d)
cp "$ARCHIVE" "$TMP_ASSETS/"
cp checksums/safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz.sha256 "$TMP_ASSETS/"

SAFECLAW_SKILLS_BASE_URL="file://$TMP_ASSETS" \
  ./install.sh --dir /tmp/safeclaw-skills-smoke --force
```

After publishing, test the public Release URLs:

macOS:

```bash
curl -fsSL https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.sh | bash -s -- --dir /tmp/safeclaw-skills-smoke --force
/tmp/safeclaw-skills-smoke/safeclaw-browser-use/scripts/browser-harness --doctor
```

Windows PowerShell:

```powershell
irm https://github.com/xDylanLong/safeclaw-skills/releases/latest/download/install.ps1 | iex
~\.codex\skills\safeclaw-browser-use\scripts\browser-harness.cmd --doctor
```
