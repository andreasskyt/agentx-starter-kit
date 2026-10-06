# 08. Lock it down

An agent that reads email or web pages can be talked into things by what it reads (prompt injection). Assume one day it will be. Build so that a hijacked agent finds nothing worth stealing and can't do lasting damage.

**A rule in a prompt is a request. A rule in the operating system is enforcement.** Use both, rely on the second.

## Layer 1: one Linux user per agent (server)

"Run as: Create new user" in the console gives each agent its own user (`agentx-<name>`). An agent then sees only its own home, its own tokens and its own logs. Check:

```bash
sudo -u agentx-<name> ls /home/agentx-<other>     # must be "Permission denied"
```

On a laptop, agents run as you and can read everything you can. Don't give laptop agents business credentials.

## Layer 2: secrets on disk, readable by one user

```
/etc/agents/<role>/          mode 700, owned by agentx-<name>
/etc/agents/<role>/slack.env mode 600
```

- Secrets arrive by `scp` or a hidden prompt (`read -rsp`), never through git, chat or command-line arguments (those land in shell history and `ps`).
- One credential per agent per service, named `agents-<role>-<service>`, so revoking one breaks nothing else.
- Narrowest scope the service offers (read-only where possible).

## Layer 3: wrapper tools where a scope is too wide

Many APIs have no "draft but never send" or "read and add notes but never delete" scope. Then:

1. A service user owns the token (`<tool>-svc`); the agent can't read it.
2. A small script (`<tool>-tool`) exposes only the commands the agent may use (e.g. `list`, `read`, `draft`; no `send`, no `delete`).
3. One sudoers line lets agents in group `<tool>-tool-users` run that script, and nothing else, as the service user.

`scripts/setup-tool.sh` installs this pattern:

```bash
sudo bash /opt/agents/scripts/setup-tool.sh <tool> token.json /root/token.json agentx-<name>
# the agent then runs:  sudo -u <tool>-svc /usr/local/bin/<tool>-tool <command>
```

sudo resets the environment, so an agent can't redirect the tool with its own variables. Test the tool against a mock API before giving it a real token, and test that the agent **can't** read the token file.

## Layer 4: Claude Code managed settings

Claude Code reads `/etc/claude-code/managed-settings.json` (Linux) for every user, and users can't override it. Start from [templates/managed-settings.json](../templates/managed-settings.json):

- `disableClaudeAiConnectors` and `ENABLE_CLAUDEAI_MCP_SERVERS=false`: no claude.ai connectors (Gmail, Drive, ...) inside agents.
- `allowManagedMcpServersOnly` + `allowedMcpServers`: only the AgentX MCP server (`/usr/local/bin/agentx`) is allowed.
- `allowManagedPermissionRulesOnly`: agents can't add their own allow rules.
- `deny`: no `curl`/`wget`/`ssh`/`scp`, no WebFetch/WebSearch, no editing its own prompt or `~/.claude`.
- `allow`: only its own tools and writing to `~/outputs/`.

Install:

```bash
sudo install -d -m 755 /etc/claude-code
sudo install -m 644 templates/managed-settings.json /etc/claude-code/managed-settings.json
```

Add each agent's tools to `allow` (e.g. `"Bash(sudo -u crm-svc /usr/local/bin/crm-tool *)"`). Don't put `sudo` in `deny`: a deny always beats an allow, so it would block the wrappers. The sudoers file is the real `sudo` limit.

Verify as an agent user: `/status` shows the managed file, `claude doctor` reports no invalid rules, and a test session can't `curl` anything.

**Known gap (0.144.4):** AgentX starts Claude agents with `--dangerously-skip-permissions`, and the console's Sandbox / Approval / Network settings didn't change that in testing. In bypass mode the **deny rules still held** in testing, but allow-lists and `defaultMode` don't apply. Don't add `disableBypassPermissionsMode`; agents won't start. Bash deny rules match command text only (`bash -c "curl ..."` can get around a `curl` deny), which is why layers 1 to 3 are the real boundary. Re-test after each AgentX update.

## Layer 5: prompts the agent can't edit

Keep prompts in a git repo; the server has a root-owned, read-only checkout (`/opt/agents`); `~/CLAUDE.md` is a symlink into it; agents have no git key. A hijacked agent can't rewrite its own instructions, and every prompt change has a commit.

## Layer 6: outbound network (advanced)

The strongest limit is a firewall rule on outbound traffic per agent user (`iptables -m owner --uid-owner`) or Claude Code's sandbox. Test carefully; agents need to reach Anthropic, AgentX and their own APIs.

## Data hygiene

- Logs are logs, not copies: IDs, labels, reasons, counts. Never full emails, DMs or client documents in a log or in git.
- Delete the `~/.claude/.credentials.json` an interactive `/login` leaves behind once the agent uses a token.
- Rotate any key that was ever pasted in a chat.

## Checklist

- [ ] Every server agent has its own Linux user.
- [ ] No agent can read another agent's files or any token file but its own.
- [ ] Every third-party token is the narrowest scope, behind a wrapper if the scope is wider than the job.
- [ ] Managed settings installed and verified.
- [ ] Prompts are read-only to agents.
- [ ] Nothing that can send, pay, delete or publish without a human, unless you decided so for that agent.
