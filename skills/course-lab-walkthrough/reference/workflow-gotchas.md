# Workflow gotchas

Phase 2's root-README banner and Phase 3's gotchas. Each also has an inline comment in the template at the exact spot.

## Root README banner (Phase 2)

Add a generic, non-personalized banner to the static root `README.md`, later in the document than the personalized one: after the spec and register-map content, right before the complete sample output. The root README reads as a curriculum landing page (spec first, walkthrough note second); `.github/steps/readme-in-progress.md` reads as an active assignment (banner first, the most urgent thing for a student with a live issue). Adapt the task count and phrasing:

```markdown
## 🚀 Interactive Walkthrough

This lab uses an interactive, automated walkthrough for Tasks 1–N. A
tracking issue opens in this repository automatically as soon as your
assignment repo is created — no action needed to start it. From there, a bot
checks your work after every push and posts the next task's instructions as
a comment.

Task requirements, sample output, and the "commit before moving on"
checkpoints all appear in that issue. If you don't see it yet, check the
**Issues** tab — this banner is replaced with a direct link to it within a
minute or two of your repo being created.
```

## The workflow gotchas (Phase 3)

1. **`exercise-title` must not contain a colon.** The toolkit's own `start-exercise.yml` embeds it unquoted into internal YAML; a colon breaks it with `"Invalid input: 'template-vars' must be valid JSON or YAML format"`. Use an em dash.
2. **`0-exercise-start.yml` needs its numeric-prefixed filename.** The toolkit's `disable_workflows` job crashes (`bash -e` plus a `grep` with no match exits 1) if zero `[0-9]*.yml` workflow files exist.
3. **Never hardcode `ref: main` in a checkout.** Use `ref: ${{ github.ref_name }}`, needed both to pick up the toolkit's own README commit mid-run and so live testing on another branch works without editing checkouts back and forth.
4. **Don't exclude `github-classroom[bot]` from `0-exercise-start.yml`.** That exclusion belongs on `exercise-progress.yml` only (it avoids wasting CI on an untouched scaffold). Excluding it from the START workflow means the student can't see Task 1 until they push, and doesn't know what to push.
5. **`exercise-progress.yml` must short-circuit everything once done.** Check for the done-marker as the very first step and skip all remaining steps if found. Otherwise the next push's `--edit-last` calls clobber the congrats comment and completion re-fires forever. This was the subtlest bug; it surfaced by pushing a real commit after completion in Phase 7.
6. **Self-disable by filename, not `${{ github.workflow }}`.** The display name is ambiguous if a stale duplicate registration exists (for example from renaming the file during iteration); `gh workflow disable` then fails with "could not find any workflows named X".
7. **Guard every job against running on the template repo itself.** Add `if: ${{ !github.event.repository.is_template }}` to `find_existing` (in `0-exercise-start.yml`) and `find_exercise` (in `exercise-progress.yml`), and fold the same clause into the existing `if:` of `start_exercise`, `post_task_1` and `check_progress` (the templates already have it). Without it, nothing stops the flow from firing on the template repo's own pushes, opening a real tracking issue and personalizing its `README.md`. `is_template` is a repo-level setting, true on every branch. Confirm it: `gh api repos/<org>/<repo> --jq '.is_template'`. If `false`, ask, then set it: `gh api -X PATCH repos/<org>/<repo> -f is_template=true`. This guard is why Phase 7 needs a setup and teardown step.
8. **`intro-message` must not contain a colon either.** The toolkit embeds it unquoted in the same internal YAML as the title (gotcha 1); "Eight tasks (100 points): write ..." fails the start workflow with the same `'template-vars' must be valid JSON or YAML format`.
9. **The toolkit disables the start workflow itself, so a second disable fails.** Its own `disable_workflows` job usually wins the race; the template's final `gh workflow disable` step then gets `HTTP 403: Unable to disable a workflow that is not active` and turns the run red. End that step with `|| echo "already disabled"`.
10. **A setup action can break the build before the harness runs.** Some toolchain actions export warnings-as-errors flags (for example Rust's `setup-rust-toolchain` sets `RUSTFLAGS=-D warnings`), and a starter whose stubs leave arguments unused then fails to build in CI while it builds locally. The harness prints no score and every task reads as failed. Disable the flag in the action's inputs and let the style row of the harness enforce warnings. Verify with a push of the pristine starter.
11. **The bot must not overwrite what the student wrote in the README.** The start and finish steps rewrite `README.md`, so a disclosure section or ticked checklist added by the student is lost at the finish. Keep student-owned content in its own file (checked by the progress workflow), and swap only the banner at the finish (`templates/finished-banner.md` between the `banner:start` and `banner:end` markers).
12. **The results table header stays red until every task passes.** The toolkit's results template says "Fail" and "Time to find the bug" if any row fails, so listing all tasks shows red to a student who is on track. List only the tasks revealed so far, and say in the comment what the last task still needs.
