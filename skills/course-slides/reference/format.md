# Slides File Format

The syntax of a SlideKraft Markdown export, with placeholder text. Reproduce this syntax exactly. The excerpts show **structure only**: slide text always comes from the notes.

## Front matter, then the first slide

The file opens with front matter. `title` is the overview's `#` heading. `subtitle`, `author` and `extra` are fixed per course: copy them from `COURSE.md` ("Slides"), and leave out a field it does not give. A `---` follows the front matter, then each slide, with `---` between slides.

```markdown
---
title: Module 3: Topic Name
subtitle: <subtitle from COURSE.md>
author: <author from COURSE.md>
extra: <credit line from COURSE.md>
---

---

# What This Module Is About

**Module 2** built the foundation. …
```

## Divider slide

A lecture's `#` title, alone on its slide.

```markdown
---

# Lecture 1: First Lecture Title

---
```

## Grid slide with a figure

`# [2+2] <Title>`. The first `:::` opens the text cell and the second closes it, the third opens the figure cell, and the slide's closing `---` ends it. The export uses `app://` image uploads; the slides file uses the module's `images/` SVGs with their alt text and caption.

```markdown
# [2+2] An Everyday Analogy
:::
A short paragraph of text that sits beside the figure …
:::
:::

![image25](app://01KWHYXR572G65QPJ9VVP4RH84)
```

In the slides file:

```markdown
# [2+2] Timing Diagram (cont.)
:::
Key observations:
- In cycle 5, every step is in progress at once.
:::
:::

![A timing diagram of five steps …](images/fig02_timing.svg)

*Fig. 3.2 — Timing for five steps*
```

## Continuation and Diagram slides

```markdown
# How Signals Propagate (cont.)

Each register also carries the signals the later steps need. …
```

```markdown
# Interactions with Branches: Case 2

**Case 2: a load right before a branch:** two stalls required …
```

```markdown
# The Five Stages Diagram

![image26](app://01KWHZ2ZEXPPN2EN51VDT8A851)
```

## Demo slide

A blockquote that links the exercise, then a `right-aside` group holding the `#` title. Link the real file in the module's exercise folder, relative to the slides file (here the exercise root is `hands_on_exercises/`).

```markdown
> **Demo:** Work on [`module03_3_exercise_timing.md`](../../hands_on_exercises/module03/module03_3_exercise_timing.md): Timing Diagrams.

::: right-aside
# Demo: Timing Diagrams
:::
```

Code exercises (the extensions `COURSE.md` lists under "Slides") are titled `# Code Demo: …`.

## Knowledge Check slide

A `left-aside` group, then a SlideKraft question block with its type, points and question ID. Copy it from the latest export unchanged.

````markdown
::: left-aside
# Knowledge Check
:::

```question mcsa 1pts
q_xpt7bdkz
```
````
