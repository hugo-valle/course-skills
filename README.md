# course-skills

Claude Code skills and agents for building university courses, shared by every course repo.

The skills hold no course-specific detail. Each course repo describes itself in a `COURSE.md` at its root (syllabus, module layout, build skills, lab stacks, manual stages, pointers), and keeps any adapter skill only that course needs (for example a lab-stack skill) in its own `.claude/skills/`. Why it is split this way: [ADR 0001](docs/adr/0001-global-core-per-course-adapters.md).

## Install

```bash
git clone https://github.com/hugo-valle/course-skills.git ~/course-skills
~/course-skills/install.sh ~/cs2810/cs2810-master ~/cs6200/cs6200-master   # one or more course repos
```

`install.sh <course-repo>...` symlinks each folder in `skills/` and each file in `agents/` into that repo's `.claude/skills/` and `.claude/agents/`, next to any adapter skill the course keeps there. Nothing is installed globally. Re-run it after adding a skill or agent; edits to an existing one need no re-run. The links are machine-specific, so each course's `.gitignore` carries `.claude/skills/course-*` and `.claude/agents/course-*` (the template has them; the installer warns if they are missing). A fresh clone or CI has no skills until the installer is run there. For a brand-new course, make the repo folder, run the installer on it, then `/course-init`. Why: [ADR 0003](docs/adr/0003-install-skills-per-course-repo.md).

## Contents

| Skill | Use it for |
|---|---|
| `course-init` | Sets up a new course repo: copies `template/`, interviews the instructor and drafts the syllabus, drafts `COURSE.md`, creates module folders and writes the sources manifest, confirming each phase before writing |
| `course-design` | Whole-course evaluation against the syllabus; drafts proposals, publishes approved ones as issues. Drafts `COURSE.md` when a course has none |
| `course-implement` | Carries out one approved `course-design` proposal through the build skills `COURSE.md` names |
| `course-slides` | Generates a module's SlideKraft slides file from its notes, word for word, and checks it against a measured slide budget (`reference/check_budget.py --self-test`) |
| `course-review` | Reviews one module with three read-only reviewer agents (Accuracy, Style, Alignment); findings cite the course's sources by name and page, or a web source by URL and snapshot date. Builds the source cache (PDF pages, dated web snapshots) from the course's `instructor_material/README.md` (`reference/test_extract_sources.sh` is its self-test) |
| `course-images` | Plans, draws, builds and embeds TikZ figures for one module. Ships the base style (`reference/base.tex`: palette, title, note, callout, badge, arrows); each course keeps a style layer for its domain shapes and colour meanings, named in `COURSE.md` ("Figures") |
| `course-content` | Which content files are source vs generated and how to rebuild them, from `COURSE.md` ("Module layout") |
| `course-quizzes` | text2qti quiz banks; file names, question types and coverage target come from `COURSE.md` ("Quizzes") |
| `course-workflow` | Issue → branch → PR, commit-message lint, hooks and semester prep, using the scripts from `template/` |
| `course-lab-walkthrough` | `/course-lab-walkthrough <template-repo>`: converts one GitHub Classroom lab template repo to an `exercise-toolkit` interactive walkthrough (tracking issue, one task per push), closes grading gaps and validates it live. Reads `COURSE.md` "Lab delivery". User-invoked only |
| `course-idea` | `/course-idea <text>`: turns a loose course idea (layout, lab, presentation, technology) into a GitHub issue labelled `idea` and `needs-triage`, after you OK the draft. User-invoked only |

| Agent | Use it for |
|---|---|
| `course-module-accuracy-reviewer`, `course-module-style-reviewer`, `course-module-alignment-reviewer` | Dispatched by `course-review` only. Read and search tools only, so a reviewer cannot edit files |

## Naming

Every skill and agent in this repo starts with `course-`, so none of them collides with another plugin's. A course's own adapter skill is named `<course-code>-<what>` (for example `cs2810-exercise-toolkit`), without the `course-` prefix, and lives in that course repo's `.claude/skills/`. Why: [ADR 0002](docs/adr/0002-course-prefix-for-shared-skills.md).

## Template

`template/` holds the files a new course repo copies into itself: the rebuild script and its test, the commit-message checker, hooks, hook installer, semester-prep script and its issue templates, the commit-lint CI workflow, the PR template, an example `docs/agents/` config and a `.gitignore`. Each course keeps its own copies. How to copy it: [template/README.md](template/README.md).

## Rules for skills in this repo

- **No course detail.** Paths, tools, terms, module names and textbook names come from the course's `COURSE.md`. `template/` is the exception: its files are copied into a course repo and edited there, so they may carry default paths (`quizzes/`, `hands_on_exercises/`), and its `docs/agents/` is a worked example from one course. `scripts/leak_check.sh` fails on known course-specific terms (in `template/` too, except `docs/agents/`); run it before every commit. When a course detail moves into `COURSE.md`, add its term to the script.
- **Paths are relative to the skill, never to the project.** A skill names its own files as `reference/<file>` ("relative to this skill"); a reference file names a sibling by bare filename (`rubric.md`) and another skill's files as "the `<skill>` skill's `reference/<file>`". A path into the course repo (`COURSE.md`, `.claude/skills/<adapter>/`) is relative to the course repo root.

## Checks

```bash
scripts/test_leak_check.sh   # self-test of the leak check
scripts/leak_check.sh        # skills/, agents/ and template/ (not its docs/agents/ example) are free of course terms
(cd template && python3 scripts/test_rebuild_module.py)   # rebuild script self-check
skills/course-review/reference/test_extract_sources.sh   # source extractor self-test
```
