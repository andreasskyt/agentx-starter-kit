---
name: agentx-agent
description: Design, create, test and schedule one AgentX agent: job, charter (metric and stop rule), persona name, prompt (CLAUDE.md), console settings, Claude login token, server wiring, dry run, daily automation. Use for "create an agent", "new agent", "/agentx-agent", "make an agent that does X", "schedule my agent".
---

# One agent, end to end

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`. Detail: `docs/04-agent-clis.md`, `docs/05-first-agent.md`, `docs/07-automations.md`. Templates: `templates/agent/`.

## 1. Charter first

Ask (one round): the job; the one metric; the stop rule; what it must never do; schedule; which data and tools it needs; the persona name. If they can't name a metric, help them find one or suggest a different first agent. Push back on first agents that send, pay, delete or publish.

Pick a lowercase **role key** that never changes. Fill `templates/agent/charter.md` into their prompts folder (`agents/<role>/` in their repo, or a local folder on a laptop).

## 2. Prompt

Fill `templates/agent/CLAUDE.md`: job, numbered "Each run" steps, exact allowed commands, DRY RUN mode, rules, output format. Add `templates/agent/CHANGELOG.md` and `agent.json`. If they use Slack, include `templates/agent/slack-requests.md` (import it or paste it in).

## 3. Login for the agent

- Laptop: their existing CLI login is enough.
- Server: one `claude setup-token` per agent, run **by them in their own terminal**, pasted into the agent's environment variables in the console as `CLAUDE_CODE_OAUTH_TOKEN`, plus `ANTHROPIC_MODEL`. Never in chat.

## 4. Create in the console (they click)

Give them the field table from `docs/05-first-agent.md`, filled in: name = persona, backend, daemon, Run as (server: **Create new user**), manage own agents **off**, max sessions 2, env vars. Save without starting a session on a server.

## 5. Wire up (server only)

Prompt pushed to their repo and pulled on the server, then they run (it asks for Slack tokens hidden, Enter skips):

```bash
ssh -t agents-01 'bash /opt/agents/scripts/provision-agent.sh <role> <Persona> [extra-group ...]'
```

Verify read-only: `id agentx-<persona>`, `ls -l /home/agentx-<persona>/CLAUDE.md`.

## 6. Test

1. "Who are you and what is your job?" in a console bubble.
2. Each tool once, harmlessly.
3. `Run your job. DRY RUN.` (console, or `scripts/ax-api send <Persona> <persona>-runs "..."`). Review the result with them.
4. Fix the prompt, add a CHANGELOG line, repeat. First live run only on their explicit yes.

## 7. Schedule

Console → agent → Automations: daily/weekly, time, bubble `<persona>-daily`, one-line input pointing at "Each run". Check message volume against their plan. For "react to new things", several daily slots plus a checkpoint file.

## 8. Close

Tick `local/progress.md`; set the 2-week review date for the metric.
