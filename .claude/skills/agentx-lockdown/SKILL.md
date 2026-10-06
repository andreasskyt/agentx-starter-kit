---
name: agentx-lockdown
description: Secure AgentX agents before they touch anything sensitive: one Linux user per agent, secrets layout, wrapper tools for over-wide API scopes, Claude Code managed settings, read-only prompts, removing stray logins. Use for "secure my agents", "/agentx-lockdown", "lock down the agent server", "give my agent access to Gmail/CRM safely".
---

# Lock-down

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`. Detail: `docs/08-security.md`. Files: `templates/managed-settings.json`, `scripts/setup-tool.sh`.

Explain the principle first in one line: a rule in a prompt is a request, a rule in the operating system is enforcement. Assume an agent will one day be tricked by what it reads.

## Audit (read-only, with their OK to SSH in)

```bash
getent passwd | grep agentx-                       # one user per agent?
ls -ld /home/agentx-* /etc/agents/*                # 700/750, owned by the right user?
ls /home/agentx-*/.claude/.credentials.json 2>/dev/null   # stray /login sessions
cat /etc/claude-code/managed-settings.json 2>/dev/null
ls /etc/sudoers.d/
ss -tulpn | grep LISTEN
```

Report findings as a short list: OK / fix.

## Fixes (each needs their yes)

1. **Agents sharing a user** → recreate them with "Run as: Create new user".
2. **Stray `.credentials.json`** → delete it once the agent has a `CLAUDE_CODE_OAUTH_TOKEN`; verify the agent still answers.
3. **Managed settings** → install the template, add each agent's own tool commands to `allow`, verify as an agent user (`/status`, `claude doctor`, a denied `curl`). Never deny `sudo` (it would block the wrappers) and never set `disableBypassPermissionsMode` (agents won't start under AgentX).
4. **A token whose scope is wider than the job** (send, delete, admin) → wrapper tool behind a service user with `scripts/setup-tool.sh`. Write the wrapper with only the allowed commands, test it against a mock API first, then test that the agent can't read the token file.
5. **Prompts writable by the agent** → read-only checkout plus symlink (`provision-agent.sh`).
6. **Secrets in git or chat history** → rotate them.

Re-test after every AgentX update: in 0.144.4, AgentX started Claude agents in bypass-permissions mode and the console Access settings didn't change that.
