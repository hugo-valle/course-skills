#!/usr/bin/env bash
#
# Commit message policy checker
#
# Shared by the commit-msg git hook and the Commit Message Lint CI workflow so
# both enforce exactly the same rules.
#
# Policy:
#   - Subject line 10-72 characters
#   - Subject starts with a capital letter (a Conventional Commit type such as
#     "fix: " is also accepted)
#   - Subject does not end with a period
#   - Subject is not vague ("wip", "update", "fix bug", "minor changes", ...)
#   - A blank line separates the subject from the body
#   - The change references an issue: a "#123" / "Closes #123" in the message,
#     or a number in the branch name (e.g. "42-fix-quiz-typo")
#
# Merge, revert and autosquash (fixup!/squash!/amend!) commits are skipped.
#
# Usage:
#   check-commit-message.sh --file <path>      # validate a COMMIT_EDITMSG file
#   check-commit-message.sh --rev  <sha>       # validate an existing commit
#   check-commit-message.sh --message "text"   # validate a literal string
#   echo "text" | check-commit-message.sh      # validate stdin
#   (optional on any form)  --branch <name>    # branch used for the issue-ref fallback
#
set -euo pipefail

PROG="check-commit-message"
SUBJECT_MIN=10
SUBJECT_MAX=72

branch=""
message=""
source_desc="commit message"

die() { echo "${PROG}: $*" >&2; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --file)    shift; [ $# -gt 0 ] || die "--file needs a path"
               message="$(cat "$1")"; source_desc="$1"; shift ;;
    --rev)     shift; [ $# -gt 0 ] || die "--rev needs a sha"
               message="$(git show -s --format=%B "$1")"
               source_desc="commit $(git show -s --format='%h %s' "$1")"; shift ;;
    --message) shift; [ $# -gt 0 ] || die "--message needs a string"
               message="$1"; shift ;;
    --branch)  shift; branch="${1:-}"; [ $# -gt 0 ] && shift || true ;;
    -h|--help) sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//; s/^#//'; exit 0 ;;
    *)         die "unknown argument: $1" ;;
  esac
done

if [ -z "$message" ] && [ ! -t 0 ]; then
  message="$(cat)"
fi
[ -n "${message//[$'\n\t ']/}" ] || die "empty commit message"

# --- normalise: drop the scissors section and comment lines, like git does ---
cleaned="$(printf '%s\n' "$message" \
  | sed '/^# -* >8 -*$/,$d' \
  | grep -v '^#' \
  | awk 'NF {p=1} p {b=b $0 ORS; if (NF) {print b; b=""}}' \
  || true)"

subject="$(printf '%s\n' "$cleaned" | sed -n '1p' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
line2="$(printf '%s\n' "$cleaned" | sed -n '2p')"

[ -n "$subject" ] || die "empty commit message"

# --- skip machine-generated commits ---
case "$subject" in
  "Merge "*|"Merge branch"*|"Merge remote-tracking"*|"Merge pull request"*) exit 0 ;;
  "Revert \""*|"Revert '"*)                                                  exit 0 ;;
  "fixup! "*|"squash! "*|"amend! "*)                                         exit 0 ;;
esac

subj_lc="$(printf '%s' "$subject" | tr '[:upper:]' '[:lower:]')"
conv_re='^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([a-z0-9._/-]+\))?!?: .'
errors=""

# 1. length
len=${#subject}
if [ "$len" -lt "$SUBJECT_MIN" ]; then
  errors="${errors}  - Subject is too short (${len} chars, need >= ${SUBJECT_MIN}); describe what changed.\n"
fi
if [ "$len" -gt "$SUBJECT_MAX" ]; then
  errors="${errors}  - Subject is too long (${len} chars, max ${SUBJECT_MAX}); move detail into the body.\n"
fi

# 2. capitalisation (or a Conventional Commit prefix)
if ! printf '%s' "$subject" | grep -Eq '^[A-Z]' \
   && ! printf '%s' "$subject" | grep -Eq "$conv_re"; then
  errors="${errors}  - Subject must start with a capital letter (or a type prefix like 'fix: ').\n"
fi

# 3. no trailing period
case "$subject" in
  *.) errors="${errors}  - Subject must not end with a period.\n" ;;
esac

# 4. not vague
vague_exact='^(wip|tmp|temp|test|tests|testing|fix|fixes|fixed|bug|bugfix|update|updates|updated|change|changes|changed|edit|edits|stuff|misc|cleanup|clean up|minor|nit|nits|typo|typos|asdf|foo|bar|commit|save|savepoint|checkpoint|done|final|final2|revert)$'
vague_phrase='^(update|updated|fix|fixed|minor|various|small|some|more|quick)( +[a-z]+){0,2} +(code|stuff|things|thing|bug|bugs|fix|fixes|change|changes|tweak|tweaks|update|updates|issue|issues|typo|typos|file|files|edit|edits|error|errors)$'
vague_twoword='^(add|added|update|updated|fix|fixed|change|changed|edit|edited|remove|removed|delete|deleted|refactor|refactored|improve|improved|tweak|tweaked|adjust|adjusted|modify|modified|rework|reworked|revise|revised|clean|cleaned|bump|patch)[[:space:]]+[a-z0-9._-]+$'
if printf '%s' "$subj_lc" | grep -Eq "$vague_exact" \
   || printf '%s' "$subj_lc" | grep -Eq "$vague_phrase" \
   || printf '%s' "$subj_lc" | grep -Eq "$vague_twoword"; then
  errors="${errors}  - \"${subject}\" is too vague; say what changed and why (e.g. 'Fix off-by-one in Module 3 quiz Q7').\n"
fi

# 5. blank line before body
if [ -n "$line2" ]; then
  errors="${errors}  - Leave a blank line between the subject and the body.\n"
fi

# 6. issue reference (in the message, or a number in the branch name)
issue_re='(#[0-9]+|GH-[0-9]+|/issues/[0-9]+)'
branch_issue_re='(^|[/_-])[0-9]+([/_.-]|$)'
if printf '%s' "$cleaned" | grep -Eiq "$issue_re"; then
  :
elif [ -n "$branch" ] && printf '%s' "$branch" | grep -Eq "$branch_issue_re"; then
  :
else
  errors="${errors}  - No issue reference. Add 'Refs #<n>' / 'Closes #<n>' to the message, or name the branch like '42-short-description'.\n"
fi

if [ -n "$errors" ]; then
  {
    echo ""
    echo "Commit message rejected -- ${source_desc}"
    echo ""
    printf '%b' "$errors"
    echo ""
    echo "  Policy: subject 10-72 chars, capitalized, no trailing period, not vague,"
    echo "  blank line before body, an issue reference (message or branch name)."
    echo "  See the policy at the top of scripts/check-commit-message.sh. Bypass (discouraged): git commit --no-verify"
    echo ""
  } >&2
  exit 1
fi

exit 0
