# Install the shared skills into each course repo, not globally

Status: accepted, 2026-10-11; superseded by [ADR 0004](0004-distribute-as-a-claude-code-plugin.md) for repos that can use plugins

The shared skills only make sense inside a course repo, but ADR 0001 linked them into `~/.claude/`, so they showed up in every unrelated project. `install.sh <course-repo>...` now symlinks `skills/*` and `agents/*` into each named repo's `.claude/skills/` and `.claude/agents/` (project skills load only there) and removes the old links in `~/.claude/`. The links hold absolute paths into this clone, so a course's `.gitignore` ignores `.claude/skills/course-*` and `.claude/agents/course-*`; the `course-` prefix from [ADR 0002](0002-course-prefix-for-shared-skills.md) makes that two lines that leave a course's own tracked adapters alone.

## Considered options

- **Keep the global install**: rejected. It clutters every project's skill list.
- **Commit the symlinks**: rejected. They break on any other machine and in CI.
- **Ignore via `.git/info/exclude` written by the installer**: rejected. Local-only, so a collaborator's clone relies on the installer's side effect instead of a visible rule; the installer warns instead.
- **Plugin packaging**: still deferred, see [ADR 0001](0001-global-core-per-course-adapters.md).

## Consequences

- A fresh clone or CI has no shared skills until `install.sh` runs there. A brand-new course needs the repo folder, then `install.sh <path>`, then `/course-init`.
- Each course repo's `.gitignore` needs the two lines; `template/.gitignore` has them.
