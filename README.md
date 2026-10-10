# course-skills

Claude Code skills and agents for building university courses, shared by every course repo.

The skills hold no course-specific detail. Each course repo describes itself in a `COURSE.md` at its root (syllabus, module layout, build skills, lab stacks, manual stages, pointers), and keeps any adapter skill only that course needs (for example a lab-stack skill) in its own `.claude/skills/`. Why it is split this way: [ADR 0001](docs/adr/0001-global-core-per-course-adapters.md).

## Install

```bash
git clone <this repo> ~/course-skills
~/course-skills/install.sh
```

`install.sh` symlinks each folder in `skills/` and each file in `agents/` into `~/.claude/skills/` and `~/.claude/agents/`. Re-run it after adding a skill or agent. Edits to an existing one need no re-run.

## Contents

| Skill | Use it for |
|---|---|
| `course-design` | Whole-course evaluation against the syllabus; drafts proposals, publishes approved ones as issues. Drafts `COURSE.md` when a course has none |
| `course-implement` | Carries out one approved `course-design` proposal through the build skills `COURSE.md` names |

## Rules for skills in this repo

- **No course detail.** Paths, tools, terms, module names and textbook names come from the course's `COURSE.md`. `scripts/leak_check.sh` fails on known course-specific terms; run it before every commit. When a course detail moves into `COURSE.md`, add its term to the script.
- **Paths are relative to the skill, never to the project.** A skill names its own files as `reference/<file>` ("relative to this skill"); a reference file names a sibling by bare filename (`rubric.md`) and another skill's files as "the `<skill>` skill's `reference/<file>`". A path into the course repo (`COURSE.md`, `.claude/skills/<adapter>/`) is relative to the course repo root.

## Checks

```bash
scripts/test_leak_check.sh   # self-test of the leak check
scripts/leak_check.sh        # skills/ and agents/ are free of course terms
```
