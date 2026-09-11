# Writing the pull request body

The body exists to save the reviewer time. Every line should change how they read
the diff, verify it, or decide on it. If a line does none of those, cut it.

## Choosing the sections

Two sections by default. A third only when it carries context the first two
cannot. Never pad to a fixed shape, and never leave a heading with nothing
underneath it.

| Section          | Include when                                                        |
| ---------------- | ------------------------------------------------------------------- |
| What changed     | Always. The change stated in prose, at a higher altitude than the diff. |
| Why              | The reason is not obvious from the code — a constraint, a trade-off, a rejected alternative. |
| How to verify    | There is a command, a flow, or a case the reviewer should exercise.  |
| Risk             | Something can break in production: a migration, a config change, an unverified path. |
| Caveats          | Work is deliberately left out, or a check could not be run.          |

Pick the two or three that actually apply. "What changed" plus one of the others
covers most pull requests.

## What to leave out

- A restatement of the diff. The reviewer can read the files.
- Process narration: what was attempted, which commands were run, how the work
  proceeded.
- Generic background the team already knows.
- Empty or placeholder sections, and template headings with nothing under them.
- Checklists nobody will tick.
- Any mention that an agent wrote the code.

## Formatting

- Rendered Markdown. Do not hard-wrap prose to 72 or 80 columns — that is a
  commit-message rule, and here it produces ragged output.
- ASD-STE (Simplified Technical English) for the prose.
- Prose over bullet soup. Use a list when the items are genuinely parallel, not
  as a way to avoid writing sentences.
- Reference issues where the repository expects it: `Closes #42` links and closes
  on merge.
- Fenced code blocks with a language tag for commands and output.

## Worked examples

### A fix

```markdown
## What changed

Token refresh now happens five minutes before expiry instead of on the first
401, so a slow request can no longer land inside the gap and fail.

## How to verify

`npm test -- auth` covers the new timing. The expiry clock is injectable, so the
test does not sleep.
```

### A feature

```markdown
## What changed

Adds `skills validate`, which checks every SKILL.md for the frontmatter contract
and for a name matching its directory. It reports all failures at once rather
than dying on the first.

## Why

The previous validator shelled out to a script under the author's home
directory, so it passed locally and failed in CI. This version has no
dependency outside the repository.

## How to verify

`npm run validate` on a clean tree passes. Renaming a skill directory without
renaming the skill makes it fail.
```

### A refactor

```markdown
## What changed

Extracts the agent-detection branch out of the installer into a single helper.
No behaviour change; the same agents are detected in the same order.

## Risk

The helper is used by both installers, so a mistake here affects macOS and
Windows together. The sandbox install in the test plan covers both paths.
```
