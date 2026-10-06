#!/usr/bin/env bash
# Links this kit's Claude Code skills into ~/.claude/skills so they work in any folder.
# The skills read the guides in this repo, so keep the clone where it is.
set -euo pipefail
kit="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/.claude/skills"
for s in "$kit"/.claude/skills/*/; do
  name=$(basename "$s")
  ln -sfn "$s" "$HOME/.claude/skills/$name"
  echo "linked $name"
done
mkdir -p "$HOME/.config"; echo "$kit" > "$HOME/.config/agentx-starter-kit-path"
echo "Kit path saved to ~/.config/agentx-starter-kit-path"
