# Spaceman Skills

Small, composable skills for coding agents that support the
[Agent Skills](https://agentskills.io/) format.

## Install

Install all skills with [skills.sh](https://skills.sh/):

```sh
npx skills@latest add spacemansh/spaceman-skills
```

To install only the auto-commit skill:

```sh
npx skills@latest add spacemansh/spaceman-skills --skill auto-commit
```

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
