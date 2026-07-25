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

<details>
<summary><strong>Install one skill, pick your agents, or use the CLI directly</strong></summary>

<br>

Both installers forward their flags to the [skills CLI](https://skills.sh/docs/cli),
so anything it accepts works:

```sh
# just the auto-commit skill
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash -s -- --skill auto-commit

# every detected agent, no prompts
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash -s -- --agent '*' --yes

# see what is in here, install nothing
curl -fsSL https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/install.sh | bash -s -- --list
```

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

- [`auto-commit`](./skills/auto-commit/SKILL.md) — split a dirty working tree
  into clean Conventional Commits, with no agent attribution.

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
