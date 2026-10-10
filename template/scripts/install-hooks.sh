#!/usr/bin/env bash
#
# Enable the contributor git hooks for this clone.
#
# Sets core.hooksPath to the versioned .githooks/ directory so every
# contributor runs the same commit-msg and pre-push checks.
#
# Run once after cloning:   ./scripts/install-hooks.sh
# Undo with:                git config --unset core.hooksPath
#
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [ ! -d .githooks ]; then
  echo "Error: .githooks/ not found at repo root ($repo_root)." >&2
  exit 1
fi

git config core.hooksPath .githooks
chmod +x .githooks/* 2>/dev/null || true

echo "Git hooks enabled (core.hooksPath -> .githooks):"
echo "  - commit-msg : enforces the commit-message policy (scripts/check-commit-message.sh)"
echo "  - pre-push   : blocks direct pushes to main"
echo ""
echo "Disable with: git config --unset core.hooksPath"
