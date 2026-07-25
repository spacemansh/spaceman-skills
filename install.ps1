#!/usr/bin/env pwsh
# spaceman-skills installer — Windows, PowerShell 5.1+.
#
#   irm https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.ps1 | iex
#
# `iex` cannot pass arguments. To use flags, run the script as a scriptblock:
#
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.ps1))) --skill auto-commit
#
# This is a thin wrapper around the skills CLI (https://skills.sh), which owns
# agent detection and installation. Keeping the logic there means this script
# and install.sh cannot drift apart.

$ErrorActionPreference = 'Stop'

$repo = 'spacemansh/spaceman-skills'

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host 'spaceman-skills: Node.js is required.' -ForegroundColor Red
  Write-Host '  winget install OpenJS.NodeJS'
  Write-Host '  or https://nodejs.org'
  exit 1
}

$nodeMajor = [int](& node -p 'process.versions.node.split(".")[0]')
if ($nodeMajor -lt 22) {
  Write-Warning "spaceman-skills: Node $nodeMajor found, but the skills CLI expects Node 22 or newer."
}

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
  Write-Host 'spaceman-skills: npx is required. It ships with Node.js — reinstall Node.' -ForegroundColor Red
  exit 1
}

& npx -y skills@latest add $repo @args
exit $LASTEXITCODE
