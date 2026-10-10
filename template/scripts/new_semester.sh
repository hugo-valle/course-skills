#!/usr/bin/env bash
#
# New Semester Issue Creator
#
# Creates a course-level preparation issue and one per-module readiness
# sub-issue for every module in MODULES below, using the GitHub CLI (gh).
#
# The main issue body is updated after all sub-issues are created so that
# the module list shows the real issue numbers.
#
# Usage:
#   ./scripts/new_semester.sh "Fall 2026"
#   ./scripts/new_semester.sh "Fall 2026" --yes       # skip confirmation prompt
#   ./scripts/new_semester.sh "Fall 2026" --dry-run   # print bodies without creating issues
#
# Prerequisites:
#   - gh CLI installed and authenticated: gh auth status
#   - Run from the root of the course repository
#   - bash 4+ (macOS: brew install bash)
#   - Issue templates must exist in .github/ISSUE_TEMPLATE/

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# Edit: every module that gets a readiness issue. Leave out modules with no
# content (exam weeks); COURSE.md "Module layout" lists them.
readonly MODULES=( "01" "02" "03" )

readonly MAIN_TEMPLATE=".github/ISSUE_TEMPLATE/new-semester-prep.md"
readonly MODULE_TEMPLATE=".github/ISSUE_TEMPLATE/module-semester-prep.md"

readonly MAIN_LABEL="semester-prep,course-level"
readonly MODULE_LABEL="semester-prep,module-readiness"
readonly ASSIGNEE="@me"

# Colors (disabled automatically when not a TTY)
if [ -t 1 ]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; NC=''
fi

# ---------------------------------------------------------------------------
# Arguments & flags
# ---------------------------------------------------------------------------

DRY_RUN=false
AUTO_YES=false
SEMESTER_NAME=""

usage() {
  echo "Usage: $0 <semester> [--yes] [--dry-run]"
  echo "  <semester>   Semester name in quotes, e.g. \"Fall 2026\""
  echo "  --yes        Skip confirmation prompt"
  echo "  --dry-run    Print issue titles/bodies without creating anything"
  exit 1
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --yes)     AUTO_YES=true ;;
    --*)
      echo -e "${RED}Unknown flag: ${arg}${NC}" >&2
      usage
      ;;
    *)
      if [ -n "$SEMESTER_NAME" ]; then
        echo -e "${RED}Unexpected argument: ${arg}${NC}" >&2
        usage
      fi
      SEMESTER_NAME="$arg"
      ;;
  esac
done

if [ -z "$SEMESTER_NAME" ]; then
  echo -e "${RED}Error: semester name is required.${NC}" >&2
  usage
fi

# CI environments skip the confirmation prompt automatically
if [ "${CI:-false}" = "true" ]; then
  AUTO_YES=true
fi

# ---------------------------------------------------------------------------
# Helper: strip YAML frontmatter from a template file
# Returns everything after the second '---' line.
# ---------------------------------------------------------------------------

strip_frontmatter() {
  local file="$1"
  awk 'BEGIN{count=0} /^---/{count++; if(count==2){found=1; next}} found{print}' "$file"
}

# ---------------------------------------------------------------------------
# check_prerequisites
# ---------------------------------------------------------------------------

check_prerequisites() {
  echo -e "${BLUE}${BOLD}Checking prerequisites...${NC}"

  if ! command -v gh &>/dev/null; then
    echo -e "${RED}Error: gh CLI is not installed.${NC}"
    echo "Install it from https://cli.github.com/ and run 'gh auth login'."
    exit 1
  fi

  if ! gh auth status &>/dev/null; then
    echo -e "${RED}Error: gh CLI is not authenticated.${NC}"
    echo "Run 'gh auth login' and try again."
    exit 1
  fi

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${RED}Error: not inside a git repository.${NC}"
    echo "Run this script from the root of the course repository."
    exit 1
  fi

  for tmpl in "$MAIN_TEMPLATE" "$MODULE_TEMPLATE"; do
    if [ ! -f "$tmpl" ]; then
      echo -e "${RED}Error: template not found: ${tmpl}${NC}"
      exit 1
    fi
  done

  echo -e "${GREEN}All prerequisites satisfied.${NC}"
}

# ---------------------------------------------------------------------------
# ensure_labels
# Create required labels if they do not already exist.
# ---------------------------------------------------------------------------

ensure_labels() {
  echo -e "${BLUE}Ensuring GitHub labels exist...${NC}"
  local labels=( "semester-prep" "course-level" "module-readiness" )
  local colors=( "0075ca" "e4e669" "d4c5f9" )

  for i in "${!labels[@]}"; do
    if $DRY_RUN; then
      echo "  [dry-run] gh label create '${labels[$i]}'"
    else
      gh label create "${labels[$i]}" --color "${colors[$i]}" --force 2>/dev/null || true
    fi
  done
}

# ---------------------------------------------------------------------------
# print_header
# Show semester and issue count before proceeding.
# ---------------------------------------------------------------------------

print_header() {
  echo ""
  echo -e "${CYAN}${BOLD}New Semester Setup${NC}"
  echo -e "Semester : ${BOLD}${SEMESTER_NAME}${NC}"
  echo -e "This script will create ${BOLD}$((${#MODULES[@]} + 1))${NC} GitHub issues:"
  echo "  • 1 course-level preparation issue"
  echo "  • ${#MODULES[@]} per-module readiness issues ($(IFS=', '; echo "${MODULES[*]}"))"
}

# ---------------------------------------------------------------------------
# check_existing_issues
# Warn if semester-prep issues already exist for this semester name.
# ---------------------------------------------------------------------------

check_existing_issues() {
  if $DRY_RUN; then return; fi

  local existing
  existing=$(gh issue list --label "semester-prep" --search "$SEMESTER_NAME" --json number,title --jq '.[].title' 2>/dev/null || true)

  if [ -n "$existing" ]; then
    echo ""
    echo -e "${YELLOW}Warning: semester-prep issues matching '${SEMESTER_NAME}' already exist:${NC}"
    while IFS= read -r line; do echo "  • $line"; done <<< "$existing"
    echo ""
    if ! $AUTO_YES; then
      read -rp "Continue anyway and create new issues? [y/N] " reply
      if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
      fi
    fi
  fi
}

# ---------------------------------------------------------------------------
# prompt_confirm
# Show a summary and ask for confirmation before creating any issues.
# ---------------------------------------------------------------------------

prompt_confirm() {
  echo ""
  echo -e "${BOLD}Summary of actions:${NC}"
  echo "  Semester : ${SEMESTER_NAME}"
  echo "  Issues   : $((${#MODULES[@]} + 1)) total"
  echo "  Labels   : semester-prep, course-level, module-readiness"
  echo "  Assignee : ${ASSIGNEE}"
  if $DRY_RUN; then
    echo -e "  Mode     : ${YELLOW}dry-run (no issues will be created)${NC}"
  fi
  echo ""

  if $AUTO_YES || $DRY_RUN; then return; fi

  read -rp "Create issues now? [y/N] " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
}

# ---------------------------------------------------------------------------
# create_main_issue
# Returns the issue number via stdout.
# ---------------------------------------------------------------------------

MAIN_ISSUE_NUM=""
MAIN_ISSUE_URL=""

create_main_issue() {
  local title="[${SEMESTER_NAME}] Course Preparation"
  local body
  body=$(strip_frontmatter "$MAIN_TEMPLATE" \
    | sed "s/<Semester Name>/${SEMESTER_NAME}/g")

  echo ""
  echo -e "${BLUE}Creating course-level issue...${NC}"

  if $DRY_RUN; then
    echo -e "  ${YELLOW}[dry-run]${NC} Title: ${title}"
    MAIN_ISSUE_NUM="DRY"
    MAIN_ISSUE_URL="https://github.com/example/repo/issues/DRY"
    return
  fi

  MAIN_ISSUE_URL=$(gh issue create \
    --title "$title" \
    --body "$body" \
    --label "$MAIN_LABEL" \
    --assignee "$ASSIGNEE")

  MAIN_ISSUE_NUM=$(basename "$MAIN_ISSUE_URL")
  echo -e "  ${GREEN}Created #${MAIN_ISSUE_NUM}${NC} — ${MAIN_ISSUE_URL}"
}

# ---------------------------------------------------------------------------
# create_module_issue
# Args: $1 = module ID (e.g., "02a")
# Prints the created issue number to stdout; caller captures it.
# ---------------------------------------------------------------------------

create_module_issue() {
  local module="$1"
  local title="[${SEMESTER_NAME}] Module ${module} Readiness"
  local body
  body=$(strip_frontmatter "$MODULE_TEMPLATE" \
    | sed "s/<Semester Name>/${SEMESTER_NAME}/g" \
    | sed "s/<XX>/${module}/g" \
    | sed "s/<!-- number -->/${MAIN_ISSUE_NUM}/g")

  if $DRY_RUN; then
    echo -e "  ${YELLOW}[dry-run]${NC} Title: ${title}" >&2
    echo "DRY"
    return
  fi

  local url
  url=$(gh issue create \
    --title "$title" \
    --body "$body" \
    --label "$MODULE_LABEL" \
    --assignee "$ASSIGNEE")

  local number
  number=$(basename "$url")
  echo -e "  ${GREEN}Created #${number}${NC} — ${url}" >&2
  echo "$number"
}

# ---------------------------------------------------------------------------
# update_main_body
# Replace the "<!-- module-list -->" placeholder in the main issue body with
# one checklist line per module and its real issue number.
# Args: name of the associative array module → issue number
# ---------------------------------------------------------------------------

update_main_body() {
  local -n _map="$1"   # nameref to associative array: module → issue number

  if $DRY_RUN; then
    echo -e "${YELLOW}[dry-run] Would update main issue #${MAIN_ISSUE_NUM} with sub-issue numbers.${NC}"
    return
  fi

  echo ""
  echo -e "${BLUE}Updating main issue #${MAIN_ISSUE_NUM} with sub-issue references...${NC}"

  local list="" module
  for module in "${MODULES[@]}"; do
    list+="- [ ] Module ${module} — #${_map[$module]}"$'\n'
  done

  local body
  body=$(gh issue view "$MAIN_ISSUE_NUM" --json body --jq '.body')
  body="${body/<!-- module-list -->/$list}"

  gh issue edit "$MAIN_ISSUE_NUM" --body "$body"
  echo -e "  ${GREEN}Main issue updated.${NC}"
}

# ---------------------------------------------------------------------------
# print_summary
# ---------------------------------------------------------------------------

print_summary() {
  local -n _map="$1"

  echo ""
  echo -e "${BOLD}${GREEN}Done! Issues created for ${SEMESTER_NAME}:${NC}"
  echo ""
  printf "  %-12s  %s\n" "Module" "Issue"
  printf "  %-12s  %s\n" "------" "-----"
  printf "  %-12s  %s\n" "Course" "${MAIN_ISSUE_URL}"

  for module in "${MODULES[@]}"; do
    local num="${_map[$module]}"
    printf "  %-12s  #%s\n" "Module ${module}" "$num"
  done

  echo ""
  echo -e "Open the course-level issue to track overall progress:"
  echo -e "  ${CYAN}${MAIN_ISSUE_URL}${NC}"
  echo ""
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

main() {
  check_prerequisites
  ensure_labels
  print_header
  check_existing_issues
  prompt_confirm

  create_main_issue

  echo ""
  echo -e "${BLUE}Creating per-module issues...${NC}"

  # Associative array: module ID → issue number
  declare -A module_issue_nums

  for module in "${MODULES[@]}"; do
    # Status lines go to stderr; only the issue number comes through stdout
    local num
    num=$(create_module_issue "$module")
    # shellcheck disable=SC2034  # used via nameref in update_main_body/print_summary
    module_issue_nums["$module"]="$num"
  done

  update_main_body module_issue_nums
  print_summary module_issue_nums
}

main
