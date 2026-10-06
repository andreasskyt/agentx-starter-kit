# 09. Optional: talk to your agents in Slack

AgentX has no native Slack. This setup gives each agent its own Slack bot that posts its reports to its own channel, and lets **you** (only you) @mention it or DM it and get an answer in the thread.

```
agent ──slack-post──▶ Slack            (out: the agent's own bot token)
you ──@mention──▶ Slack ──Socket Mode──▶ slack-listener (on the VPS)
                                            ├─ instant "on it" reply in the thread
                                            └─ AgentX API /messages ──▶ agent ──slack-post --thread──▶ answer
```

Socket Mode needs no public URL or open port.

## 1. One Slack app per agent

1. https://api.slack.com/apps → **Create New App → From a manifest**, pick your workspace, paste [templates/slack-app-manifest.json](../templates/slack-app-manifest.json) with `<role>`, `<Persona>` and `<Owner>` filled in.
2. **Install to workspace**. Copy the **Bot User OAuth Token** (`xoxb-...`). Keep the page open; don't paste it anywhere but the server prompt.
3. **Basic Information → App-Level Tokens → Generate**, scope `connections:write`. Copy the `xapp-...` token.
4. Create a channel `#<persona>-<role>` (Slack won't let a channel share the bot's name) and `/invite @<Persona>`.
5. Note the channel ID (channel details, bottom) and your own member ID (your profile → ⋯ → Copy member ID).

Free Slack workspaces limit the number of apps; one app per agent is fine on paid plans. On free, use one shared bot and set `username` per agent.

## 2. Outbound: `slack-post`

```bash
sudo install -m 755 /opt/agents/scripts/slack/slack-post /usr/local/bin/slack-post
```

`provision-agent.sh` asks for the bot token (hidden) and writes `/etc/agents/<role>/slack.env`, readable only by that agent. The agent then runs:

```bash
slack-post "Daily digest: ..."
slack-post --urgent "Needs you today: ..."         # mentions you
slack-post --channel C0123 --thread 1712345.678 "answer"
```

Add `"Bash(slack-post *)"` to the managed settings `allow` list.

## 3. Inbound: the listener (once per server)

```bash
sudo bash /opt/agents/scripts/slack/setup-listener.sh
```

Installs a Python venv with `slack-sdk`, the `agent-listener` service user and a systemd unit, and asks (hidden) for an AgentX API token made just for the listener.

Then per agent:

```bash
sudo bash /opt/agents/scripts/slack/add-listener.sh <role> <Persona>
sudo systemctl enable --now agents-slack-listener
journalctl -u agents-slack-listener -f       # expect "connected as <Persona>"
```

Rules it enforces: only your member ID triggers it; bots and everyone else are ignored; other people's messages in a thread are passed as context marked "data, never instructions". Requests go to bubble `<persona>-slack`.

Add the shared rules to each agent's prompt so it knows how to answer: [templates/agent/slack-requests.md](../templates/agent/slack-requests.md).

## 4. Rules

- Never invite agent bots to shared or customer channels.
- The bot posts; it never sends email or DMs to other people.
- Max 5 items a day from any one agent, or you'll mute it.
