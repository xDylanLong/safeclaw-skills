$ErrorActionPreference = "Stop"

$Repo = "xDylanLong/safeclaw-skills"
$SkillName = "safeclaw-browser-use"
$AssetName = "safeclaw-browser-use-darwin-arm64-win32-x64.tar.gz"
$Target = "codex"
$InstallDir = $null
$Version = "latest"
$Force = $false
$SkipPlatformCheck = $false

function Show-Usage {
  Write-Host @"
Install safeclaw-browser-use.

Usage:
  .\install.ps1 [--target codex|safeclaw] [--dir PATH] [--version TAG] [--force] [--skip-platform-check]

Options:
  --target                 Install target. Defaults to codex.
  --dir                    Install into a custom skills directory.
  --version                GitHub release tag. Defaults to latest.
  --force                  Replace an existing safeclaw-browser-use directory.
  --skip-platform-check    Download and install even on an unsupported platform.
  -h, --help               Show this help.
"@
}

for ($i = 0; $i -lt $args.Count; $i++) {
  switch ($args[$i]) {
    "--target" {
      if (($i + 1) -ge $args.Count) {
        throw "--target requires a value."
      }
      $i++
      $Target = $args[$i]
    }
    "--dir" {
      if (($i + 1) -ge $args.Count) {
        throw "--dir requires a value."
      }
      $i++
      $InstallDir = $args[$i]
    }
    "--version" {
      if (($i + 1) -ge $args.Count) {
        throw "--version requires a value."
      }
      $i++
      $Version = $args[$i]
    }
    "--force" {
      $Force = $true
    }
    "--skip-platform-check" {
      $SkipPlatformCheck = $true
    }
    { $_ -in @("-h", "--help") } {
      Show-Usage
      exit 0
    }
    default {
      throw "Unknown argument: $($args[$i])"
    }
  }
}

if (-not $InstallDir) {
  switch ($Target) {
    "codex" {
      $InstallDir = Join-Path $HOME ".codex\skills"
    }
    "safeclaw" {
      $InstallDir = Join-Path $HOME ".safeclaw\skills"
    }
    default {
      throw "Unsupported --target '$Target'. Use codex, safeclaw, or pass --dir."
    }
  }
}

if (-not $SkipPlatformCheck) {
  if (-not [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
    throw "Unsupported platform. Use install.sh on macOS arm64."
  }
  if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString() -ne "X64") {
    throw "Unsupported Windows architecture. This bundle currently supports Windows x64."
  }
}

if ($Version -eq "latest") {
  $BaseUrl = "https://github.com/$Repo/releases/latest/download"
} else {
  $BaseUrl = "https://github.com/$Repo/releases/download/$Version"
}
if ($env:SAFECLAW_SKILLS_BASE_URL) {
  $BaseUrl = $env:SAFECLAW_SKILLS_BASE_URL
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $TempDir | Out-Null

try {
  $Archive = Join-Path $TempDir $AssetName
  $ChecksumFile = Join-Path $TempDir "$AssetName.sha256"
  $Headers = @{}
  if ($env:GITHUB_TOKEN) {
    $Headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
  }

  Write-Host "Downloading $AssetName from $Repo..."
  Invoke-WebRequest -Uri "$BaseUrl/$AssetName" -OutFile $Archive -Headers $Headers -UseBasicParsing
  Invoke-WebRequest -Uri "$BaseUrl/$AssetName.sha256" -OutFile $ChecksumFile -Headers $Headers -UseBasicParsing

  $Expected = ((Get-Content $ChecksumFile -Raw).Trim() -split "\s+")[0].ToLowerInvariant()
  $Actual = (Get-FileHash -Algorithm SHA256 $Archive).Hash.ToLowerInvariant()
  if ($Expected -ne $Actual) {
    throw "Checksum mismatch for $AssetName. Expected $Expected, got $Actual."
  }

  $ExtractDir = Join-Path $TempDir "extract"
  New-Item -ItemType Directory -Path $ExtractDir | Out-Null
  tar -xzf $Archive -C $ExtractDir
  if ($LASTEXITCODE -ne 0) {
    throw "tar failed with exit code $LASTEXITCODE"
  }

  $ExtractedSkill = Join-Path $ExtractDir $SkillName
  if (-not (Test-Path (Join-Path $ExtractedSkill "SKILL.md"))) {
    throw "Archive does not contain $SkillName/SKILL.md"
  }

  New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
  $Dest = Join-Path $InstallDir $SkillName
  if (Test-Path $Dest) {
    if ($Force) {
      Remove-Item -Recurse -Force $Dest
    } else {
      throw "$Dest already exists. Re-run with --force to replace it."
    }
  }

  Move-Item -Path $ExtractedSkill -Destination $Dest

  Write-Host "Installed $SkillName to $Dest"
  Write-Host "Run doctor:"
  Write-Host "  $Dest\scripts\browser-harness.cmd --doctor"
  if ($Target -eq "codex") {
    Write-Host "Restart Codex to pick up new skills."
  }
} finally {
  Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
}
