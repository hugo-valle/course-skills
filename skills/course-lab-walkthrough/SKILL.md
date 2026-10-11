---
name: course-lab-walkthrough
description: Adapt a GitHub Classroom lab template repo (README, test harness, CI) to the skills/exercise-toolkit interactive walkthrough: a bot-driven tracking issue that reveals one task per push, grading gaps closed, validated live before merge. Use when asked to convert, adapt or re-run the walkthrough adaptation for a lab template repo.
disable-model-invocation: true
---

# Course Lab Walkthrough

Converts one lab template repo from a static README task list into an interactive walkthrough: a tracking issue opens in each student's repo, a bot reveals the next task as the student pushes, and their README tracks progress. Everything here was learned by running it against real GitHub Actions; the gotchas in `reference/` each surfaced live.

Invocation: `/course-lab-walkthrough <template-repo-path>`, run from the course repo. Phase 0 `cd`s into the template repo; run its git commands there and `gh` against its `<org>/<repo>`.

Reference files (relative to this skill): `reference/workflow-gotchas.md`, `reference/grading-gaps.md`, `reference/live-test.md`, `reference/commit-hook.md`, and `templates/` (the two toolkit workflows, the step and comment files, the commit-msg hook, `check_git_workflow.sh`). Work through every `LAB-SPECIFIC` comment in a template before using it.

## Course facts

Read the course's `COURSE.md`: "Lab delivery" (org, template repos, toolkit tag, harness output markers, CI workflow, reference implementations) and "Lab stacks" (harness and CI paths, adapter skill). If either is missing, stop and say which section to add (`course-design` drafts it). The stack's adapter skill owns the stack-specific grading-gap recipes `COURSE.md` points to.

Check the toolkit for a newer tag than "Lab delivery" pins: `gh api repos/skills/exercise-toolkit/tags --jq '.[].name'`. If you bump it, re-run Phase 7. The toolkit docs are `skills/exercise-toolkit`, `skills/exercise-creator` and `skills/exercise-template` on GitHub.

## Phases

Follow in order. Do not skip Phase 7; it caught every workflow bug in `reference/workflow-gotchas.md`. Done when the PR from Phase 9 is open with its testing section written.

0. **Preserve the original, branch off.** From an up-to-date `main`: `git tag -a pre-exercise-toolkit -m "Lab N template before adopting the exercise-toolkit walkthrough"`, push the tag, then `git checkout -b toolkit`. Ask before pushing the tag.
1. **Inventory the lab.** Read, in this order: the README (per-task sections vs. spec tables, testing instructions, submission checklist); the starting scaffold, every procedure stub end to end; the test harness (its exact per-task pass/fail marker strings, and whether every task's runner function runs the student's code at all); the existing CI workflow (its grep patterns, actor exclusions, any git-workflow script to carry forward). Then ask: does the README require something checkable that the harness never verifies? That is where a grading gap lives. Done when you can list every task's marker string and every unverified requirement.
2. **Split task content out of the README.** Keep title and points header, Quick Links, spec tables, testing instructions and submission checklist in `README.md`. Lift each task section verbatim into `.github/steps/task-N.md` (`templates/task-N.md`). Create `.github/steps/readme-in-progress.md` and `readme-finished.md` (same static content, banner swapped; `templates/readme-in-progress.md` has the `readme-finished.md` diff) and `exercise-finished-comment.md`. The root `README.md` gets its own generic banner, placed after the spec content and before the sample output, with no `{{ }}` variables and no issue link: the workflow never touches the template repo's own README. Banner wording is in `reference/workflow-gotchas.md`.
3. **Add the two toolkit workflows.** Copy `templates/0-exercise-start.yml` and `templates/exercise-progress.yml` into `.github/workflows/`, resolve every `LAB-SPECIFIC` comment, and run `actionlint` after every edit. Apply all seven gotchas in `reference/workflow-gotchas.md`.
4. **Close the grading gaps from Phase 1.** `reference/grading-gaps.md`: an unverified sub-requirement, and a "guidance-only" task that always passes. Done when the pristine scaffold fails, a correct solution passes and a full run is otherwise unchanged.
5. **Audit the scaffold for pedagogical value.** `reference/grading-gaps.md`, "Scaffold audit". Done when the trimmed stub still fails cleanly as an unsolved scaffold and a from-scratch solution still passes.
6. **Consolidate CI.** If the old validation workflow's only extra value is the git-workflow script, fold it into `exercise-progress.yml` (the optional block in the template): `fetch-depth: 0`, append its markdown to the task-results comment, keep `$GITHUB_STEP_SUMMARY` and a `test-results.txt` artifact, add `workflow_dispatch:`. Then delete the old workflow with `git rm`; ask before deleting. Update the docs that describe what is tested (grading rubric, test README) and grep every task name, count and point value you changed; templates copied from an earlier lab carry stale content.
7. **Live end-to-end test on a disposable branch.** `reference/live-test.md`. Ask before each repo-settings change and before deleting the test branch or issue. Done when the post-completion push shows every step after the done-check skipped.
8. **Add a commit-msg hook.** `reference/commit-hook.md`, including its verification checklist.
9. **Finalize.** `git push origin toolkit`, then `gh pr create --base main --head toolkit`. Write the PR body from `git log main..toolkit`, grouped by theme (walkthrough, grading gaps closed, scaffold audit, commit-msg hook, CI consolidation, doc fixes), with a "Testing performed" section for Phase 7 and 8 results and the bugs found. Merge only when asked. When adding Phase 8 to an already-merged adaptation, check the base is current first: `git merge-base --is-ancestor <old-branch-tip> origin/main`; GitHub often auto-deletes a merged PR's branch, and pushing to that name silently creates a disconnected branch.
