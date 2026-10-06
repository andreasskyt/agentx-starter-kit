# 04. Logging the agent CLIs in

AgentX runs the CLI; the CLI needs its own login. How you log in depends on where the agent runs.

## On your own laptop or Mac mini (agents run as you)

Log in once, interactively, as yourself:

```bash
claude      # then /login, or follow the first-run prompt
codex       # follow its login flow
```

Every agent on that daemon uses that login.

## On a server with one Linux user per agent (recommended)

Each agent is a separate Linux user, so each needs its own credentials. For Claude Code, use a **long-lived token per agent** set as an environment variable in the agent's settings, not an interactive `/login`.

### Claude Code: `claude setup-token`

1. On your own computer, in your **own terminal** (not through an AI assistant), run:

   ```bash
   claude setup-token
   ```

   It opens a browser, you approve, and it prints a token starting with `sk-ant-`. It uses your Claude subscription.

2. In the AgentX console, open the agent, **Settings → Environment variables**, and add:

   | Name | Value |
   |---|---|
   | `CLAUDE_CODE_OAUTH_TOKEN` | the token |
   | `ANTHROPIC_MODEL` | `sonnet` (or `opus` for judgment-heavy work) |

3. Clear your clipboard afterwards. Never paste the token in a chat, a file in git, or a ticket.

Why a token instead of `/login`:

- One token per agent, so you can revoke one agent without touching the others.
- A `/login` session can also load your claude.ai connectors (Gmail, Drive and so on) into the agent, giving it far more access than its job needs. A setup-token session doesn't load them.
- An interactive login leaves a credentials file in the agent's home (`~/.claude/.credentials.json`). If you used `/login` once, delete that file afterwards so the token is the only credential.

Tip for long tokens: a narrow terminal can wrap the token across lines and you copy it broken. Widen the window before running `setup-token`.

Fallback if the token is rejected (401): log in interactively as that agent's user, then switch to a token later:

```bash
ssh -t agents-01 'su - agentx-<name> -c claude'
```

### Codex and others

Follow each CLI's own docs for non-interactive or API-key auth, and set the variable in the agent's environment settings in the console. Log in as the agent's Linux user if the CLI only supports interactive login.

## Model subscription vs API key

- **Subscription (Claude Pro/Max, ChatGPT Plus/Pro):** flat cost, subject to the plan's usage limits. Many agents share the same limit.
- **API key:** pay per token, no plan limit, easier to put a hard spending cap on per key.

Start on your subscription. Move a busy agent to its own API key when it starts eating your personal limits.

## Done when

- On a laptop: `claude -p "say hi"` answers.
- On a server: you know which variable each agent will get. You test it in [05-first-agent.md](05-first-agent.md).
