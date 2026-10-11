# Prefix every shared skill and agent with `course-`

Status: accepted, 2026-10-11

Skills and agents in `~/.claude/` share one flat namespace with every other skill, plugin and agent the instructor installs. Five of the ten skills (`add-images`, `contributing-workflow`, `quiz-authoring`, `review-module`, `slide-prep`) and the three `module-*-reviewer` agents had generic names another source could plausibly claim. Every shared skill and agent now starts with `course-`: `course-images`, `course-workflow`, `course-quizzes`, `course-review`, `course-slides`, `course-module-{accuracy,style,alignment}-reviewer`. A course's own adapter skills are named `<course-code>-<what>` and keep out of the `course-` prefix.

## Considered options

- **Rename only the five generic names**: rejected. The `course-*` five were already prefixed, so this is the same set of changes; the chosen rule just states it.
- **A project tag such as `cskills-` or an abbreviation such as `crs-`**: rejected. Less readable, and five skills already use `course-`.
- **Package as a plugin for automatic namespacing**: still deferred, see [ADR 0001](0001-global-core-per-course-adapters.md).
- **Verb-noun names for every skill**: rejected. Longer slash commands for no gain; descriptions already say what each skill does.

## Consequences

- Course repos that name the old skills (`COURSE.md`, `CLAUDE.md`) must be updated.
- `install.sh` removes dangling links into this repo, so a rename leaves no stale link in `~/.claude/`.
- [ADR 0001](0001-global-core-per-course-adapters.md) keeps the old names; it is history.
