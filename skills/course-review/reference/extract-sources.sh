#!/usr/bin/env bash
# Extract each source listed in instructor_material/README.md into a per-source text cache.
# Manifest rows: | id | kind | location | name |   (location relative to instructor_material/)
# Kinds: pdf (location = file) and url (location = web address).
# Output: instructor_material/.source-cache/<id>/pNNNN.txt (PDF page N, not the printed page number),
#         or <id>/snapshot.txt for a url: its text, headed by "URL: <url>" and "Fetched: YYYY-MM-DD".
# Idempotent per source: skips a PDF whose cache is complete and newer than its file, and a url
# that already has a snapshot of the same address. `--refresh` fetches every url again.
# The `.complete` marker is written only after extraction succeeds, so a failed run is retried.
# Run from anywhere inside the course repo.
set -euo pipefail
refresh=0
case "${1:-}" in --refresh) refresh=1 ;; "") ;; *) echo "usage: $0 [--refresh]" >&2; exit 2 ;; esac

root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "ERROR: run inside the course repo." >&2; exit 2; }
cd "$root"
dir="instructor_material"
manifest="$dir/README.md"
[ -f "$manifest" ] || { echo "ERROR: no $manifest. List each source there as | id | kind | location | name |." >&2; exit 2; }

# Table body rows: skip the header (first row) and the |---| separator.
rows=$(awk -F'|' '/^\|/ && !/^\|[ -:|]*$/ { if (seen++) { for (i = 2; i <= 5; i++) { gsub(/^ +| +$/, "", $i) } print $2 "\t" $3 "\t" $4 } }' "$manifest")
[ -n "$rows" ] || { echo "ERROR: $manifest lists no sources." >&2; exit 2; }

pdf_pages() {   # $1 = id, $2 = PDF path
  local cache="$dir/.source-cache/$1" pages got empty
  command -v mutool >/dev/null || { echo "ERROR: mutool is required (install mupdf-tools)." >&2; exit 3; }
  if [ -f "$cache/.complete" ] && [ "$cache/.complete" -nt "$2" ]; then
    echo "$1: cache is current ($(find "$cache" -name 'p*.txt' | wc -l | tr -d ' ') pages)"; return
  fi
  pages=$(mutool info "$2" 2>/dev/null | awk '/^Pages:/ {print $2}')
  [[ "$pages" =~ ^[0-9]+$ ]] || { echo "ERROR: $1: could not read the page count of $2 (encrypted or damaged?)." >&2; exit 4; }
  rm -rf "$cache"; mkdir -p "$cache"
  mutool draw -q -F txt -o "$cache/p%04d.txt" "$2" 1-"$pages" 2>/dev/null || true   # tolerate truncated streams
  got=$(find "$cache" -name 'p*.txt' | wc -l)
  [ "$got" -ge "$pages" ] || { echo "ERROR: $1: extracted $got of $pages pages." >&2; exit 5; }
  empty=$(find "$cache" -name 'p*.txt' -size -100c | wc -l | tr -d ' ')
  touch "$cache/.complete"
  echo "$1: extracted $pages pages from $(basename "$2") to $cache ($empty near-empty: figures, blank or damaged pages)"
  [ "$empty" -le $((pages / 2)) ] || echo "WARNING: $1: most pages have no text; the PDF may be scanned. Lookups will fail." >&2
}

# HTML to plain text: drop script and style, one line per block, whitespace collapsed.
html2text='
import sys, html.parser
class P(html.parser.HTMLParser):
    skip, out = 0, []
    def handle_starttag(self, t, a):
        if t in ("script", "style", "noscript"): self.skip += 1
        self.out.append("\n")
    def handle_endtag(self, t):
        if t in ("script", "style", "noscript"): self.skip = max(0, self.skip - 1)
        self.out.append("\n")
    def handle_data(self, d):
        if not self.skip: self.out.append(d)
p = P(convert_charrefs=True); p.feed(sys.stdin.read()); p.close()
for line in "".join(p.out).splitlines():
    line = " ".join(line.split())
    if line: print(line)
'

url_snapshot() {   # $1 = id, $2 = URL
  local cache="$dir/.source-cache/$1" new="$dir/.source-cache/$1.new"
  if [ -f "$cache/.complete" ] && [ "$refresh" -eq 0 ] && grep -qxF "URL: $2" "$cache/snapshot.txt"; then
    echo "$1: snapshot of $(sed -n 's/^Fetched: //p' "$cache/snapshot.txt") kept (--refresh to fetch again)"; return
  fi
  for tool in curl python3; do command -v $tool >/dev/null || { echo "ERROR: $tool is required for url sources." >&2; exit 3; }; done
  rm -rf "$new"; mkdir -p "$new"
  curl -fsSL --max-time 60 -o "$new/page" "$2" || { rm -rf "$new"; echo "ERROR: $1: could not fetch $2." >&2; exit 6; }
  { printf 'URL: %s\nFetched: %s\n\n' "$2" "$(date +%Y-%m-%d)"; python3 -I -c "$html2text" < "$new/page"; } > "$new/snapshot.txt" \
    || { rm -rf "$new"; echo "ERROR: $1: could not convert $2 to text." >&2; exit 6; }
  rm "$new/page"; touch "$new/.complete"
  rm -rf "$cache"; mv "$new" "$cache"   # an old snapshot survives a failed refresh
  echo "$1: snapshot of $2 saved to $cache/snapshot.txt"
}

while IFS=$'\t' read -r id kind location; do
  [[ "$id" =~ ^[A-Za-z0-9_-]+$ ]] || { echo "ERROR: source id '$id' must be letters, digits, - or _ (it names the cache folder)." >&2; exit 2; }
  case "$kind" in
    pdf) [ -f "$dir/$location" ] || { echo "ERROR: $id: $dir/$location not found. Put the PDF there (the folder is git-ignored)." >&2; exit 2; }
         pdf_pages "$id" "$dir/$location" ;;
    url) url_snapshot "$id" "$location" ;;
    *)   echo "ERROR: $id: unknown kind '$kind' (supported: pdf, url)." >&2; exit 2 ;;
  esac
done <<< "$rows"
