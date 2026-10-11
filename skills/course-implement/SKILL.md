---
name: course-implement
description: Carry out one approved course-design proposal by routing its changes through the existing build skills, then check its acceptance criteria and review every touched module. Use when asked to implement, build or apply a `course-design` proposal issue, including a `tooling` proposal for a missing lab adapter skill.
---

# Course Implement

Carry out one approved **proposal** (terms in the `course-design` skill's `reference/vocabulary.md`). The proposal issue is the whole scope: its `affected artifacts` are the only files you change, and each changes through the build skill `COURSE.md` maps it to.

Invocation: `/course-implement <issue#>`

Reference files in `reference/` (relative to this skill): `lab-contract.md`, `tooling.md`.

## Rules

- **Approved only.** Act on an open issue labelled `course-design` plus an approved status label (tracker doc that `COURSE.md` names, "Design reviews"). Anything else: stop and say which label is missing.
- **Scope is the proposal.** Change only the files the Phase 1 plan resolves from its `affected artifacts`, plus the generated files their build skills rebuild. Each artifact goes through its build skill: load that skill and follow its rules before the first edit.
- **One proposal per run.** When the work turns out to need a syllabus or module-structure change the proposal does not name as its `type`, stop that part and draft it in chat as a new proposal in the shape of the `course-design` skill's `reference/proposal-template.md`, for the instructor to send through `/course-design`.
- **A new lab stack's tooling comes from a `tooling` proposal.** A lab artifact whose stack has no adapter skill in `COURSE.md` has no build skill: stop that part and draft a `tooling` proposal in chat, as for a structure change. The adapter, then its harness and CI, are built only under that proposal once approved.
- **Manual stages stay "to do".** You can see only the repo. List every manual stage as still to do; the instructor marks them done.
- **Git only on go-ahead.** Branch and commit only after the user says so, through `course-workflow`.
- Every course-specific path, skill and stage comes from `COURSE.md`. Add no course-specific detail to this skill.

## Phase 1: Load

1. `gh issue view <n> --json number,title,body,labels,state,comments`. Check the Approved rule. Check open blockers with `gh api repos/{owner}/{repo}/issues/<n> --jq .issue_dependencies_summary.blocked_by` (or the `Blocked by:` line); any open blocker, or a `blocked on` field still naming "instructor decision" with no comment recording the decision, stops the run.
2. A `tooling` proposal that adds an adapter skill for a stack with none: follow `reference/tooling.md` from here. Any other `tooling` proposal: stop and say this skill builds only missing adapter skills.
3. Read `COURSE.md`. Parse every template field. For each affected artifact, find its row in "Artifact types and build skills"; where the proposal's `build skill` disagrees with `COURSE.md`, ask which wins.
4. Present the plan: one row per affected artifact with its build skill and the exact files to change, then the acceptance check. An artifact named only by type (for example a whole artifact root) resolves to the specific files the `proposed change` and `current state` cite; ask where they do not settle it. The plan's file list is the scope. Ask whether to branch now (`course-workflow`, branch named for the issue) or work in the current tree. Done when the user has answered.

## Phase 2: Build

Work artifact by artifact in dependency order (source before figures before slides). For each, invoke or load its build skill and run it on just this artifact. Pass the proposal's `proposed change` as the instruction. Where a `COURSE.md` row chains the git workflow skill after a build skill, run only the build part now; git waits for Phase 4. A build skill that plans and waits for approval (for example a figure or slide plan) shows its plan to the user as usual.

Done when every affected artifact is changed or reported unchanged with a reason, and `git status --porcelain` lists only files in the plan or files their build skills generate. Report any other path and ask before keeping it.

## Phase 3: Verify

1. **Acceptance check.** Test each condition in the proposal's `acceptance check`. Mark each `met` with evidence (`path:line` from `grep -n`, or a command and its output) or `not met` with the gap. A condition that needs a manual stage is `pending: <stage>`.
2. **Module review.** The touched modules are the per-module folders (`COURSE.md` "Module layout") among the changed paths. Run `/course-review NN` on each through its "Phase 3: Merge and report". Findings on files this proposal changed go through its Phase 4 with the user's approval; offer to publish the rest through its issue option. Changed lab files are verified instead by their stack's test runner from `COURSE.md`: run it, and confirm each part of `reference/lab-contract.md` still maps to a file.

Done when every acceptance condition has a mark and every touched module has a review report (or test result).

## Phase 4: Report

Present, in order:

1. Changed files, grouped by artifact and build skill.
2. The acceptance table from Phase 3.
3. Review findings: applied, published, or left with the user.
4. **Manual stages still to do**: each stage in `COURSE.md` "Manual stages (outside the repo)" that applies to an artifact this run changed, as an unchecked list (`- [ ] <stage>: <changed file>`). Name the stages that do not apply in one line.

Then ask for the go-ahead to commit and open a PR through `course-workflow`, with `Closes #<n>` in the body and the manual-stage list copied into it. Done when the user has answered; on a no, stop at the working tree.
