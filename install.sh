#!/usr/bin/env bash
# spaceman-skills installer — macOS, Linux, WSL, Git Bash.
#
#   curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash
#
# Flags are forwarded to the skills CLI, so anything it accepts works here:
#
#   ... | bash -s -- --skill auto-commit          # one skill
#   ... | bash -s -- --agent claude-code          # one agent
#   ... | bash -s -- --list                       # list skills, install nothing
#
# This is a thin wrapper around the skills CLI (https://skills.sh), which owns
# agent detection and installation. Keeping the logic there means this script
# and install.ps1 cannot drift apart.

set -euo pipefail

repo="spacemansh/spaceman-skills"
cli="skills@latest"

# ── output ──────────────────────────────────────────────────────────────────
if [ -t 2 ] && [ -z "${NO_COLOR:-}" ]; then
  bold=$'\033[1m'; dim=$'\033[2m'; red=$'\033[31m'
  green=$'\033[32m'; yellow=$'\033[33m'; reset=$'\033[0m'
else
  bold=''; dim=''; red=''; green=''; yellow=''; reset=''
fi

step() { printf '%s→%s %s\n' "$dim" "$reset" "$1" >&2; }
ok()   { printf '%s✓%s %s\n' "$green" "$reset" "$1" >&2; }
warn() { printf '%s!%s %s\n' "$yellow" "$reset" "$1" >&2; }

die() {
  printf '%s✗%s %s\n' "$red" "$reset" "$1" >&2
  shift
  for line in "$@"; do printf '    %s\n' "$line" >&2; done
  exit 1
}

# spin <message> <command...> — run a command quietly behind a spinner. Falls
# back to a plain line when stderr is not a terminal, so piped logs stay clean.
spin() {
  local message="$1"; shift
  if [ ! -t 2 ]; then
    step "$message"
    "$@" >/dev/null 2>&1
    return $?
  fi

  "$@" >/dev/null 2>&1 &
  local pid=$! status=0 i=0
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r%s%s%s %s' "$dim" "${frames[$i]}" "$reset" "$message" >&2
    i=$(( (i + 1) % 10 ))
    sleep 0.08
  done
  wait "$pid" || status=$?
  printf '\r\033[K' >&2
  return $status
}

# has_flag <flag> <args...> — true when the caller already passed this flag.
has_flag() {
  local needle="$1"; shift
  local arg
  for arg in "$@"; do
    case "$arg" in "$needle"|"$needle"=*) return 0 ;; esac
  done
  return 1
}

printf '%sspaceman-skills%s\n' "$bold" "$reset" >&2

# ── requirements ────────────────────────────────────────────────────────────
command -v node >/dev/null 2>&1 || die \
  'Node.js is required.' \
  'macOS: brew install node' \
  'other: https://nodejs.org'

command -v npx >/dev/null 2>&1 || die \
  'npx is required. It ships with Node.js — reinstall Node.'

node_version="$(node -p 'process.versions.node')"
node_major="${node_version%%.*}"
if [ "$node_major" -lt 22 ]; then
  warn "Node $node_version found; the skills CLI needs Node 22 or newer."
  warn 'Upgrade with "brew upgrade node", or see https://nodejs.org.'
else
  ok "Node $node_version"
fi

# ── selection ───────────────────────────────────────────────────────────────
# Under `curl | bash`, stdin is the script, so the CLI's checkbox picker has
# nothing to read from: it renders an empty list, installs nothing, and still
# exits 0. Make the choice explicit instead of prompting for it. Anything the
# caller already asked for wins.
args=("$@")

if [ ! -t 0 ] && ! has_flag --list "$@" && ! has_flag -l "$@"; then
  has_flag --skill "$@" || has_flag -s "$@" || args+=(--skill '*')
  has_flag --agent "$@" || has_flag -a "$@" || args+=(--agent '*')
  has_flag --yes   "$@" || has_flag -y "$@" || args+=(--yes)
  step 'no terminal attached — installing every skill to every detected agent'
fi

# ── install ─────────────────────────────────────────────────────────────────
# DRY_RUN=1 prints the command instead of running it, so the flag handling above
# can be checked without touching any agent directory.
if [ -n "${DRY_RUN:-}" ]; then
  step 'dry run — nothing will be installed'
  printf 'npx -y %s add %s' "$cli" "$repo"
  for arg in ${args[@]+"${args[@]}"}; do printf ' %s' "$arg"; done
  printf '\n'
  exit 0
fi

# Warm the npx cache first so the download happens behind the spinner rather
# than as a silent stall, then hand the terminal to the CLI untouched.
spin 'fetching the skills CLI' npx -y "$cli" --version \
  || die 'could not fetch the skills CLI.' 'Check your network, then retry.'
ok 'skills CLI ready'

step "installing skills from $repo"
exec npx -y "$cli" add "$repo" ${args[@]+"${args[@]}"}
