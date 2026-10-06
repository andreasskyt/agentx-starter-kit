# 03. A hardened VPS for your agents

Goal: an always-on Linux server that runs only agents, reachable only by your SSH key, with one Linux user per agent.

## 1. Order the server (you, in the provider's console)

- **Size:** 4 vCPU / 8 GB / 80 GB for 5 to 10 agents (2 vCPU / 4 GB for 2 or 3). See [01-where-to-run.md](01-where-to-run.md).
- **Image:** Ubuntu LTS (24.04 or newer) or Debian 12+.
- **SSH key:** create a dedicated key on your computer and add the public half when ordering:

  ```bash
  ssh-keygen -t ed25519 -f ~/.ssh/agents-vps -C "agents-vps"
  cat ~/.ssh/agents-vps.pub
  ```

- **Firewall (provider-level, if offered):** inbound TCP 22 (SSH) and ICMP only. The daemon connects **out** to AgentX; it needs no inbound ports.
- **Backups:** on.
- **Name:** something neutral like `agents-01`.

Then add a shortcut on your computer, in `~/.ssh/config`:

```
Host agents-01
  HostName <server IP>
  User root
  IdentityFile ~/.ssh/agents-vps
  IdentitiesOnly yes
```

Test: `ssh agents-01 'uname -a'`

## 2. Harden it

Copy and run the script (read it first; it's short):

```bash
scp scripts/harden-vps.sh agents-01:/root/
ssh -t agents-01 'bash /root/harden-vps.sh'
```

It does:

- full package upgrade, automatic security updates (`unattended-upgrades`);
- `fail2ban` for SSH;
- a 2 GB swap file if there is none (agents spike in memory);
- key-only SSH (passwords off, root by key only), **after checking a key is installed**, so you can't lock yourself out;
- `ufw` allowing only SSH, unless you pass `--no-ufw` because the provider firewall already does it.

Keep your current SSH session open and test a **new** `ssh agents-01` before closing it.

## 3. Install an agent CLI system-wide

Agents run as separate Linux users, so the CLI must be on everyone's `PATH`, not in root's home.

**Claude Code** (native installer as root, then copy the single binary):

```bash
curl -fsSL https://claude.ai/install.sh | bash
install -m 755 "$(readlink -f /root/.local/bin/claude)" /usr/local/bin/claude
claude --version
```

Repeat this to update; per-user auto-update doesn't apply to the copied binary.

**Codex** (needs Node.js 18+): `npm install -g @openai/codex`. Check the official instructions for the current package name before installing.

Login happens **per agent**, not here. See [04-agent-clis.md](04-agent-clis.md).

## 4. Install the daemon (server flavor)

Follow the Linux **Server** (`agentx-server`) steps on https://www.agentxhq.com/install: download the package, verify the checksum, install. Then:

```bash
systemctl status agentx --no-pager
sudo cat /run/agentx/claim-token
```

Claim it via `https://www.agentxhq.com/daemons/claim?code=<CODE>` (see [02-install.md](02-install.md)). Do this from your own browser; don't paste the code into shared chats.

## 5. Optional: a prompts repo the server pulls

If you'll run more than one or two agents, keep their prompts and charters in a **private** git repo (see [05-first-agent.md](05-first-agent.md)) and give the server a **read-only deploy key**, so code reaches the server only through git and agents can't change their own prompts:

```bash
# on the server, as root
ssh-keygen -t ed25519 -f /root/.ssh/agents-repo -N "" -C "agents-01 read-only"
cat /root/.ssh/agents-repo.pub     # add as a read-only Deploy key in the repo settings
ssh-keyscan github.com >> /root/.ssh/known_hosts   # then compare against GitHub's published fingerprints
GIT_SSH_COMMAND="ssh -i /root/.ssh/agents-repo" git clone git@github.com:<you>/<agents-repo>.git /opt/agents
```

The scripts in this kit assume that checkout lives at `/opt/agents` (change `AGENTS_REPO` if not).

## 6. Rules for this server

- Agents only. No production apps, databases or customer systems.
- No production credentials. Each agent gets only the narrow tokens its job needs ([08-security.md](08-security.md)).
- Secrets arrive by `scp` or hidden prompts, never through git or chat.
- Root is for you. Every agent runs as its own user ("Run as: Create new user" in the console).

## Done when

- `ssh agents-01` works by key, password login is refused.
- `claude --version` works for any user.
- The daemon is claimed and online in the console.
