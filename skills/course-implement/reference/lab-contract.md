# Lab contract

What every lab must have, whatever its language. `/course-design` checks each lab stack in `COURSE.md` against it; an adapter skill builds labs that meet it.

| Part | Meets it when |
|---|---|
| Reference solution | A complete instructor solution exists per lab and passes its own tests at full marks. |
| Student template | A starter derived from the solution with the solution removed. |
| Test harness | An automated runner scores each task. |
| CI job | The harness runs in CI on every pull request that changes the lab's files. |
| Per-task rubric | Each task has points and traces to a CLO, stated in the rubric or in the stack's `COURSE.md` mapping. |

## Adapters

An **adapter** is the skill that authors and tests one stack. `COURSE.md` names it in the lab stacks table and maps each contract part to a path for that stack. An adapter written before this contract stays unchanged; its `COURSE.md` mapping registers it. A stack with no adapter skill is a gap.

## Why these five parts

Solution and template together let the tests show they separate finished from unfinished work. The harness and CI make grading repeatable and catch a broken lab before students see it. The CLO tie keeps labs inside the course's constructive alignment instead of beside it.
