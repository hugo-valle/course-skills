---
name: course-content
description: Layout of a course repo's content folders (lecture notes, exercises, discussions, quizzes) and which files are source vs generated, read from COURSE.md. Use when editing or adding course content, when a generated file (quiz .zip, exercise .html, slides file, figure SVG) may be stale and need rebuilding, or when checking terminology against the course glossary.
---

# Course content

Every course fact here comes from `COURSE.md` at the repo root. Read it first. If it is missing, stop and suggest `/course-design`, which drafts it.

The syllabus ("Syllabus") holds each module's learning objectives, the reference point for all content. Modules share one numbering across every artifact root. Modules with no content (exam weeks) are listed under "Module layout"; never create content for them.

## Source vs generated

The "Module layout" table names, per artifact, its root, its source files and its generated files, followed by any per-artifact notes. Edit only source files. Never hand-edit a generated file: change its source and rebuild it.

## Stale outputs

After editing a source file, rebuild its output:

- quiz and exercise sources: the rebuild command in "Module layout". Rebuild only the files you changed when a generated file stamps its build time (a quiz `.zip` does), so unchanged ones do not churn.
- lecture notes → the module's slides file: `/course-slides NN`
- figure sources → SVGs: `/course-images NN` (it owns the figure build)

## Figures and slides

Use `/course-images NN` for figures ("Figures" in `COURSE.md`) and `/course-slides NN` for the slides file ("Slides").

## Discussions

The discussion platform and the structure every discussion follows are in "Course style rules" (the discussion rule) and the conventions doc it names. A new discussion follows that structure and ties to the module's own concepts.

## Terminology

The glossary is under "Pointers". Check new or edited text against its preferred terms and the ones to avoid.

## Reviewing and publishing

- `/course-review NN` reviews one module's notes, quizzes, exercises and discussion.
- Material marked under "Sources" or "Pointers" as git-ignored is never quoted at length or staged.
- Changes go through issue → branch → PR (`course-workflow`).
