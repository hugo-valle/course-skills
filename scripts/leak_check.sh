#!/usr/bin/env bash
# Fail if a global skill or agent names a specific course.
# Course details belong in each course's COURSE.md, never in the shared core.
# Usage: scripts/leak_check.sh [path ...]   (default: the repo's skills/ and agents/)
set -u
repo="$(cd "$(dirname "$0")/.." && pwd)"

# One extended regex per line. Add a term when a ticket moves its course detail into COURSE.md.
terms='
\bCS[ -]?[0-9]{4}\b
Patterson|Hennessy|P&H
\bKialo\b
\bWeber\b
GLOSSARY\.md
\b(hazbox|stallcell|hazcell|fwdcell|bubblecell)\b
'
pattern=$(printf '%s\n' "$terms" | grep -v '^$' | paste -sd'|' -)

[ $# -eq 0 ] && set -- "$repo/skills" "$repo/agents"
grep -rniE "$pattern" "$@"
case $? in
  0) echo "leak_check: course-specific terms found above; move them to COURSE.md" >&2; exit 1 ;;
  1) echo "leak_check: clean ($*)" ;;
  *) echo "leak_check: could not read a path ($*)" >&2; exit 2 ;;
esac
