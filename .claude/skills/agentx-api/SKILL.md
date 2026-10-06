---
name: agentx-api
description: Set up and use the AgentX web API: create and store an API token safely, list agents and bubbles, send messages, read output, create bubbles, with scripts/ax-api or curl. Use for "AgentX API", "API key for AgentX", "/agentx-api", "message my agent from a script", "read my agent's output".
---

# AgentX API

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`. Detail: `docs/06-api.md`. Helper: `scripts/ax-api`.

## Token

1. They create a personal API token in the console settings, named for its consumer (`agents-scripts`, `agents-slack-listener`). One per consumer.
2. They store it themselves with one of the snippets in `docs/06-api.md` (clipboard pipe on Mac, hidden prompt elsewhere) into `~/.agentx-secrets.env` (mode 600), sourced from their shell profile. You never see it.
3. Test without printing it: `curl -s -o /dev/null -w '%{http_code}\n' -H "Authorization: Bearer $AGENTX_API_KEY" https://www.agentxhq.com/api/v1/agents` → 200.

If a token was ever pasted in chat: tell them to revoke it and make a new one.

## Use

```bash
scripts/ax-api agents
scripts/ax-api send <Agent> <bubble> "<message>"
scripts/ax-api output <Agent> <bubble> 80
```

Before relying on a field or route, check `https://www.agentxhq.com/api/v1/openapi.json`; routes get added. Remind them that every message counts against their monthly message pool.
