#!/usr/bin/env bash
# Fail if a global skill or agent names a specific course.
# Course details belong in each course's COURSE.md, never in the shared core.
# Usage: scripts/leak_check.sh [path ...]
#   default: the repo's skills/, agents/ and template/, except template/docs/agents/ (example config)
set -u
repo="$(cd "$(dirname "$0")/.." && pwd)"

# One extended regex per line. Add a term when a ticket moves its course detail into COURSE.md.
terms='
\bCS[ -]?[0-9]{4}\b
Patterson|Hennessy|P&H
\bKialo\b
\bWeber\b
GLOSSARY\.md
\bHugo Valle\b
\b(hazbox|stallcell|hazcell|fwdcell|bubblecell|pipeRow|cHaz|cFwd|cStall)\b
'
pattern=$(printf '%s\n' "$terms" | grep -v '^$' | paste -sd'|' -)

label="$*"
if [ $# -eq 0 ]; then
  label="skills/, agents/, template/ except docs/agents/"
  set -- "$repo/skills" "$repo/agents"
  [ -d "$repo/template" ] && while IFS= read -r f; do set -- "$@" "$f"; done \
    < <(find "$repo/template" -path "$repo/template/docs/agents" -prune -o -type f -print)
fi
grep -rniE "$pattern" "$@"
case $? in
  0) echo "leak_check: course-specific terms found above; move them to COURSE.md" >&2; exit 1 ;;
  1) echo "leak_check: clean ($label)" ;;
  *) echo "leak_check: could not read a path ($label)" >&2; exit 2 ;;
esac
