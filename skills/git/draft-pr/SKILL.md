---
name: draft-pr
description: >
  Publish local work as a clean draft pull request on GitHub using the gh CLI.
  Preflights the repository, authentication, remote, and base branch, creates a
  topic branch when needed, pushes safely, writes a real Markdown body, opens the
  pull request as a draft, then verifies it on the remote and reports the URL.
  Requires gh and stops to ask which alternative you want when gh is missing or
  unauthenticated. Adds no agent or model attribution to branch names, commits,
  titles, or bodies. Use when the user asks to open, raise, draft, or update a
  pull request, to put work up for review, or to publish a branch.
---

# Draft PR

## Overview

Turn finished local work into a draft pull request a reviewer can trust: correct
base and head, a body written for the person reviewing it, and nothing published
that the user did not ask for. The pull request is a draft unless the user asks
otherwise.

## When to Use

- User says "open a PR", "raise a PR", "draft a PR", "put this up for review",
  "publish this branch", or asks to update an existing pull request.
- User triggers `/draft-pr`.

Do not enter this workflow when the user only asked for pull request copy — a
title, a body, a description to paste. Writing the text is not permission to
create a branch, push, or mutate anything on GitHub. Write the copy and stop.

## Workflow

### 1. Preflight

Run these read-only checks before changing anything:

```sh
gh --version
gh auth status
git rev-parse --show-toplevel
git branch --show-current
git status --porcelain=v1 --untracked-files=all
git remote -v
gh repo view --json nameWithOwner,defaultBranchRef,isFork
gh pr list --head "$(git branch --show-current)" --state all --json number,url,state,isDraft
```

Establish four facts before going further: the publication remote, the base
branch, whether a pull request already exists for this head, and whether the
repository is a fork (a fork pushes to the fork and targets upstream).

Use `gh` first for GitHub operations. If it is missing or unauthenticated, abort
and ask whether the user wants to install or authenticate it themselves, or to
take another route — never install it for them and never silently switch paths.
Use a connector or a push-and-open-in-browser fallback only when the user selected
it or `gh` cannot represent the target, and only while the fallback preserves the
exact repository and head branch.

Stop and report instead of publishing when:

- the directory is not a Git repository, or has no remote to publish to;
- a merge, rebase, cherry-pick, or bisect is in progress;
- there is nothing to publish — no commits ahead of the base branch;
- the diff contains what appear to be credentials, tokens, or `.env` values.

### 2. Lock the intended diff

Decide exactly what this pull request contains before touching a branch. Preserve
unrelated work: never commit, stash away, or discard changes that do not belong
here, never widen the scope into drive-by refactors or repository-wide cleanup,
and when unrelated changes are in the way, leave them in the working tree and say
so in the final report.

If the intended work is still uncommitted, commit it with the `auto-commit` skill
rather than improvising messages here. Skills install one directory at a time, so
this one can be present without `auto-commit` beside it: read the sibling copy at
`../auto-commit/SKILL.md` when it is installed, and otherwise fetch it from
source.

```
https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/skills/git/auto-commit/SKILL.md
```

### 3. Get onto a topic branch

Never open a pull request from the base branch or push commits to it: create a
topic branch first with `git switch -c <name>`, named after the work
(`fix/token-refresh`, `feat/skill-validation`) and never after a model, agent, or
tool. Fetch the publication remote, then rebase onto the base branch only when the
branch is behind, conflicted, or the user asked for a sync — rebasing a branch
that is already current rewrites hashes for nothing.

### 4. Push safely

Push with `git push -u <remote> <branch>`. A rewrite needs `--force-with-lease`,
never bare `--force`, and only on a topic branch the user owns; never force-push a
base branch, a shared branch, or a branch you did not create in this session. Run
the checks the repository actually has, proportionate to the change — the test,
lint, or build a maintainer would run — and report failures rather than fixing
unrelated ones.

### 5. Write the body, then open the draft

Write real Markdown to a temporary file and pass it with `--body-file`; never build
a body from an inline string with escaped newlines.

```sh
gh pr create --draft --base <base> --head <branch> \
  --title "<title>" --body-file <path>
```

For an existing pull request, update instead of creating:

```sh
gh pr edit <number> --body-file <path>
```

Read the repository's pull request template if it has one
(`.github/PULL_REQUEST_TEMPLATE.md` or `.github/PULL_REQUEST_TEMPLATE/`), satisfy
its required sections, and never leave its placeholder text behind. Otherwise write
natural prose under a small number of descriptive headings: two sections by
default, a third only when it gives the reviewer distinct context. Keep only what
changes how a reviewer understands, verifies, or acts on the change, and cut
process narration, restatements of the diff, and generic background — an empty
section is worse than no section.

Do not hard-wrap the prose. Commit bodies wrap at 72 characters, but a pull request
body is rendered Markdown and must not carry manual line breaks. Write the title
and body in English, in ASD-STE (Simplified Technical English), whatever language
the conversation used, keeping non-English text only when it is existing content, a
quotation, or an identifier. Preserve
meaningful existing body content such as screenshots, links, issue references,
release notes, and reviewer notes, and never overwrite a human-written title unless
the user asked for a rewrite or it is clearly a generated placeholder.

### 6. Verify and report

Confirm the truth on the remote rather than trusting the create command's output:

```sh
gh pr view <number> --json url,state,isDraft,baseRefName,headRefName,title
```

Lead the final response with the pull request URL and its state, then give only
what is needed to trust the handoff: what was pushed, what checks ran and their
result, anything left uncommitted, and any caveat or reviewer action. Keep it
short.

## Attribution

Nothing in the branch name, commits, title, or body may record that an agent was
involved: no `Co-authored-by` naming a model or tool, no "Generated with" or
"AI-generated", no `codex/` or `claude/` branch prefixes, no tool name in the body.
Add such a trailer only when the user explicitly asks for it.

## Draft by default

New pull requests are drafts. Mark one ready for review only when the user asks:

```sh
gh pr ready <number>
```

## Examples

A first-time draft on a fresh topic branch:

```sh
git switch -c fix/token-refresh
git push -u origin fix/token-refresh
gh pr create --draft --base main --head fix/token-refresh \
  --title "fix: refresh tokens before they expire" --body-file /tmp/pr-body.md
gh pr view --json url,state,isDraft,baseRefName
```

A two-section body, which is the default shape:

```markdown
## What changed

Token refresh now happens five minutes before expiry instead of on the first 401, so a slow request can no longer land inside the gap and fail.

## How to verify

`npm test -- auth` covers the new timing. The expiry clock is injectable, so the test does not sleep.
```

## Resources

### references/

- `pr-body.md` — how to choose the sections, what belongs in each, and worked
  examples for a fix, a feature, and a refactor.
