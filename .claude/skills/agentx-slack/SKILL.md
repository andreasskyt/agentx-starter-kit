---
name: agentx-slack
description: Optional two-way Slack for AgentX agents: one Slack app per agent from a manifest, slack-post for reports, and a Socket Mode listener so the owner can @mention or DM an agent and get the answer in the thread. Use for "connect my agents to Slack", "/agentx-slack", "talk to my agent in Slack".
---

# Slack for agents

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`. Detail: `docs/09-slack.md`. Files: `templates/slack-app-manifest.json`, `scripts/slack/`.

Prerequisites: an agent server with the agent provisioned, an AgentX API token for the listener (`agentx-api`), a Slack workspace where they can create apps.

## Steps

1. **App per agent:** fill the manifest (`<role>`, `<Persona>`, `<Owner>`) and have them create the app from it at https://api.slack.com/apps, install it, generate an app-level token with `connections:write`. Tokens stay in the browser until a hidden prompt on the server asks for them.
2. **Channel** `#<persona>-<role>` and `/invite @<Persona>`. Note the channel ID and their member ID.
3. **Outbound:** re-run `provision-agent.sh <role> <Persona>` and give the bot token at the hidden prompt. Add `"Bash(slack-post *)"` to the managed settings allow list. Test: as the agent, `slack-post "test"` (their yes on the exact text first).
4. **Listener, once per server:** `sudo bash /opt/agents/scripts/slack/setup-listener.sh`.
5. **Per agent:** `sudo bash /opt/agents/scripts/slack/add-listener.sh <role> <Persona>`, then `systemctl enable --now agents-slack-listener` and check `journalctl -u agents-slack-listener` for "connected as".
6. **Test:** they @mention the agent in its channel. Expect an instant acknowledgement, then the answer in the thread.

Never invite agent bots to shared or customer channels.
