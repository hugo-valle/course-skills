---
name: quiz-authoring
description: Rules for writing and editing quiz banks in text2qti format, with the course's file names, question types and coverage target read from COURSE.md. Use when creating or editing quiz .md files under the course's quiz root, adding questions, checking coverage per learning objective, building a QTI .zip, or editing quiz reference sheets.
---

# Quiz authoring

Course details come from `COURSE.md` at the repo root: "Quizzes" (conventions doc, file names, kinds, question types, coverage target, outcomes file, reference sheets), the quiz title rule in "Course style rules", and the rebuild command in "Module layout". Read them first. If `COURSE.md` has no "Quizzes" section, ask the instructor for it before writing questions.

## File and header

- Name the file as "Quizzes" says.
- Line 1: `Quiz title: ` followed by the title the course style rule gives.
- Line 2: `Quiz description:` followed by a one-line description.

## Questions

- Number sequentially: `1.`, `2.`, …
- Right after the stem, a `...` feedback line that explains *why* the answer is right.
- Mark the correct option with `*`: `*a)`.
- Stems may use Markdown, code blocks, LaTeX between `$` and images.
- Mix multiple choice, true/false and scenario questions; avoid easy-format-only banks.

## Question types

Draw from the kinds and question types in "Quizzes". Suggest those types by name when planning or reviewing a bank, and say which learning objective each question tests.

## Coverage

Meet the per-objective coverage target in "Quizzes". Objectives are in the syllabus ("Syllabus"). Keep the module's outcomes file, if "Quizzes" names one, in step with the objectives.

## Constants

Any constant a question needs goes in the stem or in the module's reference sheet ("Quizzes"). Do not make students recall it.

## Build

Run the rebuild command from "Module layout" on the quiz file to produce its QTI `.zip`. The `.zip` is generated: rebuild it after every edit. A quiz that fails to build will not import, so fix its source until it builds.
