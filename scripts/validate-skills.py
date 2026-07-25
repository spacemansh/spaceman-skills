#!/usr/bin/env python3
"""Validate every skill in this repository.

Checks the Agent Skills frontmatter contract, plus one repository rule: a
skill's `name` must match its directory name.
"""

from pathlib import Path
import re
import sys

try:
    import yaml
except ModuleNotFoundError:
    print("error: PyYAML is required (pip install pyyaml)", file=sys.stderr)
    raise SystemExit(1)


ALLOWED_KEYS = {"name", "description", "license", "allowed-tools", "metadata"}
MAX_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024
FRONTMATTER = re.compile(r"^---\n(.*?)\n---", re.DOTALL)


def validate(skill: Path) -> list[str]:
    errors = []
    skill_md = skill / "SKILL.md"

    if not skill_md.is_file():
        return ["SKILL.md not found"]

    match = FRONTMATTER.match(skill_md.read_text())
    if not match:
        return ["no YAML frontmatter found at the top of SKILL.md"]

    try:
        frontmatter = yaml.safe_load(match.group(1))
    except yaml.YAMLError as error:
        return [f"invalid YAML in frontmatter: {error}"]

    if not isinstance(frontmatter, dict):
        return ["frontmatter must be a YAML mapping"]

    unexpected = sorted(set(frontmatter) - ALLOWED_KEYS)
    if unexpected:
        errors.append(
            f"unexpected frontmatter key(s): {', '.join(unexpected)}. "
            f"Allowed: {', '.join(sorted(ALLOWED_KEYS))}"
        )

    name = frontmatter.get("name")
    if name is None:
        errors.append("missing 'name' in frontmatter")
    elif not isinstance(name, str) or not name.strip():
        errors.append("'name' must be a non-empty string")
    else:
        name = name.strip()
        if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name):
            errors.append(
                f"name '{name}' must be hyphen-case: lowercase letters and digits, "
                "single hyphens, no leading or trailing hyphen"
            )
        if len(name) > MAX_NAME_LENGTH:
            errors.append(
                f"name is {len(name)} characters; the maximum is {MAX_NAME_LENGTH}"
            )
        if name != skill.name:
            errors.append(f"name '{name}' does not match directory '{skill.name}'")

    description = frontmatter.get("description")
    if description is None:
        errors.append("missing 'description' in frontmatter")
    elif not isinstance(description, str) or not description.strip():
        errors.append("'description' must be a non-empty string")
    else:
        description = description.strip()
        if "<" in description or ">" in description:
            errors.append("description cannot contain angle brackets (< or >)")
        if len(description) > MAX_DESCRIPTION_LENGTH:
            errors.append(
                f"description is {len(description)} characters; "
                f"the maximum is {MAX_DESCRIPTION_LENGTH}"
            )
        if "TODO" in description:
            errors.append("description still contains a TODO placeholder")

    return errors


def main() -> int:
    repo = Path(__file__).resolve().parent.parent
    skills = sorted(path.parent for path in (repo / "skills").rglob("SKILL.md"))

    if not skills:
        print("error: no skills found under skills/", file=sys.stderr)
        return 1

    failed = False
    for skill in skills:
        errors = validate(skill)
        relative = skill.relative_to(repo)
        if errors:
            failed = True
            for error in errors:
                print(f"{relative}: {error}", file=sys.stderr)
        else:
            print(f"{relative}: ok")

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
