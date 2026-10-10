---
name: add-images
description: Create clean, publishable TikZ diagrams for a lecture module and embed them in its Markdown notes. Reads the module's notes and required readings, proposes a figure plan for approval, then builds SVG figures. Use when asked to add, create or redo figures/images/diagrams for a module's lecture notes.
---

# Add Images

Produce publication-quality figures for one module's lecture notes, in the `images/` folder of the module's lecture-notes folder (the root `COURSE.md` gives under "Module layout", here written `<notes>/moduleNN/`). The unit of work is one module, or one lecture file if the user narrows it. The `.tex` file is the source of truth; the committed output is `.svg`.

Course details (style layer and base copy paths, colour meanings, where the readings are listed, citation form, git workflow) come from `COURSE.md` at the repo root, sections "Figures", "Sources" and "Pointers".

Reference files in `reference/` (relative to this skill): `base.tex`, `example.tex`, `Makefile`, `crop_png.py`, `figure-plan-template.md`.

Tooling: `latex`, `dvisvgm`, `pdflatex`, `mutool` and `python3` with `numpy`. `make preview` needs the last three; if one is missing, say so instead of skipping the visual check.

## Styles: base and course layer

- **Base** (`reference/base.tex`): packages, page setup, the Okabe-Ito palette under neutral names (`cBlue`, `cVermillion`, `cGreen`, `cOrange`, `cPurple`, `cInk`, `cGrey`), and the styles every course shares: `title`, `note`, `callout`, `badge=<colour>`, and arrows `flow` (neutral), `strong=<colour>`, `dashflow=<colour>`. The course keeps a byte-identical copy at the base copy path in `COURSE.md`.
- **Course style layer** (path in `COURSE.md` "Figures"): `\input`s the base copy, names each colour's meaning (for example `\colorlet{cData}{cBlue}`), and holds the course's domain shapes. Figures `\input` only the layer.
- A style any course could use goes in `reference/base.tex` (then copy it to the course's base copy; keep the two identical). A domain shape goes in the course layer. Never redefine a style inside one figure.

## Rules

- Every label and number in a figure comes from the lecture text. Never invent values.
- **Discrepancies:** if the notes contradict each other, the readings table, or a figure's numbers (values, diagrams, citations), do not pick a side silently and do not guess. Ask the user with `AskUserQuestion`: one question per discrepancy, quoting both versions with file and line, with each candidate resolution as an option (recommended first). Ask in Phase 1 before the plan is final, and again whenever drawing or verification turns up a new one. Edit the notes only to apply the user's answer, then regenerate every figure that carried the affected value.
- Figures are original drawings. Use the course textbook's terminology and cite its sections in the citation form `COURSE.md` gives under "Sources"; never reproduce its figures. Cite a specific textbook figure number only if the user has confirmed it; you cannot verify it offline.
- **Colour:** use each colour only with the meaning `COURSE.md` gives it. Never let colour carry meaning alone: add a text label, badge or line style (solid/dashed/dotted).
- Existing `figNN_*` files are never overwritten without asking.
- Only edit the `.md` notes. Never edit the generated files `COURSE.md` lists for the notes (slides files, app-managed `.slides` JSON).
- **Preview files:** `images/.preview/` and the PDFs and PNGs in it are never deleted without asking first. That includes `make clean`, `make distclean` and `rm`. Ask with `AskUserQuestion` (options: keep, delete) and default to keeping them.
- Never branch, commit or open PRs. Stop at a clean working tree (see Done).

## Phase 1: Read and plan (stop for approval)

1. Read `COURSE.md`: the lecture-notes root and notes-file pattern ("Module layout"), the "Figures" section (style layer, base copy, colour meanings, readings, caption citation) and the citation form ("Sources"). If `COURSE.md` is missing, stop and suggest `/course-design`, which drafts one; if it has no "Figures" section, stop and say so. Zero-pad `NN`.
2. Read all notes files, `moduleNN_N_*.md` (not the generated slides file), and the module's readings where `COURSE.md` "Figures" says they are listed.
3. Build the coverage checklist: each reading section and concept maps to a figure or to a stated reason none is needed.
4. Mark figures that already exist in `images/` as "exists".
5. Write the plan from `reference/figure-plan-template.md` (show it in chat; do not save it to the repo). Number figures `figNN_<slug>`.
6. List every discrepancy you found in the plan's Discrepancies section and ask the user to resolve each one (see Rules). Apply the answers to the notes.
7. **Stop.** Wait for the user to approve or edit the plan before writing any TikZ.

## Phase 2: Draw

1. Ensure the base copy exists and matches `reference/base.tex` (`cmp`); if it is missing, copy it there. If it differs, show the diff and ask which to keep. Ensure the course style layer exists; if not, create it from the "Styles" section above with the colour meanings in `COURSE.md`. If `images/Makefile` is missing, copy `reference/Makefile` and set `STYLE` to the layer and base copy paths relative to `images/`.
2. One `.tex` per figure, following `reference/example.tex`: `\input` the course style layer, no local colour definitions, `\texttt{}` for code identifiers, title on top, optional takeaway card.
3. Reuse the base and course-layer styles. Add a new shared style to the right file (see "Styles") instead of redefining it per figure.

### TikZ gotchas

- Do not name a style after a built-in TikZ key (`in`, `out`, `rotate`, ...). Use names like `inlabel` and `outbox`.
- Write `.tex` files with a quoted heredoc (`<<'EOF'`) so `\\`, `\$` and `\t` survive the shell.
- Measure loop depths from the anchor you draw from (`++(0,-1)` is relative to the anchor, not the node centre).
- Route lines so none cross; nest loops instead (inner loop is shallower and its vertical sits closer to the source).
- Keep arrows from running through text; stop them at a cell's edge or use a badge instead of a long arrow.

## Phase 3: Build and verify

1. `cd <notes>/moduleNN/images && make && make preview`
2. Read each `.preview/*.png` and check it against this list; fix and rebuild until it passes:
   - no text overflow, clipping or overlapping labels
   - names match the readings
   - every number traces to a source line in the plan
   - legible at GitHub width (~900 px); no text below `\scriptsize`
   - colour-blind safe; each colour used with its `COURSE.md` meaning; meaning not colour-only
   - one idea per figure; not crowded
3. Ensure `.preview/` is git-ignored (add `<notes>/**/images/.preview/` to `.gitignore` if missing). Leave the preview files in place; see the Preview files rule before removing anything.

## Phase 4: Embed

For each figure, insert at the planned position (the caption ends with the caption citation `COURSE.md` "Figures" gives):

```markdown
![One sentence: what the figure shows and why it matters.](images/figNN_slug.svg)

*Fig. M.N — Short title <caption citation>*
```

- Alt text is required: SVGs are built with `--no-fonts`, so text is paths and alt text is the only description.
- The prose around a figure must refer to it ("the figure below"), and the figure must not split closely coupled bullets.
- Add `images/README.md` listing each figure: file, description, lecture file.

## Done

Ask whether to keep or delete the `.preview/` files (Preview files rule). Report: figures created, notes edited, discrepancies found and how the user resolved them, and "slides not updated." Then point to the next step: "next: `/slide-prep NN` to generate the slides file." Remind the user that the course's git workflow applies (the skill and tracker doc `COURSE.md` names under "Pointers").
