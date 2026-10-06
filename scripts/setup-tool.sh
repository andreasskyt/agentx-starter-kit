#!/usr/bin/env bash
# Installs a wrapper tool behind its own service user:
#   the token is readable only by <name>-svc, and agents in group <name>-tool-users may run only
#   /usr/local/bin/<name>-tool as that user, via one sudoers line.
# Run as root on the server. The tool script must exist at $AGENTS_REPO/tools/<name>-tool.
# Usage: sudo setup-tool.sh <name> <secret-dest-filename> <secret-source-file|-> [agent-linux-user ...]
#   e.g. setup-tool.sh crm token.json /root/crm-token.json agentx-ada    ("-" keeps an installed secret)
set -euo pipefail
name="${1:?tool name, e.g. crm}"; dest="${2:?e.g. token.json}"; src="${3:?secret file or -}"; shift 3
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
[[ "$name" =~ ^[a-z0-9]+$ ]] || { echo "Name: lowercase letters and digits."; exit 1; }
repo="${AGENTS_REPO:-/opt/agents}"; svc="$name-svc"; group="$name-tool-users"; tool="$name-tool"
[[ -f "$repo/tools/$tool" ]] || { echo "Missing $repo/tools/$tool."; exit 1; }

id "$svc" >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin "$svc"
getent group "$group" >/dev/null || groupadd --system "$group"
install -m 755 -o root -g root "$repo/tools/$tool" "/usr/local/bin/$tool"
install -d -m 755 -o root -g root /etc/agents
install -d -m 700 -o "$svc" -g "$svc" "/etc/agents/$name"
if [[ "$src" != "-" ]]; then
  install -m 600 -o "$svc" -g "$svc" "$src" "/etc/agents/$name/$dest"
  shred -u "$src"
fi

tmp=$(mktemp)
echo "%$group ALL=($svc) NOPASSWD: /usr/local/bin/$tool" > "$tmp"
visudo -cf "$tmp" >/dev/null
install -m 440 -o root -g root "$tmp" "/etc/sudoers.d/$tool"
shred -u "$tmp"

for u in "$@"; do usermod -aG "$group" "$u"; done
echo "Installed $tool. Agents run: sudo -u $svc /usr/local/bin/$tool <command>"
echo "Add to managed-settings allow: \"Bash(sudo -u $svc /usr/local/bin/$tool *)\""
