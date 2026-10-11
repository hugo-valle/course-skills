#!/usr/bin/env python3
"""Check a module's SlideKraft slides file against the slide budget and its notes.

Usage:
  check_budget.py SLIDES.md...                     report over-budget slides (exit 1 if any)
  check_budget.py --coverage SLIDES.md NOTES.md... check the slides carry every notes body
                                                   line word for word and in order (exit 1 if not)
  check_budget.py --self-test                      run the built-in checks

Slides are separated by `---`. FLAG lines mark a single block (list, table, code block,
paragraph) that breaks the budget by itself; splitting cannot fix it, so FLAGs never
change the exit code. Front matter and aside slides (Demo, Knowledge Check) are not
measured. A `# [2+2] Title` grid slide is measured cell by cell at GRID_WRAP.
"""
from collections import Counter
from difflib import SequenceMatcher
import math
import re
import sys

MAX_LINES = 16
MAX_BULLETS = 10
MAX_CODE_LINES = 12
MAX_CODE_ALONE = 18  # when the code block is the slide's only content
MAX_TABLE_ROWS = 9  # body rows, not counting the header
MAX_FIGURES = 1
MAX_FIGURE_TEXT = 3  # rendered lines of other content beside a figure on a full-width slide
MIN_CONTINUATION = 3  # rendered lines a (cont.) slide needs to earn a slide
WRAP = 90  # characters per rendered line on a full-width 16:9 slide
GRID_WRAP = 45  # characters per rendered line in a [2+2] grid cell

# Notes sections that never go on a slide, by heading text. The notes' first section
# (before the first ---) contributes only its heading: the rest is metadata.
NOTES_ONLY = {"Required Readings", "Module Roadmap", "Hands-On Exercises",
              "Module Assignments", "Industry Skills Focus", "More Resources"}

LIST = re.compile(r"\s*([-*+]|\d+\.)\s")
GRID = re.compile(r"\[[^\]]*\]\s*")  # the layout prefix of a slide title, e.g. [2+2]
ASIDE = re.compile(r":::\s*\S*aside")
# what a split adds to a notes title: a label, (cont.) or Diagram, or (…, cont.) merged
SUFFIX = re.compile(r"(: .+| \(cont\.\)| Diagram)+")
MERGED = re.compile(r", cont\.\)( Diagram)?")


def line_kind(line):
    s = line.strip()
    if s.startswith(":::"):
        return "group"
    if s.startswith("#"):
        return "heading"
    if s.startswith(("```", "~~~")):
        return "code"
    if s.startswith("$$"):
        return "math"
    if s.startswith("|"):
        return "table"
    if s.startswith("!["):
        return "figure"
    if s.startswith("*Fig."):
        return "caption"
    if LIST.match(line):
        return "list"
    return "paragraph"


def front_matter(text):
    """(front matter lines, text with the front matter blanked so line numbers hold)."""
    lines = text.splitlines()
    if lines[:1] != ["---"] or "---" not in lines[1:]:
        return [], text
    end = lines.index("---", 1)
    return lines[1:end], "\n" * (end + 1) + "\n".join(lines[end + 1:])


def sections(text):
    """Split text on --- into sections; each is a list of (kind, line_no, lines)."""
    section, block, fence, gap = [], None, None, False

    def close():
        nonlocal block
        if block:
            section.append(block)
        block = None

    for no, line in enumerate(text.splitlines(), 1):
        if fence:
            block[2].append(line)
            if line.strip().startswith(fence) and len(block[2]) > 1:
                fence = None
                close()
            continue
        if line.strip() == "---":
            close()
            yield section
            section = []
            continue
        if not line.strip():
            if block and block[0] == "list":
                gap = True  # a loose list may continue after a blank line
            else:
                close()
            continue
        k = line_kind(line)
        # indented text under a list item belongs to that item
        if block and block[0] == "list" and k == "paragraph" and line[:1].isspace():
            k = "list"
        if gap and k != "list":
            close()
        gap = False
        if not block or block[0] != k or k in ("heading", "group"):
            close()
            block = (k, no, [])
        block[2].append(line)
        if k in ("code", "math") and len(block[2]) == 1:
            one_line = k == "math" and len(line.strip()) > 2 and line.strip().endswith("$$")
            fence = None if one_line else line.strip()[:3 if k == "code" else 2]
    close()
    yield section


def measure(kind, lines, wrap=WRAP):
    """Return (rendered lines, bullets) for one block."""
    if kind in ("heading", "caption", "figure", "group"):
        return 0, 0
    if kind == "list":
        items = []  # each item with the text indented under it
        for l in lines:
            if LIST.match(l):
                items.append(l.strip())
            else:
                items[-1] += " " + l.strip()
        return sum(math.ceil(len(i) / wrap) for i in items), len(items)
    if kind == "paragraph":
        return math.ceil(len(" ".join(l.strip() for l in lines)) / wrap), 0
    if kind == "code":
        return len(lines) - 2, 0  # without the fences
    if kind == "table":
        return len(table_rows(lines)), 0
    return len(lines), 0


def table_rows(lines):
    """Header and body rows, without the |---| separator."""
    return [l for l in lines if not set(l.strip()) <= set("|-: ")]


def too_big(kind, lines, wrap=WRAP, alone=False):
    """Why one block breaks the budget by itself, or None. Blocks are never split."""
    n, items = measure(kind, lines, wrap)
    if kind == "code":
        limit = MAX_CODE_ALONE if alone else MAX_CODE_LINES
        return f"code lines {n} > {limit}" if n > limit else None
    if kind == "table" and n - 1 > MAX_TABLE_ROWS:
        return f"table rows {n - 1} > {MAX_TABLE_ROWS}"
    if items > MAX_BULLETS:
        return f"bullets {items} > {MAX_BULLETS}"
    if n > MAX_LINES:
        return f"lines {n} > {MAX_LINES}"
    return None


def aside(line, code):
    """True for the line that marks an aside slide: a ::: aside group or a question block."""
    return line.strip().startswith("```question") if code else bool(ASIDE.match(line.strip()))


def unmeasured(section):
    """Aside slides (Demo, Knowledge Check) are laid out by SlideKraft, not measured."""
    return any(aside(b[0], k == "code") for k, _, b in section)


def report(name, text):
    out, exit_code = [], 0
    for section in sections(front_matter(text)[1]):
        if not section or unmeasured(section):
            continue
        head = next((b[0].lstrip("# ").strip() for k, _, b in section if k == "heading"), "")
        grid = GRID.match(head)
        title = head[grid.end():] if grid else head
        wrap = GRID_WRAP if grid else WRAP
        cells = [[]]  # a grid slide's ::: groups are cells; a plain slide is one cell
        for block in section:
            if block[0] == "group":
                cells.append([])
            else:
                cells[-1].append(block)
        if not grid:
            cells = [[b for c in cells for b in c]]
        figures = sum(k == "figure" for k, _, _ in section)
        found, flags = [], []
        if figures > MAX_FIGURES:
            found.append(f"figures {figures} > {MAX_FIGURES}")
        for cell in cells:
            content = [(k, no, b) for k, no, b in cell if k not in ("heading", "caption")]
            alone = len(content) == 1
            cell_flags = [(k, no, why) for k, no, b in content
                          for why in [too_big(k, b, wrap, alone)] if why]
            flagged = {no for _, no, _ in cell_flags}
            # lines and bullets in blocks a split can move (not flagged ones)
            movable = [measure(k, b, wrap) for k, no, b in content if no not in flagged]
            lines = sum(measure(k, b, wrap)[0] for k, _, b in cell)
            bullets = sum(measure(k, b, wrap)[1] for k, _, b in cell)
            cell_found = []
            if figures and not grid:
                if figures <= MAX_FIGURES and lines > MAX_FIGURE_TEXT:
                    cell_found.append(f"text beside figure {lines} > {MAX_FIGURE_TEXT}")
            elif lines > MAX_LINES and any(m[0] for m in movable):
                cell_found.append(f"lines {lines} > {MAX_LINES}")
            if bullets > MAX_BULLETS and any(m[1] for m in movable):
                cell_found.append(f"bullets {bullets} > {MAX_BULLETS}")
            if len(content) < 2:  # one block alone cannot be split
                cell_found = []
            if title.endswith("cont.)") and not figures and lines < MIN_CONTINUATION:
                cell_found.append(f"continuation lines {lines} < {MIN_CONTINUATION}")
            found += cell_found
            flags += cell_flags
        if found:
            out += [f"{name}:{section[0][1]}: {title!r}: {f}" for f in found]
            exit_code = 1
        out += [f"{name}:{no}: FLAG {k} too big by itself: {why}" for k, no, why in flags]
    return out, exit_code


def plain_sections(text):
    """Split text on --- into sections of (line_no, line, in_code) for non-blank lines."""
    out, fence = [[]], None
    for no, line in enumerate(text.splitlines(), 1):
        s, code = line.strip(), bool(fence)
        if fence:
            if s.startswith(fence):
                fence = None
        elif s.startswith(("```", "~~~")):
            fence, code = s[:3], True
        elif s == "---":
            out.append([])
            continue
        if s:
            out[-1].append((no, line.rstrip(), code))
    return out


def normalize(line, code):
    """Headings compare by text only: level and grid prefix are slide syntax."""
    if code or not line.startswith("#"):
        return line
    text = line.lstrip("#").strip()
    return "# " + text[GRID.match(text).end():] if GRID.match(text) else "# " + text


def notes_lines(name, text):
    for i, section in enumerate(plain_sections(text)):
        heads = [normalize(l, c) for _, l, c in section if not c and l.startswith("#")]
        if heads and heads[0][2:] in NOTES_ONLY:
            continue
        for no, l, c in section:
            if i == 0 and (c or not l.startswith("#")):
                continue  # metadata under the overview title
            yield name, no, normalize(l, c)


def slides_lines(name, text):
    matter, body = front_matter(text)
    for no, l in enumerate(matter, 2):
        if l.startswith("title:"):
            yield name, no, "# " + l[len("title:"):].strip()
    for section in plain_sections(body):
        if any(aside(l, c) for _, l, c in section):
            continue
        for no, l, c in section:
            if c or line_kind(l) != "group":
                yield name, no, normalize(l, c)


def coverage(notes, slides):
    """Notes body lines the slides file drops, rewords or moves, and lines it adds.

    Only figure lines (image and caption) may move. A slide title made from a notes
    heading (continuation, label or Diagram title) is not an added line.
    """
    old = [x for name, text in notes for x in notes_lines(name, text)]
    new = list(slides_lines(*slides))
    titles = {l for _, _, l in old if l.startswith("# ")}

    def derived(l):
        if l in titles:
            return False
        for t in titles:
            if l.startswith(t) and SUFFIX.fullmatch(l[len(t):]):
                return True
            if t.endswith(")") and l.startswith(t[:-1]) and MERGED.fullmatch(l[len(t) - 1:]):
                return True
        return False

    def figure(l):
        return line_kind(l) in ("figure", "caption")

    problems = []
    lost = Counter(l for _, _, l in old if figure(l)) - Counter(l for _, _, l in new if figure(l))
    for name, no, l in old:
        if lost[l]:
            lost[l] -= 1
            problems.append(f"{name}:{no}: missing: {l}")

    a = [x for x in old if not figure(x[2])]
    b = [x for x in new if not figure(x[2]) and not derived(x[2])]
    gone, extra, pair = [], [], {}
    matcher = SequenceMatcher(None, [x[2] for x in a], [x[2] for x in b], autojunk=False)
    for op, i1, i2, j1, j2 in matcher.get_opcodes():
        if op != "equal":
            gone += a[i1:i2]
            extra += b[j1:j2]
        if op == "replace":
            pair.update((id(o), n) for o, n in zip(a[i1:i2], b[j1:j2]))
    moved = Counter(x[2] for x in gone) & Counter(x[2] for x in extra)
    left, paired = moved.copy(), set()
    for x in gone:
        name, no, l = x
        if left[l]:
            left[l] -= 1
            problems.append(f"{name}:{no}: out of order: {l}")
        elif id(x) in pair and not moved[pair[id(x)][2]]:
            paired.add(id(pair[id(x)]))
            problems.append(f"{name}:{no}: reworded: {l} → {pair[id(x)][2]}")
        else:
            problems.append(f"{name}:{no}: missing: {l}")
    left = moved.copy()
    for x in extra:
        if left[x[2]]:
            left[x[2]] -= 1
        elif id(x) not in paired:
            problems.append(f"{x[0]}:{x[1]}: added: {x[2]}")
    return problems


def self_test():
    def para(n, wrap=WRAP):  # one paragraph of n rendered lines
        return "x" * (wrap * n)

    def items(n, tag="i"):
        return "".join(f"- {tag}{i}\n" for i in range(n))

    def code(n):
        return "```text\n" + "".join(f"line {i}\n" for i in range(n)) + "```\n"

    fm = "---\ntitle: Module 1: Topic\nsubtitle: Course\n---\n\n---\n\n"
    fig = "![Alt text.](images/fig01_x.svg)\n\n*Fig. 1.1 — Title*\n"

    def slides(*bodies):
        return fm + "\n---\n\n".join(bodies)

    # budget: a slides file under budget passes; front matter and dividers are not slides
    ok = slides("# Lecture 1: Intro\n", "# Fits\n\n" + para(8) + "\n\n" + para(8) + "\n")
    assert report("s.md", ok) == ([], 0), report("s.md", ok)

    # each rule fails just past its limit
    out = report("s.md", slides("# Long\n\n" + para(9) + "\n\n" + para(8) + "\n"))
    assert out == (["s.md:8: 'Long': lines 17 > 16"], 1), out
    out = report("s.md", slides("# Lists\n\n**A**:\n\n" + items(6) + "\n**B**:\n\n" + items(5)))
    assert out == (["s.md:8: 'Lists': bullets 11 > 10"], 1), out
    out = report("s.md", slides("# One list\n\n" + items(10)))
    assert out == ([], 0), out
    out = report("s.md", slides("# One list\n\n" + items(11)))
    assert out == (["s.md:10: FLAG list too big by itself: bullets 11 > 10"], 0), out
    rows = lambda n: "| a | b |\n|---|---|\n" + "".join(f"| r{i} | v |\n" for i in range(n))
    assert report("s.md", slides("# Table\n\n" + rows(9))) == ([], 0)
    out = report("s.md", slides("# Table\n\n" + rows(10)))
    assert out == (["s.md:10: FLAG table too big by itself: table rows 10 > 9"], 0), out
    assert report("s.md", slides("# Code\n\nIntro.\n\n" + code(12))) == ([], 0)
    out = report("s.md", slides("# Code\n\nIntro.\n\n" + code(13)))
    assert out == (["s.md:12: FLAG code too big by itself: code lines 13 > 12"], 0), out
    out = report("s.md", slides("# Figs\n\n" + fig + "\n" + fig))
    assert out == (["s.md:8: 'Figs': figures 2 > 1"], 1), out
    out = report("s.md", slides("# Fig\n\n" + para(4) + "\n\n" + fig))
    assert out == (["s.md:8: 'Fig': text beside figure 4 > 3"], 1), out
    assert report("s.md", slides("# Fig Diagram\n\n" + fig)) == ([], 0)

    # a code block alone on a slide may run to 18 lines
    assert report("s.md", slides("# Diagram\n\n" + code(18))) == ([], 0)
    out = report("s.md", slides("# Diagram\n\n" + code(19)))
    assert out == (["s.md:10: FLAG code too big by itself: code lines 19 > 18"], 0), out

    # [2+2] cells are measured at 45 characters per line
    text = para(5) + "\n\n" + para(4)  # 9 lines full width, 18 in a cell
    assert report("s.md", slides("# Wide\n\n" + text + "\n")) == ([], 0)
    out = report("s.md", slides("# [2+2] Grid\n:::\n" + text + "\n:::\n:::\n\n" + fig))
    assert out == (["s.md:8: 'Grid': lines 18 > 16"], 1), out
    short = para(4) + "\n\n" + para(3)  # 14 lines in a cell
    assert report("s.md", slides("# [2+2] Grid\n:::\n" + short + "\n:::\n:::\n\n" + fig)) == ([], 0)

    # aside slides and question slides are not measured
    kc = "::: left-aside\n# Knowledge Check\n:::\n\n```question mcsa 1pts\n" + "q_x\n" * 20 + "```\n"
    demo = "> **Demo:** " + para(20) + "\n\n::: right-aside\n# Demo: Thing\n:::\n"
    assert report("s.md", slides(kc, demo)) == ([], 0)
    long_fm = "---\ntitle: T\nextra: " + para(20) + "\n---\n\n---\n\n# A\n\nText.\n"
    assert report("s.md", long_fm) == ([], 0)

    # carried over: ~~~ fences hide ---, a flagged block does not hide movable content,
    # and a (cont.) slide must be worth a slide
    tilde = "# T\n\nIntro.\n\n~~~\n" + "a\n---\n" * 7 + "b\n~~~\n"
    assert report("s.md", tilde) == (["s.md:5: FLAG code too big by itself: code lines 15 > 12"], 0)
    out = report("s.md", "# Big\n\n" + para(17) + "\n\n" + (para(2) + "\n\n") * 5)
    assert out == (["s.md:1: 'Big': lines 27 > 16",
                    "s.md:3: FLAG paragraph too big by itself: lines 17 > 16"], 1), out
    out = report("s.md", "# T (cont.)\n\nShort.\n")
    assert out == (["s.md:1: 'T (cont.)': continuation lines 1 < 3"], 1), out
    out = report("s.md", "# T (Pipelined, cont.)\n\nShort.\n")
    assert out == (["s.md:1: 'T (Pipelined, cont.)': continuation lines 1 < 3"], 1), out

    # coverage: a correct conversion passes; notes-only sections and metadata are skipped
    notes = ("# Module 1: Topic\n\n**Course:** Course\n\n---\n\n## Topic\n\nFirst.\n\n"
             "The figure below shows it.\n\n" + fig + "\nSecond.\n\nThird.\n\n---\n\n"
             "## Required Readings\n\nRead it.\n\n---\n\n## Pair (Two)\n\nOne.\n\nTwo.\n")
    good = slides("# Topic\n\nFirst.\n\nThe figure below shows it.\n\nSecond.\n",
                  "# Topic (cont.)\n\nThird.\n",
                  "# Topic Diagram\n\n" + fig,
                  "> **Demo:** Work on it.\n\n::: right-aside\n# Demo: It\n:::\n",
                  "# [2+2] Pair (Two)\n:::\nOne.\n:::\n:::\n",
                  "# Pair (Two, cont.)\n\nTwo.\n")
    assert coverage([("n.md", notes)], ("s.md", good)) == []

    # coverage reports a dropped line, a reworded line and an out-of-order line
    out = coverage([("n.md", notes)], ("s.md", good.replace("Second.\n", "")))
    assert out == ["n.md:17: missing: Second."], out
    out = coverage([("n.md", notes)], ("s.md", good.replace("Third.", "Third!")))
    assert out == ["n.md:19: reworded: Third. → Third!"], out
    swapped = good.replace("First.\n\nThe", "The").replace("Second.\n", "Second.\n\nFirst.\n")
    out = coverage([("n.md", notes)], ("s.md", swapped))
    assert out == ["n.md:9: out of order: First."], out
    out = coverage([("n.md", notes)], ("s.md", good + "\n---\n\n# Bogus\n\nExtra.\n"))
    assert out == ["s.md:54: added: # Bogus", "s.md:56: added: Extra."], out
    out = coverage([("n.md", notes)], ("s.md", good.replace("# Topic (cont.)", "# Topical")))
    assert out == ["s.md:18: added: # Topical"], out
    out = coverage([("n.md", notes)], ("s.md", good.replace(fig, "")))
    assert out == ["n.md:13: missing: ![Alt text.](images/fig01_x.svg)",
                   "n.md:15: missing: *Fig. 1.1 — Title*"], out
    print("self-test passed")


def main(argv):
    if argv == ["--self-test"]:
        self_test()
        return 0
    if len(argv) >= 3 and argv[0] == "--coverage":
        slides = (argv[1], open(argv[1], encoding="utf-8").read())
        notes = [(p, open(p, encoding="utf-8").read()) for p in argv[2:]]
        problems = coverage(notes, slides)
        print("\n".join(problems) or f"{argv[1]}: covers the notes")
        return 1 if problems else 0
    if not argv or argv[0].startswith("-"):
        print(__doc__)
        return 2
    code = 0
    for path in argv:
        out, c = report(path, open(path, encoding="utf-8").read())
        print("\n".join(out) or f"{path}: within budget")
        code = code or c
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
