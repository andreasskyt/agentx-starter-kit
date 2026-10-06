#!/usr/bin/env bash
# Wires an AgentX-created Linux user up as an agent: prompt, outputs, first-run answers, optional Slack and tool groups.
# Run as root on the server AFTER: the agent exists in AgentX ("Run as: Create new user") and
# its prompt is at $AGENTS_REPO/agents/<role>/CLAUDE.md.
# Usage: sudo provision-agent.sh <role> <Persona> [extra-group ...]
#   AGENTS_REPO   checkout of your prompts repo (default /opt/agents)
#   NO_SLACK=1    skip the Slack setup
set -euo pipefail
role="${1:?role key, e.g. mail}"; persona="${2:?persona, e.g. Ada}"; shift 2
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
[[ "$role" =~ ^[a-z0-9-]+$ ]] || { echo "Role: lowercase letters, digits and dashes only."; exit 1; }
repo="${AGENTS_REPO:-/opt/agents}"
[[ -d "$repo/.git" ]] && git -C "$repo" pull -q || true

user="agentx-$(echo "$persona" | tr '[:upper:] ' '[:lower:]-')"
id "$user" >/dev/null 2>&1 || { echo "No Linux user $user. Create $persona in AgentX first (Run as: Create new user)."; exit 1; }
prompt="$repo/agents/$role/CLAUDE.md"
[[ -f "$prompt" ]] || { echo "Missing $prompt."; exit 1; }
home=$(getent passwd "$user" | cut -d: -f6)
secrets="/etc/agents/$role"

install -d -m 755 -o root -g root /etc/agents
install -d -m 700 -o "$user" -g "$user" "$secrets"
ln -sfn "$prompt" "$home/CLAUDE.md"
install -d -m 755 -o "$user" -g "$user" "$home/outputs" "$home/state"

if [[ "${NO_SLACK:-}" != "1" ]]; then
  read -rsp "Slack bot token for $persona (xoxb-..., hidden, Enter to skip): " token; echo
  if [[ -n "$token" ]]; then
    curl -sS -X POST https://slack.com/api/auth.test -H @- <<< "Authorization: Bearer $token" | grep -q '"ok":true' \
      || { echo "Slack rejected the token."; exit 1; }
    read -rp "Channel ID of #<persona>-<role> (starts with C): " channel
    read -rp "Your Slack member ID, for urgent mentions (starts with U): " owner
    ( umask 077; printf 'SLACK_BOT_TOKEN=%s\nSLACK_CHANNEL=%s\nSLACK_OWNER=%s\nSLACK_USERNAME=%q\n' "$token" "$channel" "$owner" "$persona" > "$secrets/slack.env" )
    chown "$user:$user" "$secrets/slack.env"
    ln -sfn "$secrets/slack.env" "$home/.slack.env"
    [[ -f "$repo/scripts/slack/slack-post" ]] && install -m 755 "$repo/scripts/slack/slack-post" /usr/local/bin/slack-post
  fi
  unset token
fi

for g in "$@"; do usermod -aG "$g" "$user"; echo "Added $user to $g"; done

# Pre-answer Claude Code's first-run screens and the external-import question,
# which otherwise block an unattended agent. AgentX runs agents in ~/.agentx/<agent name>.
python3 - "$home" "$persona" <<'PY'
import json, os, sys
home, agent = sys.argv[1], sys.argv[2]
def load(p):
    try: return json.load(open(p))
    except Exception: return {}
cj = os.path.join(home, ".claude.json"); d = load(cj)
d["hasCompletedOnboarding"] = True
d.setdefault("projects", {}).setdefault(os.path.join(home, ".agentx", agent), {}).update(
    {"hasClaudeMdExternalIncludesApproved": True, "hasClaudeMdExternalIncludesWarningShown": True, "hasTrustDialogAccepted": True})
json.dump(d, open(cj, "w"), indent=2)
sp = os.path.join(home, ".claude", "settings.json"); os.makedirs(os.path.dirname(sp), exist_ok=True)
s = load(sp); s.update({"theme": "dark", "skipDangerousModePermissionPrompt": True})
json.dump(s, open(sp, "w"), indent=2)
PY
chown -R "$user:$user" "$home/.claude.json" "$home/.claude"

echo "Provisioned $persona ($role) as $user. Prompt: $prompt. Logs: $home/outputs."
echo "Test: message $persona in the console: 'Who are you and what is your job?'"
