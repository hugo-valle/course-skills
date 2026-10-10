# Tooling proposals

How to carry out an approved `tooling` proposal that adds the adapter skill for a lab stack with none (`lab-contract.md`, "Adapters"). It replaces SKILL.md Phase 1 steps 3–4, Phase 2 and Phase 3 step 2; Phase 1 steps 1–2, the acceptance check and Phase 4 apply as written.

## Plan

The proposal's `affected artifacts` must name:

- `.claude/skills/<adapter>/SKILL.md` in the course repo (adapters are per course, not global), named for the stack.
- `COURSE.md`: the stack's row in "Lab stacks", its column in the lab contract mapping, and its row in "Artifact types and build skills".

Ask before adding either where the proposal leaves it out. Lab files it names (harness, CI workflow, a first lab) are built after the adapter, through the adapter. The toolchain, test runner and CI setup come from the proposal's `proposed change` and its `sources`; a choice without a source goes back to `/course-design` for `/research`. Present the plan and ask about branching as in SKILL.md Phase 1 step 4. Done when the user has answered.

## Build

1. Load `writing-for-agents`; where it is not installed, stop and say so. The adapter is model-invoked: its description names the stack's lab files and test runner.
2. Read an adapter skill `COURSE.md` names for another stack as the worked example and mirror its shape (files, running tests, CI, authoring order, style, checklist). With no other adapter, build from `lab-contract.md` alone.
3. Add a `## Lab contract` section to the adapter: one line per part of `lab-contract.md` saying how the stack meets it (the method and the command). The paths live in `COURSE.md`.
4. Add the `COURSE.md` rows in the existing stacks' shape.
5. Build any lab files the proposal names by following the new adapter.

Done when the adapter and `COURSE.md` rows exist and `git status --porcelain` lists only planned files.

## Verify

- Every part of `lab-contract.md` has a line in the adapter's `## Lab contract` section and a cell in the `COURSE.md` mapping, each cited as `path:line`.
- Where lab files were built, run the new test runner: the reference solution scores full marks and the unfilled student template scores less on every task.

Done when each check is marked `met` with evidence or `not met` with the gap.
