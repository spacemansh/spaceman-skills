# Spaceman Skills

Small, composable skills for coding agents that support the
[Agent Skills](https://agentskills.io/) format.

## Install

**One command. Finds the agents on your machine. Installs for each.**

```sh
# macOS · Linux · WSL · Git Bash
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash
```

```powershell
# Windows · PowerShell 5.1+
irm https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.ps1 | iex
```

Needs Node.js 22 or newer. Safe to re-run.

Or use the skills CLI directly:

```sh
npx skills add spacemansh/spaceman-skills
```

<details>
<summary><strong>Install one skill, pick your agents, or use the CLI directly</strong></summary>

<br>

Piped through `curl` there is no terminal to prompt at, so the installer picks
every skill and every detected agent for you. Pass `--skill` or `--agent` to
narrow it; whatever you pass wins:

```sh
# just the auto-commit skill
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash -s -- --skill auto-commit

# one agent
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash -s -- --agent claude-code

# see what is in here, install nothing
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash -s -- --list

# print the command that would run, install nothing
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | DRY_RUN=1 bash
```

Run `bash install.sh` from a clone and it stays interactive, letting the CLI
prompt for skills and agents. Installs are project-scoped by default; add
`--global` for user level.

`iex` cannot pass arguments, so on PowerShell run the script as a scriptblock:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.ps1))) --skill auto-commit
```

Or skip the installers and call the CLI yourself:

```sh
npx skills@latest add spacemansh/spaceman-skills
npx skills@latest add spacemansh/spaceman-skills --skill auto-commit
```

Useful flags: `--skill <name>` and `--agent <name>` both take `*`, `--global`
installs at user level instead of per project, `--list` shows what is available,
`--yes` skips every prompt.

</details>

## Skills

- [`auto-commit`](./skills/git/auto-commit/SKILL.md) — split a dirty working tree
  into clean Conventional Commits, with no agent attribution.
- [`create-pr`](./skills/git/create-pr/SKILL.md) — publish finished work as a pull
  request that is ready for review, with the checks run first.
- [`draft-pr`](./skills/git/draft-pr/SKILL.md) — publish local work as a clean draft
  pull request with the `gh` CLI, and verify it on the remote.
- [`resolve-merge-conflicts`](./skills/git/resolve-merge-conflicts/SKILL.md) — finish
  a conflicted merge or rebase without inventing behaviour or losing work.

## Development

List the skills in this repository:

```sh
npm run skills:list
```

Validate them:

```sh
npm run validate
```

Link them into `~/.agents/skills` for local development:

```sh
npm run skills:link
```

Create a release changeset:

```sh
npm run changeset
```
