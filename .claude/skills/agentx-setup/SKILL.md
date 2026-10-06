---
name: agentx-setup
description: Start here to set up AgentX (agentxhq.com) for the first time. Interviews the person, picks the path (laptop, Mac mini or VPS), tracks progress and hands off to the other agentx-* skills. Use for "set up AgentX", "/agentx-setup", "help me get started with AgentX", "continue my AgentX setup".
---

# AgentX setup: the orchestrator

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`.

## 1. Resume or start

Read `local/progress.md` if it exists and continue from the first unchecked phase. Otherwise create it from the template at the bottom.

## 2. Interview (one short round)

Ask, ideally with a multiple-choice question tool if you have one:

1. What should the agents do first? (coding help, inbox, reports, research, something else)
2. Where should they run? Explain the options in two lines each from `docs/01-where-to-run.md` and recommend: laptop to try it; a VPS for always-on business agents.
3. Which agent CLIs and model subscriptions do they already pay for? (Claude Pro/Max, ChatGPT, API keys)
4. Do they have an AgentX account yet?
5. Do they use Slack and want to talk to agents there? (optional, later)

Write the answers to `local/progress.md`. No secrets.

## 3. Route

| Phase | Do |
|---|---|
| Concepts | Explain `docs/00-overview.md` in 5 bullets, in their language. |
| Account | They sign up at https://www.agentxhq.com themselves. |
| Install | Laptop or Mac mini: `agentx-install`. VPS: `agentx-vps` (it ends with the install). |
| CLI login + first agent | `agentx-agent` |
| API token | `agentx-api` (only if they'll script or use Slack) |
| Lock-down | `agentx-lockdown` before an agent gets email, CRM, money or customer access |
| Slack | `agentx-slack` (optional) |
| Problems | `agentx-troubleshoot` |

After each phase: tick it in `local/progress.md`, say in one line what's next, and ask if they want to continue now.

## 4. Finish

Done when one agent has completed a real run, is scheduled (if it should be), and its charter has a metric and a review date 2 weeks out. Remind them of the review date.

## progress.md template

```markdown
# AgentX setup progress

## Choices
- Goal:
- Runs on:
- OS / arch:
- Agent CLIs:
- Agents planned:

## Phases
- [ ] Concepts explained
- [ ] AgentX account
- [ ] Daemon installed and claimed
- [ ] Agent CLI logged in
- [ ] First agent: charter, prompt, created, tested, dry run
- [ ] Automation scheduled
- [ ] API token (optional)
- [ ] Lock-down (before sensitive access)
- [ ] Slack (optional)
- [ ] 2-week review date:

## Notes
```
