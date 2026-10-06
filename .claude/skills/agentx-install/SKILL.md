---
name: agentx-install
description: Install the AgentX daemon on the person's own Mac, Linux machine or Windows (Docker) and claim it to their account. Use for "install AgentX", "/agentx-install", "claim my daemon", "update AgentX".
---

# Install and claim the daemon

Guides live in the agentx-starter-kit repo: `docs/` at the repo root (the current folder if it has `AGENTS.md`, otherwise the path in `~/.config/agentx-starter-kit-path`). Follow the hard rules in `AGENTS.md`. Detail: `docs/02-install.md`.

**The official instructions win:** fetch https://www.agentxhq.com/install.md and follow it. Versions and checksums change; never reuse a checksum from memory or from this repo.

## Steps

1. **Where do your commands run?** If you can't run commands on the person's own machine (you're in a browser chat or a cloud sandbox), don't install anything. Walk them through it one command at a time instead.
2. **Detect the machine:** `uname -a`, `sw_vers` (Mac) or `cat /etc/os-release`, and `uname -m`. Say which method and flavor you'll use and why. Linux: desktop flavor for a workstation, server flavor for a VPS. Never both.
3. **Check an agent CLI** is installed and logged in for the user the agents will run as (`claude --version`, `codex --version`). If none, help install one only after they agree; they log in themselves.
4. **Install:**
   - Mac with Homebrew: `brew install agentxhq/tap/agentx`, `agentx-daemon background`, `agentx-daemon status`.
   - Mac without Homebrew, or Linux: download the package from the install page, **verify the checksum** (must print OK), install. Ask before `sudo`.
   - Windows: https://www.agentxhq.com/install/docker
5. **Claim:** read the claim file (`~/.agentx/run/claim-token` on Mac/Linux desktop, `sudo cat /run/agentx/claim-token` on a server). Give them `https://www.agentxhq.com/daemons/claim?code=<CODE>` on its own line, and tell them to open it, sign in and confirm. Read the file again right before you answer; codes rotate.
6. **Verify:** they see the daemon online in the console. Tick the phase in `local/progress.md`.

If the claim file never appears, show the exact error from the logs (paths in `docs/02-install.md`). Don't guess.

## Update

Mac: `brew upgrade agentxhq/tap/agentx && agentx-daemon restart`. Linux: newer package, checksum, install. `agentx-daemon version` shows the current version.
