---
name: course-lab-validation
description: Validate a lab template repo from the student's side before release: audit the harness and CI for consistency, confirm the starter scores zero, commit the solution in stages on a throwaway branch, prove a deliberately wrong solution fails, watch the grading CI, and back-port only the fixes. Use when asked to validate, smoke-test or release-check a lab or project template.
disable-model-invocation: true
---

# Course Lab Validation

Proves that a lab template separates finished from unfinished work, the way a student meets it: through its own harness and its CI. It checks the lab contract's solution, template, harness and CI parts (the `course-implement` skill's `reference/lab-contract.md`). To convert a template to the interactive walkthrough, use `course-lab-walkthrough` instead.

Invocation: `/course-lab-validation <template-repo-path>`, run from the course repo. Phase 0 `cd`s into the template repo.

Reference file (relative to this skill): `reference/audit-checklist.md`.

## Course facts

Read `COURSE.md`. "Lab stacks" gives the harness command, the CI workflow, the build command and the adapter skill; "Lab delivery" gives the org, the template repos, the starter branch (default `main`), where the instructor solution lives, and any file holding a solution stage plan or stack notes. If a fact is missing, stop and name the section to add (`course-design` drafts it). Never invent a harness command.

## Phases

Follow in order. Confirm with the user before every push, every branch or tag deletion and the PR. Done when the PR is open and the test branch is handled as the user chose.

0. **Preflight.** `git status --short` is clean and the starter branch is current. Choose the test branch name `feature/test-student-flow`; git cannot hold `develop` and `develop/foo` together, so if the starter branch name is a prefix of the test branch name, pick another.
1. **Audit the template** against `reference/audit-checklist.md`. Fix findings on the starter branch. Done when every checklist item is ticked or listed as deferred.
2. **Verify the starting state.** Run the build and the harness exactly as `COURSE.md` gives them. Expected: it builds; infrastructure tests pass; each student TODO fails with a descriptive message; every graded check fails; the score is `0/N`. Done when you can state `N` and which tests pass and fail at the start.
3. **Create the test branch** from the starter branch.
4. **Plan, then commit the solution in stages.** From the solution `COURSE.md` names, draft the stages (one function or file group per commit, with the tests each should turn green) and show the plan in chat; wait for approval. Then commit one stage at a time, running the harness after each and checking the expected tests pass before continuing. Done when the harness reports `N/N`.
5. **Prove the harness discriminates.** Commit one deliberately wrong implementation that prints the correct output by an unintended route (a forbidden construct, or state in the wrong place), see `course-lab-walkthrough`'s `reference/grading-gaps.md`. It must fail. Revert it. A wrong solution that passes is a grading gap to fix on the starter branch.
6. **Push and watch CI** (after confirmation): push the test branch and follow the run (`gh run watch`, `gh run view --log`). Expected: the same `N/N` the local run gave. Quality steps (formatters, linters) must not fail the run.
7. **Back-port the fixes.** Cherry-pick only the template and infrastructure fixes onto the starter branch, never the solution commits. For a file fixed on the test branch, copy that file's fixed version in a separate commit. Rerun Phase 2 on the starter branch: it must still score `0/N` with every TODO intact.
8. **Open the PR** to `main` (after confirmation) with `gh pr create`: what was fixed, the starting score, the final score, and the negative-test result. Then ask whether to delete the test branch locally and on the remote; delete nothing unasked.
