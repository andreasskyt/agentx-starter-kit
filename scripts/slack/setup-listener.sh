#!/usr/bin/env bash
# One-time: installs the Slack listener that lets the owner @mention agents in Slack.
# Run as root on the agents server. Asks (hidden) for an AgentX API token made just for the listener.
# Then add agents with: sudo add-listener.sh <role> <AgentX agent name>
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }
here="$(cd "$(dirname "$0")" && pwd)"
svc=agents-slack-listener

id "$svc" >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin "$svc"
apt-get install -y -qq python3-venv >/dev/null
install -d -m 755 -o root -g root "/opt/$svc"
[[ -x "/opt/$svc/venv/bin/python" ]] || python3 -m venv "/opt/$svc/venv"
"/opt/$svc/venv/bin/pip" install -q slack-sdk==3.45.0
install -m 755 -o root -g root "$here/agent-listener" /usr/local/bin/agent-listener

install -d -m 755 -o root -g root /etc/agents
install -d -m 700 -o "$svc" -g "$svc" /etc/agents/listener
if [[ ! -s /etc/agents/listener/agentx.env ]]; then
  read -rsp "AgentX API token for the listener (hidden): " key; echo
  ( umask 077; printf 'AGENTX_API_KEY=%s\n' "$key" > /etc/agents/listener/agentx.env )
  chown "$svc:$svc" /etc/agents/listener/agentx.env
  unset key
fi

read -rp "Your first name for greetings (optional): " owner_name
read -rp "Your timezone, e.g. Europe/Berlin (Enter for UTC): " tz
sed -e "s|@OWNER_NAME@|${owner_name}|" -e "s|@TZ_NAME@|${tz:-UTC}|" "$here/$svc.service" > "/etc/systemd/system/$svc.service"
chmod 644 "/etc/systemd/system/$svc.service"
systemctl daemon-reload
echo "Installed. Add an agent with add-listener.sh, then: systemctl enable --now $svc"
