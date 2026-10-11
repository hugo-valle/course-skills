---
name: course-design
description: Evaluate a whole university course against its syllabus with backward design and constructive alignment, then draft change proposals in chat. Use when asked to design, audit or improve a course as a whole, check CLO coverage across modules, or review course flow, workload and accessibility.
---

# Course Design

Evaluate the whole course and draft proposals. Edit nothing except a user-confirmed `COURSE.md` (Phase 1). Phases 1–3 live in chat and publish nothing. Phase 4 publishes issues, and only after the instructor approves.

Invocation: `/course-design [--scope all|<module list>] [--data <path>]`

Reference files in `reference/` (relative to this skill): `rubric.md`, `vocabulary.md`, `proposal-template.md`, `lab-stacks.md`, `course-md.md`.

## Rules

- **Draft first, publish only on approval.** Stop after Phase 3 until the instructor approves proposals by name. Never publish an unapproved proposal.
- Every course-specific path, tool, term and module name comes from `COURSE.md` at the repo root. Add no course-specific detail to this skill.
- Every claim about the course carries `path:line` from `grep -n` or `cat -n`; never estimate a line.
- A claim about the field (rubric.md, "Field currency") needs a source found through `/research`. Without one, tag the proposal `design judgment`.
- Student data (`--data`) is optional; the review runs in full without it.

## Phase 1: Load

1. Read `COURSE.md`. If it is missing, draft it per `reference/course-md.md` ("Drafting"); write it only after the instructor confirms (the one file this skill may write). Done when the confirmed file is written; until then, run nothing past this step.
2. Read the syllabus file `COURSE.md` names, then the artifact roots per module.
3. Cross-check `COURSE.md` against the repo: folders exist, labs listed in the syllabus exist, every declared adapter skill exists, and every source language in the lab roots belongs to a declared stack. Record each mismatch as a finding.

## Phase 2: Evaluate

Apply `reference/rubric.md` to the whole course. Each criterion ends on a **finding** with evidence, or an explicit "met: <evidence>". Every CLO and every module is accounted for in the CLO trace, which you present first.

- **Field currency.** List every "is this still current?" question the rubric's "Field currency" criterion raises for this course. Delegate each to `/research`, telling it to save its notes in the session scratchpad; confirm `git status` shows no new file afterwards. Done when every question has an answer with source URLs, or is marked unsourced. Carry the URLs and the check date into the `sources` field of each proposal that rests on them.
- **Workload.** Build the workload table (rubric.md, "Workload table"). Done when every module row and every student-facing manual-stage column is filled, and Per-module load and Term rhythm each end on their comparison.
- **Module drill-down.** Course-level criteria check that artifacts exist and map to objectives. The quality of one item (an objective's wording, a question, a figure's alt text) is module-level and comes only from `/course-review`. For each module the course-level pass flags, run `/course-review NN` through "Phase 3: Merge and report", decline its Phase 4 and its offer to publish an issue, and cite its findings in the proposal's `current state`. Done when every flagged module has a `/course-review` report or the instructor has declined that drill-down.
- **Labs.** For each lab stack, build a contract table: one row per lab folder, one column per lab-contract part, each cell a `path` or `missing`; then list the recommended set (`lab-stacks.md`) as present, deferred or missing. Done when every cell is filled and every stack, including one with no adapter, has its table.
- **Student data.** With `--data`, read it and cite it as `path:line` like repo evidence. Without it, open the trace with one line naming the rubric criteria that ran on repo evidence alone (rubric.md, "Student data"). Done when that line is present or every data file is cited.

## Phase 3: Propose

1. Turn findings into **proposals** using `reference/proposal-template.md`. One proposal per approvable change; group findings that share one fix.
2. Size structural proposals (see `proposal-template.md`) `L` and mark them blocked on "instructor decision".
3. Present the proposals in chat: the trace table, the workload table, then proposals ordered by effort and dependency.
4. Done when every proposal carries every template field and the user has seen the list. Ask which to refine and which to approve. Approved proposals go to Phase 4; nothing is published before then.

## Phase 4: Publish (after approval only)

Run only when the instructor has said which proposals are approved. Conventions are in the tracker doc `COURSE.md` names ("Design reviews"). Show the issue list (titles, labels, blocked-by edges) and wait for a go-ahead before the first `gh` write.

1. Create one umbrella issue titled `Design review <Term YYYY>`, labelled `course-level`, with the CLO trace and the workload table in the body.
2. Create one child issue per approved proposal: the full template as the body, labelled `course-design` plus its status label. Link each child to the umbrella as a sub-issue.
3. Add a native blocked-by edge for each "blocked on" entry that names another proposal.
4. Add the children to the umbrella body as a task list (`- [ ] #N title`) using the real issue numbers, then report the links.

Status labels and the rule for structural (`L`) proposals are in the tracker doc.

Terms (finding, proposal, design review) are defined in `reference/vocabulary.md`.
