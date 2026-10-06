# 02. Install the daemon and claim it

The official, always-current instructions are at **https://www.agentxhq.com/install.md** (written for AI assistants) and https://www.agentxhq.com/install (for humans, with package links and checksums). This page is a summary plus the things that tripped people up. If they disagree, follow the official page.

## 0. Before you start

- An AgentX account: sign up at https://www.agentxhq.com (free tier, no card).
- At least one supported agent CLI installed **and logged in** on the machine, for the user the agents will run as. See [04-agent-clis.md](04-agent-clis.md).

## 1. macOS

With Homebrew:

```bash
brew install agentxhq/tap/agentx
agentx-daemon background
agentx-daemon status
```

Start at login instead: `brew services start agentx`. Local console: http://127.0.0.1:3333/console

Without Homebrew: don't install Homebrew just for this. Use the "Without Homebrew" package on the install page (`uname -m` says `arm64` or `x86_64`), verify the checksum with `shasum -a 256 -c` (must print `OK`), unpack and run `./install.sh --launchd`. It installs into `~/.local/bin` without sudo.

Builds are not yet signed or notarized. If you downloaded in a browser, run `xattr -dr com.apple.quarantine .` in the unpacked folder first.

## 2. Linux

Use the **Manual install** section of the install page. Pick exactly one flavor; they conflict:

| Flavor | Package | Runs as | Use for |
|---|---|---|---|
| Desktop | `agentx-desktop` | Your login user (user unit `agentx-daemon.service`, with linger) | Your own workstation |
| Server | `agentx-server` | root (system unit `agentx.service`), can run each agent as its own Linux user | A VPS or always-on box |

Download the package for your distro (Debian/Ubuntu `.deb`, Arch `.pkg.tar.zst`, RHEL/Rocky/Alma `.rpm`) and architecture, **verify with `sha256sum --check`**, then install with the command shown there. The package enables and starts the daemon.

## 3. Windows

Docker Desktop (WSL 2): https://www.agentxhq.com/install/docker

## 4. Claim the daemon

Until it's claimed, the daemon writes a claim code to a file:

| How it runs | Command |
|---|---|
| Linux server | `sudo cat /run/agentx/claim-token` |
| Linux desktop or macOS | `cat ~/.agentx/run/claim-token` |
| Docker | `docker exec agentx cat /run/agentx/claim-token` |

Open `https://www.agentxhq.com/daemons/claim?code=<CODE>`, sign in, confirm. The machine now shows up in your console.

- No file yet? Wait a few seconds; the daemon writes it once it reaches AgentX.
- Codes expire and are replaced. Read the file again right before you use it.
- The file disappears once claimed.
- Treat the claim code like a password until it's used: whoever claims it first gets your machine in their account. Don't paste it in shared chats.

Logs if it doesn't show up: `journalctl -u agentx` (Linux server), `journalctl --user -u agentx-daemon` (Linux desktop), `docker logs agentx`, or on Mac the `logfile:` path from `agentx-daemon status`.

## 5. Updating later

- Mac with Homebrew: `brew upgrade agentxhq/tap/agentx`, then `agentx-daemon restart` (or `brew services restart agentx`).
- Linux: download and install the newer package the same way (checksum first).
- Check the version shown on the install page against `agentx-daemon version` now and then.

## Done when

- The machine is listed under your daemons in the console.
- You know which user the agents will run as, and that user has a logged-in agent CLI.

Next: [05-first-agent.md](05-first-agent.md), or [03-vps.md](03-vps.md) if you're setting up a server.
