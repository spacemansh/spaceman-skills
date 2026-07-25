#!/usr/bin/env bash
# spaceman-skills installer — macOS, Linux, WSL, Git Bash.
#
#   curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash
#
# Flags are forwarded to the skills CLI, so anything it accepts works here:
#
#   ... | bash -s -- --skill auto-commit          # one skill
#   ... | bash -s -- --agent '*' --yes            # every detected agent, no prompts
#   ... | bash -s -- --list                       # list skills, install nothing
#
# This is a thin wrapper around the skills CLI (https://skills.sh), which owns
# agent detection and installation. Keeping the logic there means this script
# and install.ps1 cannot drift apart.

set -euo pipefail

repo="spacemansh/spaceman-skills"

if ! command -v node >/dev/null 2>&1; then
  echo "spaceman-skills: Node.js is required." >&2
  echo "  macOS: brew install node" >&2
  echo "  other: https://nodejs.org" >&2
  exit 1
fi

node_major="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$node_major" -lt 22 ]; then
  echo "spaceman-skills: warning: Node $node_major found, but the skills CLI expects Node 22 or newer." >&2
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "spaceman-skills: npx is required. It ships with Node.js — reinstall Node." >&2
  exit 1
fi

args=("$@")

# Under `curl | bash`, stdin is the script itself, so the CLI's agent picker has
# nothing to read from. Hand it the terminal when there is one; otherwise skip
# the prompts entirely so the install cannot hang.
if [ ! -t 0 ]; then
  if [ -r /dev/tty ]; then
    exec </dev/tty
  else
    args+=(--yes)
  fi
fi

exec npx -y skills@latest add "$repo" ${args[@]+"${args[@]}"}
