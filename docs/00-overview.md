# 00. How AgentX fits together

## The pieces

| Piece | What it is | Where it lives |
|---|---|---|
| **Daemon** | A small program on your machine that starts, supervises and resumes your agents. | Your laptop, Mac mini or VPS. |
| **Agent CLI** | The coding agent the daemon runs: Claude Code (`claude`), Codex (`codex`), Grok CLI (`grok`); Cursor Agent, Junie, Pi and OpenCode are beta or experimental. List: https://www.agentxhq.com/supported-agents | Installed on the same machine as the daemon. |
| **Agent** | A named, persistent instance of one CLI with its own settings, prompt, environment variables and (on a server) its own Linux user. | Registered in the daemon. |
| **Bubble** | A conversation. An agent has one session per bubble; bubbles run in parallel. Bubbles can hold several agents, even from different vendors (Claude writes, Codex reviews). | Daemon. |
| **Console** | The web UI at https://www.agentxhq.com (works on a phone). Locally the daemon also serves one at http://127.0.0.1:3333. | Browser. |
| **Automations** | Scheduled messages to an agent: daily or weekly at a set time. | Set per agent in the console. |
| **API / MCP** | A web API (`https://www.agentxhq.com/api/v1`) to list and create agents and bubbles, send messages and read output. Also an MCP server you can call from Claude.ai or ChatGPT. | AgentX cloud, routed to your daemon. |

## Where your data goes

- Agents, sessions, messages and artifacts live in a **local SQLite database on the daemon's machine**.
- AgentX's cloud ("core") holds identity, billing, which daemons and agents exist, and message **counts** (never content).
- When you open the console, live terminal output and transcripts are **relayed** through AgentX's edge, held in memory only.
- **Your model keys and subscriptions stay on your machine.** AgentX never proxies or bills inference.

Details: https://www.agentxhq.com/trust

## Behaviour worth knowing

- **Resume:** after a reboot or when a laptop wakes, a resume policy restarts agents and they continue where they stopped.
- **Idle reap:** idle agents shut down after a short time and start again on the next message. Each running agent uses roughly 300 MB RAM.
- **Run as:** in server mode the daemon runs as root and can give each agent its own Linux user. On a laptop, agents run as you.
- **Agents can manage agents:** an agent can be allowed to create and message other agents. Keep this off except for a deliberate "manager" agent.

## Pricing in one line

You pay AgentX per **message** (one instruction or reply), not per token, agent or machine. There's a free tier; paid tiers add message volume and seats. Your model subscription (Claude, ChatGPT and so on) is billed separately by its vendor. Current numbers: https://www.agentxhq.com/pricing

## What AgentX doesn't do (yet)

Check the console for the current state, but as of 0.144.x:

- **Scheduling is time-based only** (daily or weekly). No inbound webhooks or event triggers. For "react to new email" style jobs, run the agent several times a day and have it process everything new since its last run (a checkpoint).
- **No native Slack.** See [09-slack.md](09-slack.md) for a small bridge you run yourself.
- **Permissions are basic.** For Claude agents, the console's Access settings (Sandbox, Approval, Network) were observed to have no effect in 0.144.4: Claude still starts in bypass-permissions mode. Lock down with Linux users and Claude Code's managed settings instead ([08-security.md](08-security.md)).
- **Docs are thin.** This kit exists for that reason.
