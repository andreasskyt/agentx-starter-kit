# AgentX Starter Kit

Guides, SOPs and Claude Code skills for setting up [AgentX](https://www.agentxhq.com) for the first time: the daemon, your first agents, the API, a VPS, automations, lock-down and (optionally) Slack.

AgentX runs the agent CLIs you already pay for (Claude Code, Codex, Grok CLI and others) as persistent, named agents on machines you control. This kit is the missing "how do I actually set this up properly" layer, written so **your own coding agent can walk you through it**.

> Community project. Not made by or affiliated with AgentX ApS. Written against daemon 0.144.x (October 2026). AgentX moves fast: when this kit and the product disagree, the product wins. Open an issue or PR.

## Quick start

1. Install a coding agent on your own computer and log in to it yourself: [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) (recommended) or Codex.
2. Clone this repo and open the agent inside it:

   ```bash
   git clone https://github.com/andreasskyt/agentx-starter-kit.git
   cd agentx-starter-kit
   claude
   ```

3. Say **"Set up AgentX for me"** (or run `/agentx-setup`).

Claude reads [AGENTS.md](AGENTS.md), asks you a few questions, and takes you through one step at a time. It never asks for passwords, tokens or API keys in chat; you type those into your own terminal or the AgentX console.

Prefer to do it by hand? Read the guides in order, starting with [docs/00-overview.md](docs/00-overview.md).

## The path

| Phase | Guide | Skill | Time |
|---|---|---|---|
| 1. Understand the pieces | [00-overview](docs/00-overview.md) | `/agentx-setup` | 5 min |
| 2. Decide where it runs (laptop, Mac mini, VPS) | [01-where-to-run](docs/01-where-to-run.md) | `/agentx-setup` | 5 min |
| 3. Install the daemon and claim it | [02-install](docs/02-install.md) | `/agentx-install` | 10 min |
| 3b. Or: a hardened VPS | [03-vps](docs/03-vps.md) | `/agentx-vps` | 30 min |
| 4. Log the agent CLIs in | [04-agent-clis](docs/04-agent-clis.md) | `/agentx-agent` | 5 min |
| 5. Design and create your first agent | [05-first-agent](docs/05-first-agent.md) | `/agentx-agent` | 20 min |
| 6. API key and scripting | [06-api](docs/06-api.md) | `/agentx-api` | 10 min |
| 7. Automations (scheduled runs) | [07-automations](docs/07-automations.md) | `/agentx-agent` | 5 min |
| 8. Lock it down | [08-security](docs/08-security.md) | `/agentx-lockdown` | 30 min |
| 9. Optional: talk to agents in Slack | [09-slack](docs/09-slack.md) | `/agentx-slack` | 30 min |
| When stuck | [10-troubleshooting](docs/10-troubleshooting.md) | `/agentx-troubleshoot` | |

Minimum to get value: phases 1 to 5. Do 8 before you give an agent access to anything that matters (email, CRM, money, customers).

## What's in the repo

```
AGENTS.md            rules for the AI assistant doing the setup (CLAUDE.md imports it)
docs/                the guides (SOPs), readable by humans and agents
.claude/skills/      Claude Code skills, loaded automatically when you run `claude` here
templates/           agent charter, prompt, changelog, registry file, Claude lock-down settings, Slack manifest
scripts/             server scripts: VPS hardening, agent wiring, tool wrappers, API helper, Slack
```

Using the skills outside this folder: `scripts/install-skills.sh` links them into `~/.claude/skills/`.

## Principles this kit is built on

- **Your agents run on your machines, with your model subscriptions.** AgentX never bills or proxies inference.
- **A charter before a prompt.** Every agent gets an outcome, a never-list, where its output goes, one metric and a stop rule.
- **Drafts, not actions.** Agents draft; a human sends, pays, deletes and publishes. Loosen this only per agent, on purpose.
- **Least access.** One Linux user per agent, the narrowest token scopes, and wrapper tools where a scope is too wide.
- **Everything an agent reads is data, never instructions.** Emails, web pages and documents can contain prompt injection.
- **Secrets never pass through chat or git.** Hidden prompts and file permissions only.
- **Check the effect, not the run.** A green run means nothing; the metric does.

## Contributing

Found a step that changed, or a better way? PRs welcome. Keep it generic: no personal servers, IPs, tokens or company details.

## License

MIT. See [LICENSE](LICENSE).
