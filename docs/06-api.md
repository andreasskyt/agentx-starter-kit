# 06. The AgentX API

Use the API to message agents from scripts, other tools, a Slack bridge or another agent. It goes through AgentX's cloud, so it reaches agents on any of your machines without opening ports.

- **Base URL:** `https://www.agentxhq.com/api/v1`
- **Auth:** `Authorization: Bearer <token>` with a personal API token.
- **Spec:** `GET https://www.agentxhq.com/api/v1/openapi.json` (public; check it, routes get added).

## 1. Create a token (you, in the console)

Create a personal API token in the console's settings. Give it a name that says what uses it (`agents-scripts`, `agents-slack-listener`). One token per consumer, so you can revoke one without breaking the rest.

Store it without it touching chat or shell history:

```bash
# macOS: copy the token in the browser, then
printf 'export AGENTX_API_KEY=%q\n' "$(pbpaste)" >> ~/.agentx-secrets.env && pbcopy < /dev/null
chmod 600 ~/.agentx-secrets.env
echo 'source ~/.agentx-secrets.env' >> ~/.zshrc
```

```bash
# Linux / any: hidden prompt
read -rsp "AgentX API key: " k; echo; printf 'export AGENTX_API_KEY=%q\n' "$k" >> ~/.agentx-secrets.env; unset k; chmod 600 ~/.agentx-secrets.env
```

Test: `curl -s -H "Authorization: Bearer $AGENTX_API_KEY" https://www.agentxhq.com/api/v1/agents | head -c 300`

## 2. Routes

| Method and path | What it does | Main fields |
|---|---|---|
| `GET /agents` | List agents | `include_all` (query) |
| `POST /agents` | Create an agent | `name`, `backend`, `daemon`, `run_as` / `create_run_as`, `model`, `system_prompt`, `work_dir`, `sandbox`, `approval`, `network`, `max_sessions`, `manager`, `idle_reap_*`, `boot_resume_policy` |
| `GET /bubbles` | List bubbles | `limit`, `cursor`, `query` |
| `POST /bubbles` | Create a bubble | `name`, `anchor_agent` |
| `POST /messages` | Send a message to an agent | `agent`, `bubble`, `message`, `start` |
| `POST /output` | Read an agent's output | `agent`, `bubble`, `tail`, `lines`, `format` |
| `POST /agents/{agent}/upload` | Upload a file to an agent | `bubble` (query), multipart file |
| `POST /daemons/claim` | Claim a daemon | `claim_code` |

Field details are in the OpenAPI spec. Verify before relying on one; this table was written against 0.144.x.

## 3. Helper script

`scripts/ax-api` wraps the common calls (needs `curl` and `python3`, reads `AGENTX_API_KEY`):

```bash
scripts/ax-api agents                          # list agents
scripts/ax-api bubbles                         # list bubbles
scripts/ax-api new-bubble ada-runs Ada         # create bubble "ada-runs" anchored to agent Ada
scripts/ax-api send Ada ada-runs "Run your job. DRY RUN."
scripts/ax-api output Ada ada-runs 80          # last 80 lines
```

`send` creates the bubble if it doesn't exist yet.

## 4. Raw curl

```bash
curl -s -X POST https://www.agentxhq.com/api/v1/messages \
  -H "Authorization: Bearer $AGENTX_API_KEY" -H "Content-Type: application/json" \
  -d '{"agent":"Ada","bubble":"ada-runs","message":"Run your job. DRY RUN.","start":true}'
```

## 5. Conventions that help

- **One bubble per purpose:** `<name>-runs` for manual and test runs, `<name>-daily` for the automation, `<name>-slack` for Slack requests. Sessions stay short and readable.
- **Messages are metered.** A message is one instruction or reply. A chatty integration that polls or pings agents costs messages; batch work into one instruction per run.
- **Treat the token like a password.** It can create agents and message every agent you own. If it was ever pasted in a chat, revoke it and make a new one.

## MCP

AgentX also exposes an MCP server, so Claude.ai or ChatGPT can list and message your agents from a chat. Find the connection details in the console.
