#!/usr/bin/env bash
# Self-test for extract-sources.sh against a throwaway course repo with a two-page PDF.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail=0
run() { (cd "$tmp" && "$here/extract-sources.sh") >"$tmp/out" 2>&1; }

git -C "$tmp" init -q
mkdir "$tmp/instructor_material"
printf '%s\n' "BT 72 720 Td /F1 12 Tf (Alpha page) Tj ET" > "$tmp/c1"
printf '%s\n' "BT 72 720 Td /F1 12 Tf (Beta page) Tj ET" > "$tmp/c2"
(cd "$tmp" && mutool create -o instructor_material/book.pdf c1 c2) || { echo "FAIL: could not build fixture PDF"; exit 1; }

# No manifest: an error that names the file.
run && { echo "FAIL: missing manifest passed"; fail=1; }
grep -q 'instructor_material/README.md' "$tmp/out" || { echo "FAIL: missing-manifest message"; fail=1; }

cat > "$tmp/instructor_material/README.md" <<'MD'
# Sources

| id | kind | location | name |
|---|---|---|---|
| book | pdf | book.pdf | Test Book, 1st Ed. |
MD

# One PDF source: one text file per page, in its own folder.
run || { echo "FAIL: extraction failed: $(cat "$tmp/out")"; fail=1; }
grep -q Beta "$tmp/instructor_material/.source-cache/book/p0002.txt" 2>/dev/null || { echo "FAIL: page 2 not cached per source"; fail=1; }

# Rerun skips a current cache.
run && grep -q current "$tmp/out" || { echo "FAIL: rerun did not skip a current cache"; fail=1; }

# Runs from a subfolder: paths resolve from the repo root.
mkdir "$tmp/sub"; (cd "$tmp/sub" && "$here/extract-sources.sh") >/dev/null 2>&1 || { echo "FAIL: not run from repo root"; fail=1; }

# A listed file that is missing, and an unknown kind, are errors.
echo "| gone | pdf | gone.pdf | Gone |" >> "$tmp/instructor_material/README.md"
run && { echo "FAIL: missing PDF passed"; fail=1; }
sed -i.bak '$d' "$tmp/instructor_material/README.md"
echo "| tape | vhs | x | Tape |" >> "$tmp/instructor_material/README.md"
run && { echo "FAIL: unknown kind passed"; fail=1; }

[ $fail -eq 0 ] && echo "extract-sources self-test: ok"
exit $fail
