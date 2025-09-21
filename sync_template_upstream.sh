#!/bin/bash
set -e  # Exit if any command fails

# -------------------------------------------------------
# Script to sync this repository with upstream template A
# Usage: ./sync_upstream.sh
# -------------------------------------------------------

UPSTREAM_URL="https://github.com/chenyongquan2/cc-template.git"
UPSTREAM_NAME="upstream"
UPSTREAM_BRANCH="main"

echo ">>> Checking if remote '$UPSTREAM_NAME' already exists..."
if git remote get-url "$UPSTREAM_NAME" >/dev/null 2>&1; then
    echo ">>> Remote '$UPSTREAM_NAME' already exists. Skipping add."
else
    echo ">>> Adding upstream remote: $UPSTREAM_URL"
    git remote add "$UPSTREAM_NAME" "$UPSTREAM_URL"
fi

echo ">>> Fetching latest changes from $UPSTREAM_NAME..."
git fetch "$UPSTREAM_NAME"

echo ">>> Merging branch '$UPSTREAM_BRANCH' from upstream..."
# Use --allow-unrelated-histories to handle template-based repos
git merge "$UPSTREAM_NAME/$UPSTREAM_BRANCH" --allow-unrelated-histories || {
    echo ">>> Merge conflicts detected! Please resolve them manually."
    exit 1
}

echo ">>> Sync completed successfully ✅"