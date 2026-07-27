# spaceman-skills installer — Windows, PowerShell 5.1+.
#
#   irm https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.ps1 | iex
#
# To pass flags, run the script as a scriptblock instead — `iex` cannot forward
# arguments:
#
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.ps1))) --skill auto-commit
#
# This is a thin wrapper around the skills CLI (https://skills.sh), which owns
# agent detection and installation. Keeping the logic there means this script and
# install.sh cannot drift apart.
#
# Why is everything inside a function? `irm | iex` runs this file as a string:
# $PSCommandPath is $null and a top-level param() block cannot receive arguments
# through a pipe. A function plus forwarded $args keeps one script working for
# both the pipe path and `pwsh install.ps1 --skill auto-commit`.
#
# Markers are ASCII on purpose: Windows PowerShell 5.1 consoles still run legacy
# code pages, where box-drawing and check glyphs arrive as mojibake.

function Install-SpacemanSkills {
  param([string[]]$InstallerArgs = @())

  $ErrorActionPreference = 'Stop'

  $repo = 'spacemansh/spaceman-skills'
  $cli = 'skills@latest'

  # Never named $args: inside a scriptblock or nested function that name binds to
  # that block's own arguments, not to this array.
  $cliArgs = @($InstallerArgs)

  function Write-Step { param($Message) Write-Host "  -> $Message" -ForegroundColor DarkGray }
  function Write-Ok   { param($Message) Write-Host "  ok $Message" -ForegroundColor Green }
  function Write-Warn { param($Message) Write-Host "   ! $Message" -ForegroundColor Yellow }

  function Write-Fail {
    param($Message, [string[]]$Hints = @())
    Write-Host "   x $Message" -ForegroundColor Red
    foreach ($hint in $Hints) { Write-Host "     $hint" }
  }

  # Reads $cliArgs from the enclosing scope.
  function Test-Asked {
    param([string]$Short, [string]$Long)
    return @($cliArgs | Where-Object {
      $_ -eq $Short -or $_ -eq $Long -or $_ -like "$Long=*"
    }).Count -gt 0
  }

  Write-Host 'spaceman-skills'

  if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Fail 'Node.js is required.' @(
      'winget install OpenJS.NodeJS.LTS',
      'or download from https://nodejs.org'
    )
    exit 1
  }

  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Fail 'npx is required. It ships with Node.js - reinstall Node.'
    exit 1
  }

  $nodeVersion = (& node -p 'process.versions.node').Trim()
  $nodeMajor = [int]($nodeVersion.Split('.')[0])
  if ($nodeMajor -lt 22) {
    Write-Warn "Node $nodeVersion found; the skills CLI needs Node 22 or newer."
    Write-Warn 'Upgrade with "winget upgrade OpenJS.NodeJS.LTS", or see https://nodejs.org.'
  }
  else {
    Write-Ok "Node $nodeVersion"
  }

  # When stdin is redirected the CLI's checkbox picker has nothing to read from:
  # it renders an empty list, installs nothing, and still exits 0. Make the
  # choice explicit instead of prompting for it. Anything the caller already
  # asked for wins.
  if ([Console]::IsInputRedirected -and -not (Test-Asked '-l' '--list')) {
    if (-not (Test-Asked '-s' '--skill')) { $cliArgs += @('--skill', '*') }
    if (-not (Test-Asked '-a' '--agent')) { $cliArgs += @('--agent', '*') }
    if (-not (Test-Asked '-y' '--yes'))   { $cliArgs += @('--yes') }
    Write-Step 'no terminal attached - installing every skill to every detected agent'
  }

  if ($env:DRY_RUN) {
    Write-Step 'dry run - nothing will be installed'
    Write-Host ("npx -y $cli add $repo " + ($cliArgs -join ' ')).TrimEnd()
    exit 0
  }

  Write-Step 'fetching the skills CLI'
  & npx -y $cli --version | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Fail 'could not fetch the skills CLI.' @('Check your network, then retry.')
    exit 1
  }
  Write-Ok 'skills CLI ready'

  Write-Step "installing skills from $repo"
  & npx -y $cli add $repo @cliArgs
  exit $LASTEXITCODE
}

# $args is populated when run as a file (`pwsh install.ps1 --skill auto-commit`)
# and empty under `irm | iex`.
Install-SpacemanSkills -InstallerArgs $args
