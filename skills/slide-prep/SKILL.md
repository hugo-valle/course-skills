---
name: slide-prep
description: Generate a module's SlideKraft slides file (moduleNN_slides.md) from its lecture notes, word for word, with over-budget sections split, figures placed, Demo slides added and Knowledge Check slides carried over from the latest SlideKraft export. Plans first and waits for approval, then checks the file against a measured slide budget and for coverage of the notes. Use after /add-images and before importing into SlideKraft, or when asked to make, rebuild or prepare slides for a module.
---

# Slide Prep

Generate `moduleNN_slides.md`, the **slides file** the instructor imports into SlideKraft. It sits in the module's lecture-notes folder (the root `COURSE.md` gives under "Module layout", here written `<notes>/moduleNN/`) and is built from the module's notes there, `moduleNN_N_*.md` (the digit after the module number marks a notes file), which it never changes. The unit of work is one module.

The notes follow the shared convention: an overview file (`moduleNN_1_*.md`) with Required Readings, Module Roadmap and Hands-On Exercises tables, then numbered lecture files. Course details (folders, modules with no content, front matter, code exercise extensions, git workflow) come from `COURSE.md` at the repo root.

Reference files in `reference/` (relative to this skill):

- `format.md`: the slides file syntax, with excerpts from the instructor's SlideKraft export. Follow it exactly.
- `terms.md`: the vocabulary used below (slides file, slide budget, seam, lead-in, continuation slide, figure group, grid slide, Demo slide, Knowledge Check slide, notes-only section, coverage, flagged block).
- `check_budget.py`: the checker. It measures; you do not estimate. Run it from the course repo root, by its path in this skill's folder (`<skill>` below: the base directory shown when the skill loads, normally `~/.claude/skills/slide-prep`):

```bash
python3 <skill>/reference/check_budget.py <notes>/moduleNN/moduleNN_slides.md
python3 <skill>/reference/check_budget.py --coverage <notes>/moduleNN/moduleNN_slides.md <notes>/moduleNN/moduleNN_[0-9]_*.md
python3 <skill>/reference/check_budget.py --self-test
```

The budget values and the notes-only list live at the top of `check_budget.py`. Change them there only, and run `--self-test` after.

## Rules

- **Never reword.** Every body line of the notes, outside notes-only sections, goes into the slides file word for word and in order. Only figure groups may move. A flagged block is reported to the user, not cut.
- **Never edit the notes**, a `.slides` file (app-managed JSON) or the instructor's SlideKraft Markdown export. Content fixes go through `/review-module`.
- The export is a format and placement reference only. Its wording is stale: take no text from it except the Knowledge Check blocks.
- Line numbers come from the checker or `cat -n`, never from estimation.
- Never branch, commit or open PRs. Stop at a clean working tree (see Done).

## Building the slides file

- **Front matter and dividers.** Front matter as in `format.md`: its `title` is the overview's `#` heading, the other fields come from `COURSE.md` ("Slides"). Each other notes file's `#` title (`# Lecture N: …`) becomes a divider slide, in file order.
- **One section, one slide.** Each `---` section of the notes becomes a slide. Its first heading becomes the `#` slide title. A section that opens with a `###` subheading continues the last `##` title: the slide is titled `<Title>: <subheading text>` and the subheading line stays in the body. Other subheadings stay in the body at their own level.
- **Notes-only sections are left out**, as listed in `terms.md`, along with the metadata lines under the overview's title. A section that is not notes-only but has no counterpart in the export is kept, and the plan asks about it.
- **Splitting** a section the checker reports:
  - Break only between blocks: never inside a list, table, code block, math block or paragraph.
  - Seams are before a `###` subheading, before a bold lead-in line, before a code block or table, and between paragraphs. Take the **latest seam** that brings the first part within budget, then repeat on the rest.
  - **Lead-ins stay attached.** A seam never falls right after a heading or a paragraph ending in `:` (including a bold label such as `**Cycle 5 (…):**`).
  - No continuation slide under ~3 rendered lines: move the seam earlier, or leave the section as it is.
  - Continuation titles: `<Title>: <label>` when the part starts at a subheading or bold label (the label is the subheading text or the bold text, without a trailing `:`). Otherwise `<Title> (cont.)`, or `(…, cont.)` merged into a parenthesis the title ends with.
- **Figures.** A figure group is the image line and its caption; never separate them. The intro sentence ("The figure below …") stays with the text. A figure group that sits right at a split joins the part after it. Then, for each figure:
  - If the rest of its slide is ≤ 8 full-width rendered lines and has no code block or table wider than 45 characters, the slide becomes a grid slide, `# [2+2] <Title>`: the text in the first `:::` group, the figure group in the second (see `format.md`).
  - Otherwise the figure group moves to a new `# <Title> Diagram` slide right after the section's last part.
  - Image paths stay `images/…svg`: the slides file sits next to the notes.
- **Demo slides.** One per row of the overview's Hands-On Exercises table, in the `format.md` form. Link to the exercise file in the module's folder under the exercise root `COURSE.md` gives, relative to the slides file (`../../<exercises>/moduleNN/<file>`). The description and the `# Demo: …` title are the exercise's own title (its first `#` line, without `Exercise: `); code exercises (the extensions `COURSE.md` lists under "Slides") use `# Code Demo: …`. Place it right before the Key Takeaways slide of its companion lecture (the last one named, if the row names two). A row with no lecture (for example "Lab N Preparation") goes where the export has it, else at the end of the summary lecture; say so in the plan.
- **Knowledge Check slides.** Copy each question slide from the latest export unchanged (the newest `.md` in the module folder with front matter, other than the slides file). Place it after the slide that holds the last body line of the content slide it followed in the export (skipping Demo slides), found word for word; if none is found, after the slide with the same title (ignoring case, a grid prefix and a trailing `?` or `:`). If that slide has a Diagram slide, place it after the Diagram slide. Consecutive questions stay together. List any you cannot place. If there is no export, there are no Knowledge Check slides.

## Phase 1: Plan (stop for approval)

1. Read `COURSE.md`: the lecture-notes and exercise roots, the modules with no content, and the "Slides" section. If it is missing, or has no "Slides" section, stop and say so. Zero-pad `NN` (`9` → `09`). If the module has no content per `COURSE.md`, or `<notes>/moduleNN/` has no notes files, stop and say so.
2. Read the notes with `cat -n`, the overview's Hands-On Exercises table, each exercise's title, and the latest export.
3. Build a draft slides file in the scratchpad (one slide per section, no splits) and run the checker on it.
4. Show the plan in chat (do not save it to the repo):
   - sections dropped as notes-only, and sections you are asking about
   - one table per lecture: *slide*, *rule broken*, *break before line*, *new titles*
   - each figure: grid slide or Diagram slide, and why
   - Demo slide and Knowledge Check placements, and any Knowledge Check you cannot place
   - sections you cannot split within the rules, and FLAG lines ("needs your decision": block, size, limit)
5. **Stop.** Wait for the user to approve or edit the plan.

## Phase 2: Generate

Write `<notes>/moduleNN/moduleNN_slides.md` from the approved plan, replacing any earlier version.

## Phase 3: Verify

1. Run the checker on the slides file. Every reported slide must be fixed, or be one the plan left as is. FLAG lines may remain: they are the blocks the user decides on.
2. Run `--coverage` against the notes. It must print `covers the notes`. Anything else means a line was dropped, reworded or moved: fix the slides file and rerun.

## Done

Report:

- the slides file and its slide count
- flagged blocks still over budget, with `path:line`, size and limit, for the user to shorten in the notes
- slides left over budget and why
- Knowledge Checks not placed, and sections asked about
- the checker's final output and the coverage result
- "Import `moduleNN_slides.md` into SlideKraft. Do the final layout tuning there."

Remind the user that the course's git workflow applies (the skill and tracker doc `COURSE.md` names under "Pointers").
