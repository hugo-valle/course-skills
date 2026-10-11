# Style Rubric

The generic standard the Style reviewer applies. Each course adds its own rules (`C1`, `C2`, …) in the "Course style rules" section of its `COURSE.md`: citation form, code formatting, quiz title prefix, discussion platform and structure, and any required sections. A course rule wins over a rule here. Rule IDs are stable; cite them in findings and do not renumber.

## Notes (N)

- **N1** Folder layout: an overview note (`moduleNN_1_overview.md`) plus numbered topic notes (`moduleNN_K_topic.md`). Number sequence has no gaps.
- **N2** Each note starts with one `#` title. The overview is `# Module N: Topic`; topic notes are `# Lecture K: Topic`. Lecture numbers match the overview's roadmap.
- **N3** The overview has: a header block naming the course, the source and the required reading; What This Module Is About, Learning Objectives, Required Readings table, Module Roadmap, Hands-On Exercises, Module Assignments.
- **N4** Heading levels do not skip (`##` then `####`). Headings are sentence case or consistent title case within a module; no trailing punctuation.
- **N5** Each topic note ends with `## Key Takeaways`; the final note of a module is a summary with Key Formulas, Connection to Other Modules, Looking Ahead and Before the Quiz.
- **N6** (Course-specific required sections are course rules.)
- **N7** Every fenced code block has a language tag (the course rules list the tags). Code identifiers, commands and names of program elements in prose are in backticks.
- **N8** Units have a space before them (`200 ps`, `5 ns`) and are consistent within a note. Numbers in tables are right-aligned or consistently formatted. Math uses `$…$` LaTeX consistently, not a mix of Unicode and LaTeX for the same expression.
- **N9** Terms are introduced once in **bold** at first use, then used consistently (check the glossary). One name per concept: do not alternate between near-synonyms for the same thing without saying they are related.
- **N10** Figures: `![alt](images/figNN_slug.svg)` with a one-sentence alt text, followed by an italic caption `*Fig. M.N — Title (cf. <citation>)*` with the citation in the course citation form; the prose refers to the figure. Images exist on disk.
- **N11** Citations to sources use the course citation form (`COURSE.md` "Sources") and name the edition consistently across the module.
- **N12** Tone: second person or inclusive "we", instructional, no filler ("simply", "obviously", "as everyone knows"), no marketing language, no unexplained abbreviations at first use.
- **N13** Tables have a header row and no empty cells; blockquote callouts (`> **Study tip:**`) use a consistent label set.
- **N14** No broken relative links, no leftover TODO/TBD/XXX, no stray trailing whitespace runs or tabs in prose, files end with a newline.

## Quizzes (Q)

- **Q1** File name `moduleNN_YY_topic_{practical|theoretical}.md`; `YY` sequential and two digits.
- **Q2** First line `Quiz title: <prefix>-Module N - Topic - Kind Quiz` (the prefix is a course rule); second `Quiz description:` a sentence; blank line after. Title matches the file name's topic and kind.
- **Q3** Questions are numbered `1.`, `2.`, … sequentially; every question has `...` feedback immediately after the stem that explains *why*, not just restates the key.
- **Q4** Single-answer questions have exactly one `*x)` option; multi-answer use `[*]`/`[ ]`; short-answer uses `* answer`; numerical uses `= value`. Syntax matches text2qti exactly.
- **Q5** Options are parallel in grammar and similar in length; no "all of the above"/"none of the above"; no option that is longer or more specific only because it is correct.
- **Q6** Stems are self-contained, end with `?` or a clear instruction, and avoid negatives ("which is NOT") unless emphasised.
- **Q7** The mix per bank follows its kind: practical = apply, theoretical = explain/compare. At least 5 questions per learning objective across the module's banks; avoid easy recall-only banks.
- **Q8** Code in stems uses backticks or code fences; math uses `$…$`.
- **Q9** Reference-sheet dependency: any constant a question needs is either in the stem or listed in the module's quiz reference sheet, if the course has one (`COURSE.md` "Module layout").
- **Q10** Learning objectives in the module's outcomes file are phrased with an observable verb and match the overview note's objectives word for word.

## Exercises (E)

- **E1** File name `moduleNN_K_exercise_topic.md` where `K` is the companion lecture number; solution files live in `solution/` with a `_solution` suffix (code, or `.md` for a worksheet key not kept inline, see E5).
- **E2** Header comment block states title, companion lecture and instructions; the companion lecture exists.
- **E3** Parts are labelled `Part N` / `Na.` consistently; each part states what to fill in and the assumptions it relies on.
- **E4** Code files: header comment with purpose; consistent naming; comments explain intent, not the statement. Language-specific naming rules are course rules.
- **E5** Solutions do not leak into the student-facing exercise file, with one exception: a Markdown self-check worksheet may end with its answer key in a collapsed `<details>` "Check Your Work" block, or keep it in `solution/` instead; both are accepted. Code solutions and keys to graded work always live in `solution/`.

## Discussions (D)

- **D1** Follows the discussion structure in the course rules.
- **D2** The central question is one sentence, phrased so both theses are defensible; it matches the module's entry in the course's discussion index, if there is one.
- **D3** Theses are balanced in length and strength; claims about real systems are specific and checkable.
- **D4** Background is 2–3 sentences and connects to the module's lectures and lab.
