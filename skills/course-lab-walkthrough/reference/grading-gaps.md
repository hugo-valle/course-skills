# Phase 4: grading gaps; Phase 5: scaffold audit

A lab can have either gap, both or neither; check both.

## A. A checked task with an unverified sub-requirement

Whatever specific, checkable requirement the README states that the harness doesn't verify. The shape is always the same: find the side channel the tool or interpreter exposes for inspecting internal state, or the source itself, beyond stdout, and check that in addition to the printed text. Flavors seen:

- **Final state of a variable or register.** The README names where a result must live; the harness only checks printed text, so a wrong location passes. Check state through the tool's own CLI.
- **Instruction or construct restriction.** The README forbids one; the harness checks only the result. Check by static source inspection.
- **Calling convention.** Specific registers saved and restored, not an end value, when the call chain creates no observable difference between following it and skipping it (every callee is a leaf). **This recurs**; it showed up in two labs before being caught, so audit it on every new lab in Phase 1.
- **Required implementation strategy** (for example mandatory recursion) when the harness checks only the return value, so an iterative shortcut passes. Count self-calls inside the procedure's own body.

The stack's recipes (how to read the state, extract a procedure body, match a mnemonic) live in the stack's adapter skill; `COURSE.md` "Lab stacks" names it. Common rules for every recipe:

- Fold the new check into the same pass/fail boolean that feeds the CI workflow's existing grep pattern; do not change the printed text.
- Check only values with a single well-defined required end value (accumulators, not temporaries). Design cases so every checked location has a value pairwise distinct from the others in at least one case, or a swap between exactly those two goes uncaught.
- Strip comments before matching source, and match whole words, so a TODO hint or a label never false-positives.
- Verify both directions live: a deliberately wrong implementation that prints the right answer must now fail, a correct one must still pass, and a full run must be otherwise unchanged.

## B. A "guidance-only" task that always passes

Some tasks are marked guidance-only or manual review because they have no clean argument and return contract to call directly (a banner-printing procedure with no arguments is typical). Check whether that task's runner function in the harness runs the student's code at all, in both the single-task path and the all-tasks aggregate path; fixing one and missing the other is easy. In one lab both printed a canned PASS unconditionally, so an unimplemented stub earned those points every time.

Fix pattern:

- Add a runner helper that runs the student's whole program, not a per-procedure test file.
- Add a `taskN_check()` that pipes a smoke input valid enough to get the program through (check what the still-unimplemented stubs consume from stdin first), then checks stdout by keyword, not by exact line. The README's sample strings are "e.g.", and exact matching fails a correct implementation that phrases things differently or hits the simulator's non-UTF-8 round-tripping of a multi-byte character such as an em dash.
- Wire the check into both runner paths.
- Verify: the pristine scaffold now fails (it always passed), a correct implementation still passes, and a full run is otherwise unaffected.
- Update every doc that called the task guidance-only or manually reviewed (README, the task's `.github/steps/task-N.md`, the rubric, any HOWTO, the test README) to describe it as automated, and move its points into the automated bucket.

## Scaffold audit (Phase 5)

The starting scaffold is a teaching artifact. Ask the opposite question from Phase 4: is it giving away too much of the skill being tested?

Read every procedure stub end to end, not only the `# TODO` ones, and compare siblings that share a point value and structural shape (for example three field-extraction procedures worth 50 points each, all extract, print, save-before-print, restore-before-return). A scaffold is over-generous when one sibling hands the student a complete, working, uncommented block for the part its siblings leave as bare prose: the skill being tested, not boilerplate an earlier task covered, has been solved for them. In one lab the exponent-printing task shipped the whole working print sequence and blanked only the math, while its same-points, same-shape sibling got prose only.

Cross-check against the course's ungraded practice or hands-on companion file for the same concept (it may ship a full answer key). If the graded scaffold is more generous than the ungraded practice file for an equivalent step, that is backwards; trim it to at least that rigor.

Fine to leave in:

- Orchestration the task doesn't grade (a fully wired `main` calling every procedure in order).
- Literal data (`.data` strings, constants).
- Boilerplate for a step an earlier task already taught (the prompt and read pattern, once covered).
- A formula the README or task file already discloses in full. Duplicating disclosed material is fine; runnable code for the part around it, which the README leaves to the student, is not.

Fix: trim the over-scaffolded stub to prose-only TODO guidance at the same level as its true siblings. Name the computation in prose if the README discloses it, describe the save/restore or print requirement in words, and remove instructions for the part that was the exercise. Verify both: the trimmed stub still fails cleanly as an unsolved scaffold (no crash, no accidental pass), and a from-scratch implementation still passes its test.
