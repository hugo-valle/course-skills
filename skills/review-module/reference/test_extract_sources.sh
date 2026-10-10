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

# A URL source: a dated text snapshot next to the PDF pages, tags and scripts stripped.
printf '%s\n' '<html><head><style>p{}</style><script>var x=1;</script></head><body><h1>Gamma</h1><p>Delta &amp; docs</p></body></html>' > "$tmp/doc.html"
echo "| web | url | file://$tmp/doc.html | Test Docs |" >> "$tmp/instructor_material/README.md"
run || { echo "FAIL: URL snapshot failed: $(cat "$tmp/out")"; fail=1; }
snap="$tmp/instructor_material/.source-cache/web/snapshot.txt"
grep -q "Delta & docs" "$snap" 2>/dev/null || { echo "FAIL: URL text not snapshotted"; fail=1; }
grep -q "var x\|<p>\|p{}" "$snap" 2>/dev/null && { echo "FAIL: snapshot kept markup, script or style"; fail=1; }
grep -q "^URL: file://$tmp/doc.html$" "$snap" 2>/dev/null || { echo "FAIL: snapshot does not record its URL"; fail=1; }
grep -q "^Fetched: $(date +%Y-%m-%d)$" "$snap" 2>/dev/null || { echo "FAIL: snapshot does not record its fetch date"; fail=1; }
[ -f "$tmp/instructor_material/.source-cache/book/p0001.txt" ] || { echo "FAIL: PDF cache missing beside the URL snapshot"; fail=1; }

# Rerun keeps an existing snapshot; --refresh fetches it again.
sed -i.bak 's/Delta/Epsilon/' "$tmp/doc.html"
run && grep -q "web: snapshot of" "$tmp/out" && grep -q Delta "$snap" || { echo "FAIL: rerun did not keep the snapshot"; fail=1; }
(cd "$tmp" && "$here/extract-sources.sh" --refresh) >"$tmp/out" 2>&1 && grep -q Epsilon "$snap" || { echo "FAIL: --refresh did not refetch: $(cat "$tmp/out")"; fail=1; }

# A manifest row pointed at a new URL is fetched again without --refresh.
cp "$tmp/doc.html" "$tmp/doc2.html"; sed -i.bak 's/Epsilon/Zeta/' "$tmp/doc2.html"
sed -i.bak "s|file://$tmp/doc.html|file://$tmp/doc2.html|" "$tmp/instructor_material/README.md"
run && grep -q Zeta "$snap" || { echo "FAIL: changed URL kept the old snapshot"; fail=1; }

# An unreachable URL is an error and leaves no snapshot behind.
echo "| dead | url | file://$tmp/nope.html | Dead |" >> "$tmp/instructor_material/README.md"
run && { echo "FAIL: unreachable URL passed"; fail=1; }
[ -e "$tmp/instructor_material/.source-cache/dead/.complete" ] && { echo "FAIL: failed fetch marked complete"; fail=1; }
sed -i.bak '$d' "$tmp/instructor_material/README.md"

# A listed file that is missing, and an unknown kind, are errors.
echo "| gone | pdf | gone.pdf | Gone |" >> "$tmp/instructor_material/README.md"
run && { echo "FAIL: missing PDF passed"; fail=1; }
sed -i.bak '$d' "$tmp/instructor_material/README.md"
echo "| tape | vhs | x | Tape |" >> "$tmp/instructor_material/README.md"
run && { echo "FAIL: unknown kind passed"; fail=1; }

[ $fail -eq 0 ] && echo "extract-sources self-test: ok"
exit $fail
