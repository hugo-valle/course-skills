#!/usr/bin/env bash
# Self-test for leak_check.sh: a clean tree passes, a course-specific term fails.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail=0

echo "Generic rule: read COURSE.md." > "$tmp/clean.md"
"$here/leak_check.sh" "$tmp" >/dev/null 2>&1 || { echo "FAIL: clean tree flagged"; fail=1; }

for term in "CS 2810" "cs6200" "Patterson & Hennessy" "P&H §4.7" "Kialo" "hazbox"; do
  echo "Example: $term." > "$tmp/leak.md"
  "$here/leak_check.sh" "$tmp" >/dev/null 2>&1 && { echo "FAIL: '$term' not flagged"; fail=1; }
  rm "$tmp/leak.md"
done

# Relative paths resolve from the caller's directory, not the repo root.
echo "Example: CS-2810." > "$tmp/leak.md"
(cd "$tmp" && "$here/leak_check.sh" leak.md >/dev/null 2>&1) && { echo "FAIL: relative path not checked from caller dir"; fail=1; }
rm "$tmp/leak.md"

# A missing path is an error, never a silent pass.
"$here/leak_check.sh" "$tmp/nope" >/dev/null 2>&1 && { echo "FAIL: missing path passed"; fail=1; }

[ $fail -eq 0 ] && echo "leak_check self-test: ok"
exit $fail
