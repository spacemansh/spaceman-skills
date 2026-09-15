---
name: resolve-merge-conflicts
description: >
  Resolve an in-progress Git merge, rebase, cherry-pick, or stash conflict. Reads
  the state of the operation, finds the primary source and original intent behind
  each conflicting change, resolves every hunk while preserving both intents where
  possible, runs the repository's checks, and finishes the operation. Never invents
  behaviour that neither side had, never discards work, never stages with git add
  -A, and never aborts without asking. Use when a merge or rebase has stopped with
  conflicts, when files carry conflict markers, or when the user asks to resolve,
  fix, continue, or finish a conflicted merge, rebase, or cherry-pick.
---

# Resolve Merge Conflicts

## Overview

Finish a conflicted merge or rebase with a result both sides would recognise:
every hunk resolved deliberately, nothing invented, nothing dropped in silence.
Resolution is a reading task before it is an editing task — the markers show where
two changes collide, never which one is right.

## When to Use

- User says "resolve the conflicts", "fix this merge", "I am mid-rebase",
  "finish the rebase", or "there are conflict markers".
- User triggers `/resolve-merge-conflicts`.

## Workflow

### 1. See the current state

```sh
git status --porcelain=v1
git diff --name-only --diff-filter=U
git log --oneline -5
ls .git/MERGE_HEAD .git/rebase-merge .git/rebase-apply .git/CHERRY_PICK_HEAD 2>/dev/null
```

Know which operation is running before touching a file, because the ending differs
and so does the vocabulary. A merge finishes with `git commit`, a rebase with
`git rebase --continue`, a cherry-pick with `git cherry-pick --continue`. In a
rebase the sides are reversed: "ours" is the branch being replayed onto, "theirs"
is the commit being replayed. Getting that backwards silently discards the user's
work.

Stop and report when no operation is in progress and no file carries markers —
there is nothing to resolve, and the user is describing a different problem.

### 2. Find the primary sources

For every conflicting file, learn why each side made its change before choosing
between them. Read the commits that introduced both sides (`git log --merge -p --
<path>` shows the commits that touched the conflicting range), and follow them out
to the pull request or issue that explains the intent (`gh pr list --search <sha>`,
then `gh pr view <number>`). A conflict resolved without knowing either intent is a
guess wearing a diff's clothes.

### 3. Resolve each hunk

Preserve both intents wherever they can coexist. Where they genuinely cannot, keep
the one matching the stated goal of the merge, and record the trade-off for the
final report — a decision nobody is told about is a decision nobody can review.
Never invent behaviour neither side had: this is not the moment to improve the
code, rename the variable, or fix the bug you noticed.

Edit each file to the intended result and delete every marker. `git checkout
--ours` or `--theirs` is legitimate when one side is wholly correct, never as a
fast way to make markers disappear. Never discard work with `git reset --hard`,
`git clean`, or `git checkout --` on a path you have not read.

Always resolve. Do not abort on your own: if a conflict truly cannot be resolved,
stop and report what is stuck and why, and run `git merge --abort` or
`git rebase --abort` only when the user asks for it.

Before finishing, prove no marker survived:

```sh
git diff --check
grep -rn '^<<<<<<< \|^=======$\|^>>>>>>> ' -- <resolved paths>
```

### 4. Run the project's checks

Discover what the repository actually has — `package.json` scripts, a Makefile, a
justfile, the CI workflow — and run them in the order that fails fastest:
typecheck, then tests, then format. Fix what the merge broke. Do not fix unrelated
failures, and say which ones were already failing before the merge started.

### 5. Finish the operation

Stage the resolved paths explicitly with `git add -- <path>`, never `git add -A`
or `git add .`, so a stray file cannot ride along invisibly. Then finish the
operation that is actually running:

```sh
git commit            # merge: keep the generated merge message
git rebase --continue # then return to step 1 for the next conflicted commit
git cherry-pick --continue
```

Keep the default merge message. It is not a Conventional Commits subject, it
carries no body, and it records no agent attribution — no `Co-authored-by` naming a
model or tool, no "Generated with", no tool name. A rebase repeats: conflicts can
surface on every replayed commit, so work through them until the rebase reports
that it is finished.

Work that is not part of the resolution belongs in its own commit afterwards. Use
the `auto-commit` skill for it rather than folding it into the merge. Skills
install one directory at a time, so this one can be present without `auto-commit`
beside it: read the sibling copy at `../auto-commit/SKILL.md` when it is installed,
and otherwise fetch it from source.

```
https://raw.githubusercontent.com/spacemansh/spaceman-skills/main/skills/auto-commit/SKILL.md
```

## Report

Close with what the user cannot see from `git log`: which files conflicted, how
each incompatible hunk was decided and what was traded away, which checks ran and
what they said, and anything still waiting on them.

## Examples

Reading both sides of one conflicting file before deciding:

```sh
git log --merge -p -- src/auth/token.ts
gh pr list --search 4f2c1ab --state all --json number,title,url
```

Finishing a rebase, one conflicted commit at a time:

```sh
git add -- src/auth/token.ts
git rebase --continue
git status --porcelain=v1
```
