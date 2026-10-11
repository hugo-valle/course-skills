#!/usr/bin/env bash
# Symlink each skill and agent in this repo into one or more course repos' .claude/, so edits here reach them.
# Usage: install.sh <course-repo>...   Safe to re-run. Never replaces a real file or folder; it reports the clash.
set -u
repo="$(cd "$(dirname "$0")" && pwd)"
[ $# -gt 0 ] || { echo "usage: $0 <course-repo>..." >&2; exit 2; }
status=0
# Migration: earlier versions linked into ~/.claude; remove those links.
for old in "$HOME"/.claude/{skills,agents}/*; do
  [ -L "$old" ] && case "$(readlink "$old")" in "$repo"/*) rm "$old"; echo "removed global: $old";; esac
done
for target in "$@"; do
  [ -d "$target" ] || { echo "skip: $target is not a directory" >&2; status=1; continue; }
  target="$(cd "$target" && pwd)"
  for kind in skills agents; do
    dir="$target/.claude/$kind"
    mkdir -p "$dir"
    for old in "$dir"/*; do   # drop links left behind by a rename
      [ -L "$old" ] && [ ! -e "$old" ] && case "$(readlink "$old")" in "$repo"/*) rm "$old"; echo "removed stale: $old";; esac
    done
    for src in "$repo/$kind"/*; do
      [ -e "$src" ] || continue
      dest="$dir/$(basename "$src")"
      if [ -L "$dest" ]; then
        ln -sfn "$src" "$dest"
      elif [ -e "$dest" ]; then
        echo "skip: $dest exists and is not a symlink" >&2; status=1; continue
      else
        ln -s "$src" "$dest"
      fi
      echo "linked: $dest -> $src"
    done
  done
  grep -qxF '.claude/skills/course-*' "$target/.gitignore" 2>/dev/null ||
    echo "warning: $target/.gitignore lacks '.claude/skills/course-*' and '.claude/agents/course-*'; the links would be committed" >&2
done
exit $status
