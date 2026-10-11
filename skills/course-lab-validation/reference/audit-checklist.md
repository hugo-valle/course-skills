# Template audit checklist

Run each item on the template repo; report the result per item. Stack commands come from the course's `COURSE.md`.

## README

- Prerequisites: toolchain and runtime versions, plus any dependency on another project's output (for example sample inputs produced by an earlier project), called out by name.
- A table of what the student implements: file, function, number of TODOs.
- Getting started: clone, build, run a sample.
- Running tests: the all-tests command and the single-test command.

## Harness script

- Project and lab names in comments and messages match this lab, not a copy from an earlier one.
- The example or test range matches the CI workflow's range.
- A failing unit-test stage does not stop the later stages: the script records the failure and continues, so a student sees their score before every unit test passes.

## CI workflow

- The workflow name matches this lab.
- Triggers include the student branches (`feature/**`) as well as the default ones.
- Ranges in the file-existence checks, the flag and points tables and the scoring loop all match each other and the harness.
- The maximum score is correct and equals the sum of the points.
- Quality steps (format check, linter) do not fail the run.

## Sample and generated output folders

- Not empty: a short README explains the folder holds generated outputs that are git-ignored.

## Student source files

- Every file with a TODO builds; warnings are fine, errors are not.
- Each unimplemented-marker message says exactly what to implement.
- Infrastructure files the student should not touch are fully implemented and exported.
