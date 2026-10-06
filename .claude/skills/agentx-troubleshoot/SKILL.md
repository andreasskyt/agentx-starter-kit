---
name: agentx-troubleshoot
description: Diagnose AgentX problems: daemon offline, missing claim file, agent never answers, Claude 401 or first-run prompts, automations not running, message pool empty, Slack listener issues. Use for "AgentX isn't working", "/agentx-troubleshoot", "my agent doesn't answer", "daemon offline".
---

# Troubleshoot

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`. Table of known problems: `docs/10-troubleshooting.md`.

1. **Get the symptom exactly:** what they did, what they expected, what happened, and the exact error text. Ask them to redact tokens before pasting logs.
2. **Match it** against the table in `docs/10-troubleshooting.md`.
3. **Check read-only first:** daemon status, logs, the agent's bubble in the console, `claude doctor` as the agent user (`sudo -iu agentx-<name>`), `~/outputs/`.
4. **Change one thing at a time**, with their yes for anything that writes, restarts or deletes. Re-test after each.
5. **Not in the table?** Say so plainly, collect the version (`agentx-daemon version`), OS and the exact error, and point them to AgentX's Discord (linked in https://www.agentxhq.com/install.md). Offer to add the fix to `docs/10-troubleshooting.md` once solved.
