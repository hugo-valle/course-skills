#!/usr/bin/env bash
# Self-test for leak_check.sh: a clean tree passes, a course-specific term fails.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail=0

echo "Generic rule: read COURSE.md." > "$tmp/clean.md"
"$here/leak_check.sh" "$tmp" >/dev/null 2>&1 || { echo "FAIL: clean tree flagged"; fail=1; }

for term in "CS 2810" "cs6200" "Patterson & Hennessy" "P&H §4.7" "Kialo" "hazbox" "Dr. Hugo Valle"; do
  echo "Example: $term." > "$tmp/leak.md"
  "$here/leak_check.sh" "$tmp" >/dev/null 2>&1 && { echo "FAIL: '$term' not flagged"; fail=1; }
  rm "$tmp/leak.md"
done

# Relative paths resolve from the caller's directory, not the repo root.
echo "Example: CS-2810." > "$tmp/leak.md"
(cd "$tmp" && "$here/leak_check.sh" leak.md >/dev/null 2>&1) && { echo "FAIL: relative path not checked from caller dir"; fail=1; }
rm "$tmp/leak.md"

# The default run covers template/ but skips its example config (docs/agents).
mkdir -p "$tmp/repo/scripts" "$tmp/repo/skills" "$tmp/repo/agents" "$tmp/repo/template/docs/agents" "$tmp/repo/template/.githooks"
cp "$here/leak_check.sh" "$tmp/repo/scripts/"
echo "Glossary: GLOSSARY.md." > "$tmp/repo/template/docs/agents/domain.md"
echo "# generic hook" > "$tmp/repo/template/.githooks/pre-push"
"$tmp/repo/scripts/leak_check.sh" >/dev/null 2>&1 || { echo "FAIL: template example config flagged"; fail=1; }
echo "# CS 2810 hook" > "$tmp/repo/template/.githooks/pre-push"
"$tmp/repo/scripts/leak_check.sh" >/dev/null 2>&1 && { echo "FAIL: template/ not checked by default"; fail=1; }

# A missing path is an error, never a silent pass.
"$here/leak_check.sh" "$tmp/nope" >/dev/null 2>&1 && { echo "FAIL: missing path passed"; fail=1; }

[ $fail -eq 0 ] && echo "leak_check self-test: ok"
exit $fail
