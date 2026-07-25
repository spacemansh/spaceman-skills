# Conventional Commits 1.0.0, as applied by `auto-commit`

Source: https://www.conventionalcommits.org/en/v1.0.0/

## Structure

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

The specification permits any number of footers in `Token: value` form. This
skill deliberately allows only one, and only under one condition. See
[Stricter rules](#stricter-rules-this-skill-adds).

## Types

`feat` and `fix` are the two types the specification defines. The rest are the
conventional set this skill uses:

| Type       | Use for                                                        |
| ---------- | -------------------------------------------------------------- |
| `feat`     | A new capability visible to a user of the code                  |
| `fix`      | A bug fix                                                       |
| `docs`     | Documentation only                                              |
| `style`    | Formatting and whitespace, no behaviour change                  |
| `refactor` | Restructuring with no behaviour change                          |
| `perf`     | A change made for performance                                   |
| `test`     | Adding or correcting tests only                                 |
| `build`    | Build system, bundling, packaging, dependencies                  |
| `ci`       | CI configuration and pipelines                                  |
| `chore`    | Maintenance that fits nothing above                             |
| `revert`   | Reverting a previous commit                                     |

`feat` maps to a minor release and `fix` to a patch release under SemVer. A `!`
marks a breaking change and maps to a major release, whatever the type.

## Scope

A noun in parentheses describing the section of the codebase: `feat(parser):`.
Optional. Prefer a real package, module, or directory name. Omit it when the
change is repository-wide or when no honest scope exists.

## Breaking changes

Two mechanisms exist in the specification: a `!` before the colon, and a
`BREAKING CHANGE: <description>` footer. Either is sufficient.

**Always use `!`.** It keeps the signal in the subject line and avoids a footer,
which this skill otherwise forbids. When `!` alone cannot convey the migration
path, that is the case for a body — describe the migration there, still without a
footer.

## Stricter rules this skill adds

The specification treats the body and footers as freely optional. This skill
narrows that:

1. **No body unless it is needed.** A body is needed when the reason for the
   change is not recoverable from the diff. It is not needed to restate the
   diff, to list touched files, or to pad a small change.
2. **No footer except an issue reference.** `Closes #42`, `Fixes #42`, or
   `Refs #42`. Nothing else — no `Reviewed-by`, no `Signed-off-by` (unless the
   user asks), no `BREAKING CHANGE`.
3. **A footer requires a body.** If a commit should reference an issue, it gets a
   one-or-two-line body giving the reason, then a blank line, then the footer.
4. **No agent attribution, ever.** No `Co-authored-by` naming a model or tool, no
   "Generated with", no "Assisted-by", no tool name in the body. The commit does
   not record how it was written.

Rules 1–3 are the repository's policy layered on top of the specification;
rule 4 is absolute.

## Subject line mechanics

- Imperative mood: "add", "fix", "remove" — never "added", "adds", "adding".
- No trailing period.
- Target 50 characters; 72 is a hard cap.
- Match the surrounding history for capitalization after the colon. Lowercase
  when the history gives no signal.
