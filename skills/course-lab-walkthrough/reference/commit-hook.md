# Phase 8: commit-msg hook

Recommended for every lab. `check_git_workflow.sh`'s vague-message check is informational and runs only in CI, after a push, which is too late to build a habit. A local `commit-msg` hook rejects a bad commit before it exists.

1. Copy `templates/commit-msg` to `.githooks/commit-msg` and `chmod +x` it. It rejects a commit exactly when its subject matches the same `BAD_MESSAGE_PATTERN` as `check_git_workflow.sh` (case-insensitive, exact match only: `"fix: correct float prompt spacing"` still passes). Block only those documented vague messages; requiring a task reference or conventional-commit prefix would false-positive on a legitimate doc tweak or fixup. Replace the template's two `<replace with ...>` example lines with real examples from this lab's own `docs/GIT_BEST_PRACTICES.md` "Examples You Can Copy" section.
2. **Git hooks are never cloned with a repo** (`.git/hooks` isn't tracked), so nothing activates the hook on `git clone`. Add an `ensure_git_hooks_installed()` function to the test harness (a reference implementation is in the course's "Lab delivery" reference repos) that silently runs `git config core.hooksPath .githooks` on every invocation: idempotent, and wrapped so it can never crash test running when `git` is missing or the directory isn't a repo (check `git rev-parse --is-inside-work-tree` first, swallow all other errors). Call it right after the harness's prerequisite check in `main()`. Students run the harness constantly, so the hook activates with no manual setup step.
3. Update `docs/GIT_BEST_PRACTICES.md`: right after "Messages to Avoid", add a short section saying the hook activates the first time the harness runs, and one honest sentence that it is a personal safety net bypassable with `--no-verify`, not a replacement for the manually graded Git Workflow category. State the escape hatch; a client-side hook cannot be the only enforcement.
4. **Update every copy of the README's "Git Commit Guide" Quick Links bullet.** There are normally two: the root `README.md` and `.github/steps/readme-in-progress.md`, which carries its own Quick Links section (Phase 2). Missing the second is the usual gap.

## Verification checklist

Verify all of it, not a subset:

- `shellcheck -s sh .githooks/commit-msg` is clean.
- Vague messages are rejected case-insensitively (`wip`, `WIP`, `Fix`) with exit 1 and the guidance text; prefixed or task-style messages (`"fix: ..."`, `"task1: ..."`) are accepted. Test in an isolated scratch repo first (`git init` there, copy the hook to `.git/hooks/commit-msg`), then confirm it fires in the real repo before committing anything through it.
- A real auto-generated merge commit (`git merge --no-ff` with no `-m`) is not blocked, but an explicit vague message given via `-m` during a merge is. These are different `commit_source` values (`merge` vs. unset or `message`); confirm the distinction live.
- Fresh-state bootstrap: `git config --unset core.hooksPath`, run a harness command that reaches `main()`'s body (not `--help`, which `argparse` exits on before `main()` runs), confirm the one-time notice prints and `git config --get core.hooksPath` reads `.githooks`, run again and confirm the notice does not reprint.
- `git ls-files -s .githooks/commit-msg` shows mode `100755`; a hook committed without its executable bit silently never runs, and `git add` does not warn.
- A full harness run (all tasks) gives the same pass and fail counts as before the hook: the bootstrap must never interfere with grading, and this catches any exception leaking out of `ensure_git_hooks_installed()`.
