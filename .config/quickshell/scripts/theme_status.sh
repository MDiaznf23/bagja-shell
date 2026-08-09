#!/bin/bash
# Check the status of a single theme.
# Usage: theme_status.sh <name> <repo_url> <branch>
# Output: not_installed | installed | update_available | error

set -uo pipefail

NAME="${1:?theme name is required}"
REPO="${2:?repo url is required}"
BRANCH="${3:-main}"

STAGING="$HOME/.cache/quickshell/staging/$NAME"
DEST="$HOME/.local/share/quickshell-themes/$NAME"

# never installed at all
if [ ! -d "$DEST" ] || [ ! -d "$STAGING/.git" ]; then
  echo "not_installed"
  exit 0
fi

LOCAL_HASH="$(git -C "$STAGING" rev-parse HEAD 2>/dev/null)"
REMOTE_HASH="$(git ls-remote "$REPO" "refs/heads/$BRANCH" 2>/dev/null | cut -f1)"

if [ -z "$REMOTE_HASH" ]; then
  # can't reach remote (offline / repo moved), just assume installed
  echo "installed"
  exit 0
fi

if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
  echo "installed"
else
  echo "update_available"
fi
