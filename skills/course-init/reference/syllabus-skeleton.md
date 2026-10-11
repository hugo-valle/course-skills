# Syllabus skeleton

The headings a new syllabus uses, so `COURSE.md` "Syllabus" can name them and `/course-design` can trace every objective to a CLO. Keep these headings and their order; the course's other prose (philosophy, delivery, project, policies) goes in sections of its own before the CLOs or after "Grading". `<…>` is filled from the interview; a fact nobody has given stays `unknown: <question>`.

```markdown
# <Course number>: <Title> (<credits> credits)

<Term, modality, meeting pattern. One paragraph on what the course is for.>

## Course Learning Outcomes (CLOs)

By the end of the course, students will be able to:

1. <CLO1, one observable verb per outcome>
2. <CLO2>

## Schedule

| Weeks | Module | Topic |
|---|---|---|
| <1–2> | <1> | <title> |
| <13–15> | — | <project or exam: no module content> |

## Modules

### Module N: <title>

<Weeks. One sentence on the module's central question.>

#### Module N Learning Objectives

1. <objective> (CLO<k>)

#### Module N Required Readings

- <source name, chapter or section, or URL> (manifest id `<id>`)

#### Module N Assignments

- <quiz, lab, exercise or deliverable>

## Grading

| Component | Weight |
|---|---|
| <component> | <n>% |
```

Rules:

- Number CLOs and objectives; every objective names at least one CLO, and every CLO is named by at least one objective.
- A reading names the source as it will appear in the sources manifest (`instructor_material/README.md`), so reviewers can find it.
- Weeks with no module content (exams, for example) either get a module number with no objectives, or `—` as their module in the schedule. Numbered ones are the "Modules with no content" in `COURSE.md`.
