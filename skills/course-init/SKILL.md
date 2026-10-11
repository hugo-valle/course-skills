---
name: course-init
description: Set up a new course repo so the global course skills work in it. Copies the course-skills template, interviews the instructor and drafts the syllabus (CLOs, modules, objectives, readings), drafts COURSE.md, creates the module folders and writes the sources manifest. Use when starting a new course, or when asked to initialise, bootstrap or set up a course repo that has no COURSE.md.
---

# Course Init

Set up one new course repo, run from its root. Five phases; each is shown as a draft in chat and written only after the instructor confirms it.

Invocation: `/course-init`

Reference files: `reference/syllabus-skeleton.md` (relative to this skill); the `course-design` skill's `reference/course-md.md` (COURSE.md sections and drafting rules) and `reference/lab-stacks.md` (seed lab tooling); the `course-review` skill's `reference/extract-sources.sh`. The template is the `template/` folder of the course-skills repo this skill lives in (`<skill>/../../template`, where `<skill>` is the base directory shown when the skill loads; resolve it with `realpath`).

## Rules

- **Draft, confirm, write: one phase at a time.** Show the phase's draft, wait for the instructor's go-ahead or corrections, write, then start the next phase. Never write ahead.
- **Never overwrite without asking.** A file that already exists is shown with the change as a diff and asked about. An existing draft syllabus (the root `README.md`, a `syllabus*` file) is the starting point for Phase 2, never discarded.
- **Never invent course facts.** CLO wording, readings, grading weights, dates and lab tools come from the instructor or the existing draft. A fact neither gives stays `unknown: <question>` in the draft.
- **Course detail goes into the course repo, never into this skill.**
- `instructor_material/` holds copyrighted sources: never stage it.
- Never commit or push. Stop at the working tree; the first commit goes through `course-workflow`.
- If this skill was found, `install.sh` has already linked the shared skills into this repo. Its `.gitignore` lines come with the template (Phase 1).
- If `COURSE.md` already exists, stop: the course is set up. Suggest `/course-design` instead.

## Phase 1: Copy the template

1. Check the root is a git repo (`git rev-parse --show-toplevel`) and list what it already holds (`git status --short`, `ls -A`). Read any draft syllabus now.
2. Draft: the template files to copy (`find <template> -type f ! -path '*/__pycache__/*'`), minus the template's own `README.md`; each that already exists in the repo, with its diff; and the edits to `docs/agents/` (it is a worked example from another course: replace its glossary file name, example terms and module names with this course's, or `unknown:`).
3. On confirmation copy without overwriting, then merge `.gitignore` lines the repo lacks and install the hooks:

   ```bash
   rsync -a --ignore-existing --exclude /README.md --exclude __pycache__ <template>/ ./
   ./scripts/install-hooks.sh
   ```

   Done when `git config core.hooksPath` prints `.githooks` and `git check-ignore -q instructor_material/x` succeeds.

## Phase 2: Interview and draft the syllabus

1. Interview the instructor. Ask with `AskUserQuestion` where the answer is a choice, in plain chat where it is wording. Skip any question the draft syllabus already answers, and quote the line you took it from. Cover:
   - course number, title, credits, term, modality and meeting pattern
   - course learning outcomes (CLOs)
   - the modules in order, their weeks, and which weeks are exams or projects (modules with no content)
   - per module: learning objectives, each tied to one or more CLOs; required readings; assignments
   - grading weights and policies
   - **labs:** language, toolchain and test runner per lab stack (offer the `course-design` skill's `reference/lab-stacks.md` rows as options), and which module carries each lab. "No labs yet" is a valid answer.
   - **sources** the reviewers check claims against: books (PDF files the instructor will put in `instructor_material/`) and official web documentation (URLs)
2. Draft the syllabus in the structure of `reference/syllabus-skeleton.md`, keeping the draft's own prose (philosophy, schedules, project descriptions) under the skeleton's headings or in its extra sections. Save the whole draft in the session scratchpad. Show in chat what is new (CLOs, each module's objectives, readings and assignments, grading) and what moved or was dropped, with the scratchpad path, then the open `unknown:` questions.
3. On confirmation write it to the syllabus file (default: root `README.md`). If that file holds a draft, show the diff and ask whether planning material the syllabus drops moves to `docs/` or is deleted.

## Phase 3: Draft COURSE.md

1. Draft `COURSE.md` by the `course-design` skill's `reference/course-md.md`: every section in order, filled from the confirmed syllabus, the interview and the copied template, following its "Drafting" steps. Artifact roots default to the template's (`lecture_notes/`, `quizzes/`, `hands_on_exercises/`, `discussions/`, `labs/`); ask which of them this course has.
2. Write it when the instructor confirms (the `course-md.md` "Drafting" step 3).

## Phase 4: Module folders

1. Draft the tree: `moduleNN` (zero-padded) under each per-module artifact root in "Module layout", for every module except the modules with no content, and lab folders only if the instructor wants them now. Also draft the `MODULES` list in `scripts/new_semester.sh`.
2. On confirmation create each folder with an empty `.gitkeep` (git does not track empty folders) and set `MODULES`.

## Phase 5: Sources

1. Draft `instructor_material/README.md`: a one-paragraph header (as in `COURSE.md` "Sources"), then the manifest table `| id | kind | location | name |` with one row per source from the interview. `id` is letters, digits, `-` or `_`; `kind` is `pdf` (location relative to the folder) or `url` (one page: prefer the documentation page the notes will cite over a product home page, and tell the instructor a landing page gives reviewers little to check against); `name` is how findings cite it and matches the course edition in `COURSE.md`.
2. On confirmation write it. A `pdf` row whose file is not in the folder yet stays out of the table (the extractor stops on a missing file); list it under a `Pending:` line below the table and tell the instructor to copy the file in and move the row up.
3. Snapshot the web docs: run the `course-review` skill's `reference/extract-sources.sh` from the repo root. Done when it exits 0. If a fetch fails, show the message and ask whether to fix the URL or drop the row.

## Done

Run these and show their output:

```bash
git check-ignore -q instructor_material/README.md && echo "instructor_material ignored"
git status --short                                          # instructor_material/ must not appear
git commit --allow-empty -qm wip 2>/dev/null; [ $? -eq 1 ] && echo "hook rejected a bad message"
echo "refs/heads/main 0 refs/heads/main 0" | .githooks/pre-push origin x 2>/dev/null; [ $? -eq 1 ] && echo "pre-push blocks main"
python3 scripts/test_rebuild_module.py
```

Build one sample quiz with the rebuild command `COURSE.md` names (a two-line text2qti file, one multiple-choice question, in the first module's quiz folder), check its `.zip` exists, then delete both files.

Then run the cross-check from `/course-design` Phase 1 ("Load": `COURSE.md` against the repo: folders, labs, adapter skills, lab languages) and report its mismatches, if any. List every `unknown:` left in the syllabus and `COURSE.md`, every pending source, and the next step: open an issue and make the first commit through `course-workflow`.
