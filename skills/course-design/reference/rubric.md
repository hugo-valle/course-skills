# Rubric

Backward design and constructive alignment are the spine: outcomes first, then the evidence that shows them, then the activities that prepare students for it. Workload and accessibility checks follow. Ideas from Quality Matters may be cited; its rubric is not reproduced.

Each criterion yields a finding or "met: <evidence>".

## Backward design and alignment

1. **CLO coverage.** Every CLO is addressed by at least one module objective, and by an assessment, not only by lecture content. Build the CLO trace table; a CLO with one weak link is a finding.
2. **Objective-to-assessment alignment.** Every module objective has an assessment item (quiz, exercise, lab, discussion, exam) that measures the verb the objective uses ("write" needs a task that writes, not a recognition question).
3. **Activity-to-objective alignment.** Every activity (exercise, discussion, follow-along) serves a stated objective. An activity serving none is a finding.
4. **Assessment mix.** The weighted mix in the syllabus matches the CLO verbs: performance CLOs have performance assessments, and weights reflect importance.
5. **Progression.** Prerequisites between modules are explicit; later modules use earlier skills; cognitive level rises across the term.
6. **Syllabus consistency.** The syllabus agrees with itself and with the repo: numbering, assignment lists, due-date cadence, required software, listed labs versus labs that exist.

## Workload and pacing

7. **Per-module load.** Build the workload table (below). Compare each module row with the per-module workload target in `COURSE.md`; with no target, compare it with the course median. Flag modules well above the target or their neighbours.
8. **Term rhythm.** Lay the module rows on the `COURSE.md` cadence. Compare the term-total row with a term target from `COURSE.md`, or report it as "target unknown". Releases, deadlines and exam weeks leave recovery time; lab weights progress as the syllabus claims.
9. **Manual and external stages.** `COURSE.md` splits manual stages into student-facing and production. Each student-facing stage is a step in the module sequence the student follows (for example: watch the video, do the exercise, take the quiz, post to the discussion) and a column in the workload table. Each production stage gates the release of the steps it delivers. A step out of order, missing, or delivered by an undone production stage is a finding.

### Workload table

One row per module in the `COURSE.md` layout, including modules with no content, plus a term-total row. One column per artifact type and per student-facing manual stage, in module-sequence order so the table also shows the flow, then estimated student hours.

- A repo cell is a count (files, words, questions, tasks) with the command or `path:line` that produced it.
- A manual-stage cell is what the repo shows about that stage (a video link, a quiz export), or `manual: not in repo`.
- Hours come from reported time in student data or from a `/research` source. Without either, state each assumed rate once above the table; every proposal that rests on those hours is `design judgment`.

## Accessibility and UDL

10. **Multiple means of representation.** Key content appears in more than one form (text, figure, video, worked example); figures have text alternatives.
11. **Multiple means of engagement and action.** Students can choose among ways to practise and show mastery; help paths are stated early.
12. **Technical access.** Required tools are free, documented and usable on common platforms; the syllabus states the accessibility contact.

## Currency

13. **Field currency.** The language or platform taught, the tooling, the textbook edition and the online pedagogy are still current. Answer each "is this still current?" question through `/research` (SKILL.md, Phase 2).

## Labs

14. **Lab contract.** Each lab stack in `COURSE.md` meets every part of the lab contract (the `course-implement` skill's `reference/lab-contract.md`) through its `COURSE.md` mapping, checked against each lab folder. A stack with no adapter skill, a part with no file, or a missing item from the recommended set (`lab-stacks.md`) is a finding.

## Student data

Student data (grades, survey feedback) is optional. When given, it is evidence for Objective-to-assessment alignment (item results per objective), Per-module load and Term rhythm (reported time and late work), and Multiple means of engagement and action (survey feedback). Without it, those criteria run on repo evidence alone.
