#!/bin/bash
set -e

REPO_URL="https://github.com/readikus/progress.git"
INSTALL_DIR="$HOME/.progress/repo"
COMMANDS_DIR="$HOME/.claude/commands"

echo "Installing Progress skill for Claude Code..."

# Clone or update the repo
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "Updating existing installation..."
  git -C "$INSTALL_DIR" pull --quiet
else
  echo "Cloning repo..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

# Symlink commands into Claude Code
mkdir -p "$COMMANDS_DIR"
ln -sfn "$INSTALL_DIR/commands/progress" "$COMMANDS_DIR/progress"

echo ""
echo "Installed. Commands available:"
echo "  /progress:onboard   — set up your preferences"
echo "  /progress:standup   — concise standup summary"
echo "  /progress:sprint    — sprint demo with metrics"
echo "  /progress:review    — detailed personal review"
echo ""
echo "Run /progress:onboard in Claude Code to get started."
