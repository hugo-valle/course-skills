# Phase 7: live end-to-end test on a disposable branch

Do not skip. Every workflow gotcha was found here, not by reading code.

## Setup

Repeat from scratch for each re-test after a fix: delete and recreate rather than merging fixes in, to avoid merge commits on a throwaway branch.

```bash
git checkout -b LAB-student-test toolkit   # fresh from the work branch's tip
```

Widen the trigger on both new workflow files, commented as test-only:

```yaml
branches: [main, LAB-student-test] # TEST-ONLY: added for manual student-flow testing; do not merge to main.
```

Commit that (it triggers the first run) and push.

Before each fresh run, clean up the last one's state (ask before deleting the issue):

```bash
gh issue delete <N> --repo <org>/<repo> --yes
gh workflow enable <workflow-id> --repo <org>/<repo>   # re-enable anything self-disabled last time
```

## The template-repo guard no-ops the test

The `is_template` guard (`workflow-gotchas.md` #7) silently skips every job, because `LAB-student-test` is a branch of the same repo that has `is_template: true`. Ask, then flip it off for the test and back before merging:

```bash
gh api -X PATCH repos/<org>/<repo> -f is_template=false   # before testing
# ... run the walkthrough below ...
gh api -X PATCH repos/<org>/<repo> -f is_template=true    # before Phase 9 / merge
```

**An agent harness with its own permission layer can deny this PATCH** even when `gh auth status` reports admin scope: the scope and the harness's safety classifier are separate gates, and a repo-settings change can trip the second one where a push or `gh pr create` does not. A narrower workaround (branch-scoping the guard in the workflows' `if:` conditions) can be flagged too. If denied: do not retry with reworded commands, and do not route the action through another tool or a nested agent. Leave `is_template` untouched and report that Phase 7 cannot complete here and needs a human with interactive access before the adaptation is safe to merge.

Before flipping it back, verify the guard itself: push one more trivial commit with `is_template` still `true` and confirm via `gh run list` or `gh api .../jobs` that `find_existing` and `find_exercise` (and everything depending on them) show as skipped. This is the actual verification that the guard works; everything else runs with it off.

## Walk through it as a student

```bash
gh run list --repo <org>/<repo> --branch LAB-student-test --limit 5
gh run watch <run-id> --repo <org>/<repo> --exit-status
```

- First push (the trigger-widening commit): the issue is created, the README personalized, Task 1 posted.
- Implement tasks progressively in separate commits. After each push: the results-table comment updates in place (no spam); the next task is revealed only once its predecessor passes; and, if Phase 4 applies, a deliberately broken implementation (a swapped-register or forbidden-instruction variant, or an unimplemented guidance-only task) is caught live, not just locally.
- Final push (all tasks passing): the congrats comment, the README rewrite, and the issue stays open (not closed) if manual-grading points remain.
- One more real push after completion. It must be an actual file change: an empty commit or a change under a `paths-ignore`'d path never triggers a path-filtered workflow, which looks like a false pass. Every step after "Check if already complete" shows skipped (`-`), and the comment count and README commit SHA are unchanged. This catches `workflow-gotchas.md` #5.

## Fixes found here

Never port a fix back to the work branch with a file-scoped diff or apply. By then the test branch's `README.md` is bot-rewritten (real login, real issue URL); a blanket diff pulls that personalization into the work branch's generic banner, and it reaches `main` looking fine until someone sees a student's name in the template repo's README. Cherry-pick the textual change by hand.

Inspect comment bodies and timestamps with `gh api repos/<org>/<repo>/issues/<N>/comments --jq '...'`. `gh issue view --comments` and `gh pr edit` can fail on an unrelated GraphQL "Projects (classic)" deprecation; use the REST API instead (`gh api repos/.../pulls/<N> -X PATCH -F body=@file`).

## Finish

Ask whether to clean up the test branch and issue or leave them for review; delete nothing unasked. Either way restore `is_template` to `true` and check it with `gh api repos/<org>/<repo> --jq '.is_template'`; left `false`, the template repo personalizes its own README on the next push.

## Scratch repo variant (student-folder deliveries)

When the walkthrough lives in a student folder inside the course repo, there is no template repo to branch. Test on a private scratch repo instead; its `is_template` is `false`, so the guard is not needed.

1. Create the scratch repo (ask first). Copy the tracked files of the student folder into a temporary directory, `git init -b main`, commit and push. The first push starts the walkthrough.
2. Walk through it as in "Walk through it as a student", pushing a staged solution for each task. Build the stages from the instructor copy by replacing unfinished functions with their stubs; check locally which rows pass at each stage, because rows that pass early change what the bot posts.
3. To reset between runs (ask first): delete the tracking issue, `gh workflow enable 0-exercise-start.yml`, and force-push a fresh copy of the student folder. The start workflow runs again.
4. After the walkthrough works, run a student agent on it (the `course-lab-student` agent) and fix its findings.
