#!/usr/bin/env bash
# Symlink each skill and agent in this repo into ~/.claude, so edits here reach every course.
# Safe to re-run. Never replaces a real file or folder; it reports the clash instead.
set -u
repo="$(cd "$(dirname "$0")" && pwd)"
status=0
for kind in skills agents; do
  mkdir -p "$HOME/.claude/$kind"
  for src in "$repo/$kind"/*; do
    [ -e "$src" ] || continue
    dest="$HOME/.claude/$kind/$(basename "$src")"
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
exit $status
