---
name: agentx-vps
description: Set up a hardened Linux VPS for AgentX agents: choosing and ordering the server (the person pays), SSH key, firewall, hardening, system-wide agent CLI, agentx-server install and claim, optional read-only prompts repo. Use for "set up a server for my agents", "/agentx-vps", "VPS for AgentX", "firewall for the agent server".
---

# Agent VPS

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`. Detail: `docs/03-vps.md`, hardening script `scripts/harden-vps.sh`.

## Rules for this skill

- **They order and pay.** Recommend a size and provider, state the monthly price from the provider's page, and let them click buy. Never order anything yourself.
- **Never on a production server.** If they suggest reusing the server that runs their website or database, push back once and recommend a separate VPS.
- **Ask before every change on the server.** Say the command and what it does. Read-only checks are fine.
- **SSH keys:** the private key never leaves their computer and never appears in chat.

## Steps

1. **Size and provider:** 4 vCPU / 8 GB for 5 to 10 agents, 2 vCPU / 4 GB for 2 or 3. Ubuntu LTS. Backups on. Provider firewall: inbound TCP 22 and ICMP only (the daemon only connects outwards).
2. **SSH key** on their computer: `ssh-keygen -t ed25519 -f ~/.ssh/agents-vps -C agents-vps`. They paste the `.pub` file into the order form.
3. **SSH config** entry `agents-01` (template in the doc). Test `ssh agents-01 'uname -a'`.
4. **Harden:** read `scripts/harden-vps.sh` with them, then `scp` it and run it. Use `--no-ufw` if the provider firewall already restricts to SSH. Before closing the session, they test a new SSH login and that password login is refused.
5. **Agent CLI system-wide:** Claude Code native installer as root, then `install -m 755 "$(readlink -f /root/.local/bin/claude)" /usr/local/bin/claude`. Check `claude --version`.
6. **Daemon:** `agentx-server` package from https://www.agentxhq.com/install (checksum first). `systemctl status agentx`. Claim via `sudo cat /run/agentx/claim-token` and the claim link. They open the link themselves.
7. **Optional prompts repo** (recommended from 2+ agents): private repo, read-only deploy key on the server, checkout at `/opt/agents`, and copy this kit's `scripts/` into it. Steps in the doc.
8. **Managed settings:** hand off to `agentx-lockdown` before the first agent gets real access.

Tick the phase in `local/progress.md` with the server's nickname only (no IP needed there).

## Firewall check (read-only)

```bash
ss -tulpn | grep LISTEN        # only sshd should listen on 0.0.0.0 / [::]
ufw status verbose             # if ufw is used
```

The AgentX daemon's local console listens on 127.0.0.1 only. Never open port 3333 to the internet; use an SSH tunnel if needed: `ssh -L 3333:127.0.0.1:3333 agents-01`.
