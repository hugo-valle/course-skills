#!/bin/bash

# Analyze the repository history for this lab's commit workflow.
# This script is informational and always exits successfully so students can
# still receive testing feedback even when their Git workflow needs work.
#
# This file is already generic -- if the lab you're adapting already has one
# of these (from a retiring lab_validation.yml-equivalent), reuse it as-is
# and just wire it into exercise-progress.yml per the skill's Phase 6.
# Otherwise, copy this file to .github/scripts/check_git_workflow.sh and only
# change the TASK_MESSAGE_PATTERN line below to match this lab's task names.

set -uo pipefail

BAD_MESSAGE_PATTERN='^(wip|update|stuff|temp|asdf|final|final final|fix)$'
CONVENTIONAL_PATTERN='^(feat|fix|docs|style|refactor|test|chore|perf|ci|build)(\(.+\))?!?:'
# LAB-SPECIFIC: task numbers and keywords that indicate a commit describes
# real task progress (used to compute task_related_count/task_related_met).
TASK_MESSAGE_PATTERN='(task[[:space:]]*[1234]|keyword one|keyword two|keyword three)'
COMMIT_COUNT_TARGET=3
TASK_RELATED_TARGET=3

echo "Analyzing Git workflow..."
echo ""

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || true)
if [ -z "$CURRENT_BRANCH" ]; then
    CURRENT_BRANCH="detached"
fi

if git show-ref --verify --quiet refs/heads/main; then
    HISTORY_REF="main"
else
    HISTORY_REF="HEAD"
fi

echo "Inspecting commit history from: $HISTORY_REF"

COMMIT_MESSAGES=$(git log "$HISTORY_REF" --no-merges --pretty="%s" 2>/dev/null || true)
LAST_FIVE_MESSAGES=$(git log "$HISTORY_REF" --no-merges --pretty="- %s" -5 2>/dev/null || true)

if [ -n "$COMMIT_MESSAGES" ]; then
    COMMIT_COUNT=$(printf '%s\n' "$COMMIT_MESSAGES" | wc -l | tr -d ' ')
    CONVENTIONAL_COUNT=$(printf '%s\n' "$COMMIT_MESSAGES" | grep -Ec "$CONVENTIONAL_PATTERN" || true)
    BAD_MESSAGE_COUNT=$(printf '%s\n' "$COMMIT_MESSAGES" | grep -Eic "$BAD_MESSAGE_PATTERN" || true)
    TASK_RELATED_COUNT=$(printf '%s\n' "$COMMIT_MESSAGES" | grep -Eic "$TASK_MESSAGE_PATTERN" || true)
    VAGUE_MESSAGES=$(printf '%s\n' "$COMMIT_MESSAGES" | grep -Ei "$BAD_MESSAGE_PATTERN" || true)
else
    COMMIT_COUNT=0
    CONVENTIONAL_COUNT=0
    BAD_MESSAGE_COUNT=0
    TASK_RELATED_COUNT=0
    VAGUE_MESSAGES=""
fi

COMMIT_COUNT_MET="no"
if [ "$COMMIT_COUNT" -ge "$COMMIT_COUNT_TARGET" ]; then
    COMMIT_COUNT_MET="yes"
fi

TASK_RELATED_MET="no"
if [ "$TASK_RELATED_COUNT" -ge "$TASK_RELATED_TARGET" ]; then
    TASK_RELATED_MET="yes"
fi

COMMIT_QUALITY_MET="no"
if [ "$BAD_MESSAGE_COUNT" -eq 0 ]; then
    COMMIT_QUALITY_MET="yes"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    {
        echo "current_branch=$CURRENT_BRANCH"
        echo "history_ref=$HISTORY_REF"
        echo "commit_count=$COMMIT_COUNT"
        echo "conventional_count=$CONVENTIONAL_COUNT"
        echo "bad_message_count=$BAD_MESSAGE_COUNT"
        echo "task_related_count=$TASK_RELATED_COUNT"
        echo "task_related_met=$TASK_RELATED_MET"
        echo "commit_count_target=$COMMIT_COUNT_TARGET"
        echo "commit_count_met=$COMMIT_COUNT_MET"
        echo "commit_quality_met=$COMMIT_QUALITY_MET"
        echo "vague_messages<<EOF"
        printf '%s\n' "$VAGUE_MESSAGES"
        echo "EOF"
        echo "last_five_messages<<EOF"
        printf '%s\n' "$LAST_FIVE_MESSAGES"
        echo "EOF"
    } >> "$GITHUB_OUTPUT"
fi

echo "=== GIT WORKFLOW REPORT ==="
echo "   Current branch:              $CURRENT_BRANCH"
echo "   History reference:           $HISTORY_REF"
echo "   Commits (non-merge):         $COMMIT_COUNT"
echo "   Conventional-format commits: $CONVENTIONAL_COUNT / $COMMIT_COUNT"
echo "   Vague commit messages:       $BAD_MESSAGE_COUNT"
echo "   Task-related commits:        $TASK_RELATED_COUNT"
echo "   3+ commits requirement met:  $COMMIT_COUNT_MET ($COMMIT_COUNT / $COMMIT_COUNT_TARGET)"
echo "   3 task-related commits met:  $TASK_RELATED_MET ($TASK_RELATED_COUNT / $TASK_RELATED_TARGET)"
echo "   Commit quality requirement:  $COMMIT_QUALITY_MET"
echo ""
if [ -n "$VAGUE_MESSAGES" ]; then
    echo "Vague commit messages detected:"
    printf '%s\n' "$VAGUE_MESSAGES"
    echo ""
fi
echo "Recent commits:"
if [ -n "$LAST_FIVE_MESSAGES" ]; then
    printf '%s\n' "$LAST_FIVE_MESSAGES"
else
    echo "- No commits found"
fi
echo ""
echo "Git workflow remains a manual grading category."
echo "This report only checks minimum commit count and basic commit-message quality."

exit 0
