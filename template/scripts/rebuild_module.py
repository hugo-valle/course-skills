#!/usr/bin/env python3
"""Rebuild generated quiz .zip and exercise .html files from their .md sources.

Usage:
    scripts/rebuild_module.py NN               # every quiz and exercise in module NN
    scripts/rebuild_module.py FILE.md [...]    # only these sources

Quiz .md (quizzes/moduleNN/) -> .zip via text2qti. If text2qti is not on PATH,
a .venv is created at the repo root from requirements.txt.
Exercise .md (hands_on_exercises/moduleNN/) -> .html: the .md is embedded in the
page; a missing page is created and linked from hands_on_exercises/index.html.
A hand-written page with no embedded source is refused, not overwritten.
"""
import functools
import html
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VENV = ROOT / ".venv"
EXERCISES = ROOT / "hands_on_exercises"

SOURCE_RE = re.compile(
    r'(<script id="markdown-source" type="text/plain">\n).*?(\n  </script>)', re.S
)

PAGE = """<!DOCTYPE html>
<html lang="en" data-markdown="./{stem}.md">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{stem}</title>
  <link rel="stylesheet" href="../exercise.css">
  <script defer src="../exercise-renderer.js"></script>
</head>
<body>
  <main>
    <article id="exercise-content"><p class="loading-note">Loading content...</p></article>
  </main>
  <script id="markdown-source" type="text/plain">

  </script>
</body>
</html>
"""


def embed(html, md):
    """Return html with md as its embedded Markdown source."""
    if "</script" in md.lower():
        raise ValueError("Markdown contains '</script', which would end the embed early")
    new, n = SOURCE_RE.subn(lambda m: m.group(1) + md + m.group(2), html)
    if n != 1:
        raise ValueError("page has no markdown-source block")
    return new


def link_in_index(md_path):
    """Add a link to a new exercise page under its module's card in index.html."""
    index = EXERCISES / "index.html"
    text = index.read_text()
    href = f"{md_path.parent.name}/{md_path.stem}.html"
    if href in text:
        return
    title = re.search(r"^#\s+(?:Exercise:\s*)?(.+)$", md_path.read_text(), re.M)
    label = title.group(1).strip() if title else md_path.stem
    num = md_path.parent.name.removeprefix("module")
    card = re.search(rf"<h2>Module {num}</h2>.*?(\n\s*</ul>)", text, re.S)
    if not card:
        print(f"  ! no Module {num} card in index.html; add the link to {href} by hand")
        return
    li = f'\n          <li><a href="{href}">{html.escape(label)}</a></li>'
    index.write_text(text[: card.start(1)] + li + text[card.start(1) :])
    print(f"  + linked {href} in index.html (label: {label})")


def build_exercise(md_path):
    """Embed an exercise .md in its .html page, creating and linking a new page."""
    md = md_path.read_text()
    html_path = md_path.with_suffix(".html")
    if html_path.exists():
        page = html_path.read_text()
        if not SOURCE_RE.search(page):
            raise ValueError("hand-written page with no markdown-source block; "
                             "delete it to regenerate from the standard shell")
        html_path.write_text(embed(page, md))
    else:
        html_path.write_text(embed(PAGE.format(stem=md_path.stem), md))
        link_in_index(md_path)
    print(f"  html {html_path.relative_to(ROOT)}")


@functools.cache
def text2qti():
    """Path to text2qti: the pinned .venv copy, else PATH, else a new .venv."""
    venv_bin = VENV / "bin" / "text2qti"
    if venv_bin.exists():
        return str(venv_bin)
    if found := shutil.which("text2qti"):
        return found
    print("text2qti not found; creating .venv from requirements.txt")
    subprocess.run([sys.executable, "-m", "venv", str(VENV)], check=True)
    subprocess.run(
        [str(VENV / "bin" / "pip"), "install", "-q", "-r", str(ROOT / "requirements.txt")],
        check=True,
    )
    return str(venv_bin)


def build_quiz(md_path):
    """Build the QTI .zip for one quiz .md."""
    # text2qti writes <stem>.zip next to the source when run from its folder.
    subprocess.run([text2qti(), md_path.name], cwd=md_path.parent, check=True)
    print(f"  zip  {md_path.with_suffix('.zip').relative_to(ROOT)}")


def sources(args):
    for arg in args:
        if arg.isdigit():
            nn = f"module{int(arg):02d}"
            yield from sorted((ROOT / "quizzes" / nn).glob("*.md"))
            yield from sorted((EXERCISES / nn).glob("*.md"))
        else:
            yield Path(arg).resolve()


def main(args):
    if not args:
        sys.exit(__doc__)
    builders = {"quizzes": build_quiz, "hands_on_exercises": build_exercise}
    failed, built = [], 0
    for path in sources(args):
        try:
            rel = path.relative_to(ROOT)
            build = builders.get(rel.parts[0])
            if not build or not rel.parent.name.startswith("module"):
                print(f"  skip {rel} (not a quiz or exercise source)")
                continue
            build(path)
            built += 1
        except (subprocess.CalledProcessError, ValueError, OSError) as e:
            print(f"  FAILED {path}: {e}")
            failed.append(path)
    if not built and not failed:
        print("  nothing to build")
    if failed:
        sys.exit(f"{len(failed)} file(s) failed to build")


if __name__ == "__main__":
    main(sys.argv[1:])
