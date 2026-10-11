# Course repo template

Files a new course repo copies into itself, because the shared skills expect them in the repo. Each course keeps and edits its own copies; nothing here is symlinked.

`/course-init` copies it as its first phase. By hand, from the course repo root:

```bash
rsync -a --ignore-existing --exclude /README.md --exclude __pycache__ ~/course-skills/template/ ./
./scripts/install-hooks.sh
```

This skips this file (the course root README is its syllabus) and never overwrites a file the repo already has. If the repo already had a `.gitignore`, merge the template's lines into it.

| Path | What it is | Edit after copying |
|---|---|---|
| `scripts/rebuild_module.py` | Rebuilds quiz `.zip`s (text2qti) and exercise `.html` pages from their `.md` sources. Self-check: `python3 scripts/test_rebuild_module.py` | the `quizzes` and `hands_on_exercises` roots if the course uses others. Exercise pages load `../exercise.css` and `../exercise-renderer.js`, which the course supplies |
| `requirements.txt` | text2qti pin for the rebuild script's `.venv` | |
| `scripts/check-commit-message.sh` | Commit-message policy, shared by the hook and CI | |
| `scripts/install-hooks.sh` | Points `core.hooksPath` at `.githooks/` | |
| `.githooks/` | `commit-msg` runs the checker; `pre-push` blocks pushes to `main` | |
| `scripts/new_semester.sh` | Creates the semester-prep issue and one module-readiness sub-issue per module, from the two `.github/ISSUE_TEMPLATE/` files | `MODULES` |
| `.github/workflows/commit-lint.yml` | "Commit Message Lint" CI job, and the check that a PR links an issue | |
| `.github/pull_request_template.md` | PR body with the `Closes #` slot | type-of-change list |
| `docs/agents/` | Example engineering-skills config: issue tracker, triage labels, domain glossary | everything: it is a worked example from one course (the leak check skips it) |
| `.gitignore` | Keeps `instructor_material/` (copyrighted sources) and the rebuild `.venv` out of git | |

Then write `COURSE.md` (`/course-init` or `/course-design` drafts it) so the global skills know the course's layout.
