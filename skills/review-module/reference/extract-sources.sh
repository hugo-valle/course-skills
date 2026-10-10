#!/usr/bin/env bash
# Extract each source listed in instructor_material/README.md into a per-source text cache.
# Manifest rows: | id | kind | location | name |   (location relative to instructor_material/)
# Output: instructor_material/.source-cache/<id>/pNNNN.txt (PDF page N, not the printed page number)
# Idempotent per source: skips one whose cache is complete and newer than its file.
# The `.complete` marker is written only after extraction succeeds, so a failed run is retried.
# Run from anywhere inside the course repo.
set -euo pipefail

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

while IFS=$'\t' read -r id kind location; do
  [[ "$id" =~ ^[A-Za-z0-9_-]+$ ]] || { echo "ERROR: source id '$id' must be letters, digits, - or _ (it names the cache folder)." >&2; exit 2; }
  case "$kind" in
    pdf) [ -f "$dir/$location" ] || { echo "ERROR: $id: $dir/$location not found. Put the PDF there (the folder is git-ignored)." >&2; exit 2; }
         pdf_pages "$id" "$dir/$location" ;;
    *)   echo "ERROR: $id: unknown kind '$kind' (supported: pdf)." >&2; exit 2 ;;
  esac
done <<< "$rows"
