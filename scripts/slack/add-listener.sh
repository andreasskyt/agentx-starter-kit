#!/usr/bin/env bash
# Lets the owner @mention an agent in Slack. Run as root after provision-agent.sh (with Slack) and setup-listener.sh.
# Reuses the agent's bot token and asks only for its app-level token (xapp-, scope connections:write).
# Usage: sudo add-listener.sh <role> <AgentX agent name>
set -euo pipefail
role="${1:?role key, e.g. mail}"
agent="${2:?AgentX agent name, e.g. Ada}"
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
src="/etc/agents/$role/slack.env"
[[ -f "$src" ]] || { echo "Missing $src. Run provision-agent.sh with a Slack token first."; exit 1; }
[[ -d /etc/agents/listener ]] || { echo "Run setup-listener.sh first."; exit 1; }
source "$src"

read -rsp "App-level token for $agent (xapp-..., hidden): " app; echo
[[ "$app" == xapp-* ]] || { echo "That is not an app-level token (should start with xapp-)."; exit 1; }
bubble="$(echo "$agent" | tr '[:upper:]' '[:lower:]')-slack"

( umask 077; printf 'SLACK_APP_TOKEN=%s\nSLACK_BOT_TOKEN=%s\nSLACK_OWNER=%s\nPERSONA=%s\nAGENTX_AGENT=%s\nAGENTX_BUBBLE=%s\n' \
  "$app" "$SLACK_BOT_TOKEN" "$SLACK_OWNER" "${SLACK_USERNAME:-$agent}" "$agent" "$bubble" > "/etc/agents/listener/$role.env" )
chown agents-slack-listener:agents-slack-listener "/etc/agents/listener/$role.env"
unset app SLACK_BOT_TOKEN

systemctl restart agents-slack-listener 2>/dev/null || true
echo "Done. @$agent in Slack now reaches AgentX agent '$agent' (bubble $bubble)."
