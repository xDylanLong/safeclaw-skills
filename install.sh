#!/usr/bin/env bash
set -euo pipefail

REPO="xDylanLong/safeclaw-skills"
SKILL_NAME="safeclaw-browser-use"
ASSET_NAME="safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz"
TARGET="codex"
INSTALL_DIR=""
VERSION="latest"
FORCE="0"
SKIP_PLATFORM_CHECK="0"

usage() {
  cat <<'USAGE'
Install safeclaw-browser-use.

Usage:
  install.sh [--target codex|safeclaw] [--dir PATH] [--version TAG] [--force] [--skip-platform-check]

Options:
  --target                 Install target. Defaults to codex.
  --dir                    Install into a custom skills directory.
  --version                GitHub release tag. Defaults to latest.
  --force                  Replace an existing safeclaw-browser-use directory.
  --skip-platform-check    Download and install even on an unsupported platform.
  -h, --help               Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      if [ "$#" -lt 2 ]; then
        echo "--target requires a value." >&2
        exit 2
      fi
      TARGET="${2:-}"
      shift 2
      ;;
    --dir)
      if [ "$#" -lt 2 ]; then
        echo "--dir requires a value." >&2
        exit 2
      fi
      INSTALL_DIR="${2:-}"
      shift 2
      ;;
    --version)
      if [ "$#" -lt 2 ]; then
        echo "--version requires a value." >&2
        exit 2
      fi
      VERSION="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="1"
      shift
      ;;
    --skip-platform-check)
      SKIP_PLATFORM_CHECK="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$INSTALL_DIR" ]; then
  case "$TARGET" in
    codex)
      INSTALL_DIR="$HOME/.codex/skills"
      ;;
    safeclaw)
      INSTALL_DIR="$HOME/.safeclaw/skills"
      ;;
    *)
      echo "Unsupported --target '$TARGET'. Use codex, safeclaw, or pass --dir." >&2
      exit 2
      ;;
  esac
fi

if [ "$SKIP_PLATFORM_CHECK" != "1" ]; then
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
  case "$os-$arch" in
    darwin-arm64|darwin-aarch64)
      ;;
    *)
      echo "Unsupported platform: $os-$arch" >&2
      echo "This bundle currently supports macOS arm64. Use install.ps1 on Windows x64." >&2
      echo "Pass --skip-platform-check only if you are staging files intentionally." >&2
      exit 1
      ;;
  esac
fi

if [ "$VERSION" = "latest" ]; then
  BASE_URL="https://github.com/$REPO/releases/latest/download"
else
  BASE_URL="https://github.com/$REPO/releases/download/$VERSION"
fi
BASE_URL="${SAFECLAW_SKILLS_BASE_URL:-$BASE_URL}"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

archive="$tmp_dir/$ASSET_NAME"
checksum_file="$tmp_dir/$ASSET_NAME.sha256"

curl_args=(-fsSL --retry 3 --retry-delay 2)
if [ -n "${GITHUB_TOKEN:-}" ]; then
  curl_args+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

echo "Downloading $ASSET_NAME from $REPO..."
curl "${curl_args[@]}" "$BASE_URL/$ASSET_NAME" -o "$archive"
curl "${curl_args[@]}" "$BASE_URL/$ASSET_NAME.sha256" -o "$checksum_file"

expected="$(awk '{print tolower($1)}' "$checksum_file")"
if command -v shasum >/dev/null 2>&1; then
  actual="$(shasum -a 256 "$archive" | awk '{print tolower($1)}')"
elif command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$archive" | awk '{print tolower($1)}')"
else
  echo "Cannot find shasum or sha256sum for checksum verification." >&2
  exit 1
fi

if [ "$expected" != "$actual" ]; then
  echo "Checksum mismatch for $ASSET_NAME" >&2
  echo "Expected: $expected" >&2
  echo "Actual:   $actual" >&2
  exit 1
fi

extract_dir="$tmp_dir/extract"
mkdir -p "$extract_dir"
tar -xzf "$archive" -C "$extract_dir"

if [ ! -f "$extract_dir/$SKILL_NAME/SKILL.md" ]; then
  echo "Archive does not contain $SKILL_NAME/SKILL.md" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
dest="$INSTALL_DIR/$SKILL_NAME"
if [ -e "$dest" ]; then
  if [ "$FORCE" = "1" ]; then
    rm -rf "$dest"
  else
    echo "$dest already exists. Re-run with --force to replace it." >&2
    exit 1
  fi
fi

mv "$extract_dir/$SKILL_NAME" "$dest"

echo "Installed $SKILL_NAME to $dest"
echo "Run doctor:"
echo "  $dest/scripts/browser-harness --doctor"
if [ "$TARGET" = "codex" ]; then
  echo "Restart Codex to pick up new skills."
fi
