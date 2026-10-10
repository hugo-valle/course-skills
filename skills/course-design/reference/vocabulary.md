# Vocabulary

Workflow terms for `/course-design`. They live here, not in a course glossary, which holds course vocabulary only.

**Finding**:
What is wrong or missing in existing content. Comes from `/review-module` for one module, or from the rubric for the whole course.

**Proposal**:
An approvable change that answers one or more findings. Has every field in `proposal-template.md`. Drafted in chat; published as a child issue once approved.

**Design review**:
One run of `/course-design` over the course. Produces proposals. Once approved, it is published as an umbrella issue.

**Umbrella issue**:
The `course-level` issue for one design review. Its children are the approved proposals.

**CLO trace**:
The table mapping each course learning objective to the modules, assessments and activities that address it.

**Workload table**:
One row per module plus a term total, one column per artifact type and student-facing manual stage, with estimated student hours. Defined in `rubric.md`.

**Lab stack**:
One language and toolchain for labs, declared in `COURSE.md` with its adapter skill. Checked against the lab contract (the `course-implement` skill's `reference/lab-contract.md`, which also defines **adapter**).

**Recommended set**:
The skills, subagent and integrity policy a complete lab pipeline has for one stack. Listed in `lab-stacks.md`.

**Evidence-based**:
Every repo claim in the proposal has a `path:line` and every field claim has a cited source.

**Design judgment**:
The proposal rests on the designer's reasoning, or on a field claim with no source. Its text states such a claim as the designer's opinion, never as fact.
