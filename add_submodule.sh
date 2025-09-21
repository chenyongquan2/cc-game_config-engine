#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# -------------------------------------------------------------------
# This script adds a Git submodule and initializes it properly
# -------------------------------------------------------------------

# Variables (you can change them if needed)
REPO_URL="https://github.com/chenyongquan2/cc-common.git"
BRANCH="main"
DEST_DIR="cc-common"

echo ">>> Adding submodule from $REPO_URL (branch: $BRANCH) ..."
git submodule add -b "$BRANCH" "$REPO_URL" "$DEST_DIR"

echo ">>> Initializing and updating submodules (force & recursive) ..."
git submodule update --init --force --recursive

echo ">>> Submodule setup completed successfully ✅"