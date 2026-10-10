---
name: contributing-workflow
description: A course repo's issue → branch → PR workflow, commit-message lint rules and git hooks (scripts/check-commit-message.sh, .githooks/). Use before creating a branch, committing, pushing or opening a pull request, when a commit is rejected by the commit-msg or pre-push hook or by the Commit Message Lint CI job, or when starting semester prep with new_semester.sh.
---

# Contributing workflow

The scripts, hooks and CI job below come from the course-skills `template/` folder; each course repo keeps its own copies. Where the repo's copy differs from this page, the repo's copy wins. The contributing guide and the tracker doc (issue operations) are under "Pointers" in `COURSE.md`.

## Flow

1. Open an issue (`gh issue create`).
2. Branch `<issue#>-short-description` from `main`, for example `42-fix-module3-quiz-q7` (also accepted: `issue-42-…`, `fix/42-…`).
3. Commit under the message rules below.
4. Push and open a PR with `gh pr create`. Follow `.github/pull_request_template.md`. The body must say `Closes #N`.
5. Merge once review and CI pass, then delete the branch.

Never commit to `main`. The `pre-push` hook blocks pushes to it (override `ALLOW_PUSH_TO_MAIN=1` only in an emergency).

## Commit messages

Checked by `scripts/check-commit-message.sh`, in the `commit-msg` hook and the "Commit Message Lint" CI job.

- Subject 10–72 characters.
- Starts with a capital letter, or a Conventional Commit type (`fix: `, `docs: `).
- No trailing period.
- Not vague: `update`, `wip`, `fix bug`, `minor changes` are rejected.
- A blank line between subject and body.
- An issue reference in the message (`#42`, `Closes #42`) or the issue number in the branch name.

Merge, revert and `fixup!` / `squash!` commits are exempt.

## Setup

Run `./scripts/install-hooks.sh` once per clone. It sets `core.hooksPath` to `.githooks/`.

## Semester prep

`./scripts/new_semester.sh "Fall 2026"` creates the semester-prep issue and one module-readiness sub-issue per module in its `MODULES` list (`--dry-run` previews).

## Skills that stop at the working tree

`/review-module`, `/add-images` and `/slide-prep` never branch, commit or open PRs. Their work then goes through this flow; the tracker doc says how their output becomes issues.
