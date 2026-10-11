# Slide Prep Terms

**Slides file**: `moduleNN_slides.md` in the module's lecture-notes folder, generated from the module's notes (`moduleNN_N_*.md`) in the format of `format.md` and imported into SlideKraft. Generated: rebuild it with `/course-slides NN` whenever the notes change; never hand-edit it as a source.

**Slide**: the text between two `---` dividers in the slides file. SlideKraft imports one as one slide. Every slide title is a level-1 `#` heading.

**Notes-only section**: a notes section that never goes on a slide: Required Readings, Module Roadmap, Hands-On Exercises, Module Assignments, Industry Skills Focus and More Resources (the `NOTES_ONLY` set in `check_budget.py`), plus the metadata lines under the overview's `#` title.

**Block**: a unit the checker measures and a split never breaks: a heading, paragraph, list, table, code block, math block, figure (image line), caption or `:::` group marker.

**Slide budget**: the most a slide may hold. The limits are the constants at the top of `check_budget.py` (measured from a real SlideKraft deck; change them only there). The checker measures:

- **rendered lines**: a paragraph, or a list item with the text indented under it, counts one line per 90 characters (45 in a grid cell); a table row, code line or math line counts one; headings, images and captions count zero
- **bullets**: list items, nested ones included
- **code block lines** (fences excluded; a higher limit when the code block is the slide's only content) and **table body rows** (header excluded)
- **figures**, and the rendered lines beside a figure on a full-width slide
- **continuation lines**: the rendered lines in a `(cont.)` slide

Front matter, divider slides, Demo slides and Knowledge Check slides are not measured.

**Seam**: a place between two blocks where a section may be split: before a `###` subheading, before a bold lead-in line, before a code block or table, or between paragraphs. Never right after a **lead-in**: a heading or a paragraph ending in `:`, which stays with the block it introduces.

**Continuation slide**: a slide created by a split. Titled `<Title>: <label>` when it starts at a subheading or bold label, otherwise `<Title> (cont.)`, or `(…, cont.)` when the title already ends in a parenthesis.

**Figure group**: an image line and its `*Fig. M.N*` caption. The only content that may move out of order. Its intro sentence ("The figure below …") is not part of it and stays with the text.

**Grid slide**: a `# [2+2] <Title>` slide with the text in one `:::` group and the figure group in the next. Each cell is measured at 45 characters per line.

**Diagram slide**: a `# <Title> Diagram` slide that holds only a figure group, right after the text it belongs to.

**Demo slide**: a `right-aside` slide that points at one hands-on exercise, placed before its companion lecture's Key Takeaways.

**Knowledge Check slide**: a `left-aside` slide holding a SlideKraft question block (```` ```question … ```` with a question ID). Copied unchanged from the latest SlideKraft Markdown export; never written by the skill.

**Coverage**: the slides file carries every notes body line outside notes-only sections, word for word and in order (only figure groups may move). `check_budget.py --coverage` checks it and lists missing, reworded, out-of-order and added lines. Heading levels and grid prefixes are ignored, and titles made from a notes heading (continuation, label and Diagram titles) do not count as added.

**Flagged block**: a single block that breaks the budget by itself, such as a 16-line code block next to text or an 11-item list. Splitting cannot fix it, so the skill reports it (a `FLAG` line) and the instructor decides how to shorten it in the notes. FLAG lines never change the checker's exit code.
