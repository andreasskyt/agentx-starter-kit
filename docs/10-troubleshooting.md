# 10. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| No claim file | Daemon not running or can't reach AgentX | `systemctl status agentx` / `agentx-daemon status`; read the logs ([02](02-install.md)); check outbound HTTPS works (`curl -I https://www.agentxhq.com`) |
| Claim link says expired | Codes rotate | Read the claim file again and use the new code right away |
| Daemon offline in console | Machine asleep, daemon stopped, network | Wake it / `agentx-daemon restart` / `systemctl restart agentx` |
| New agent never answers | Claude Code is waiting on a first-run screen (theme, login, bypass warning) nobody sees | Run `provision-agent.sh` (it pre-answers them), or log in once as the user: `su - agentx-<name> -c claude` and click through |
| Agent stops at "Allow external CLAUDE.md file imports?" | Prompt imports a file outside its project | `provision-agent.sh` pre-approves it; or answer once interactively |
| `401` / "invalid token" from Claude | Bad or truncated `CLAUDE_CODE_OAUTH_TOKEN` | New `claude setup-token` in a wide terminal; paste as one line; restart the agent |
| Agent has your Gmail/Drive tools | It was logged in with `/login`, which loads claude.ai connectors | Use a setup-token, delete `~/.claude/.credentials.json`, set managed settings ([08](08-security.md)) |
| Access settings seem ignored | Claude agents start in bypass mode (observed in 0.144.4) | Enforce with Linux users and managed settings |
| `claude: command not found` for agents | CLI installed in root's home only | Install to `/usr/local/bin` ([03](03-vps.md)) |
| Automation didn't run | Laptop asleep, wrong timezone, message pool empty | Move to an always-on machine; check the time; check usage in the console |
| Messages pause | Monthly message pool used up | Running work finishes; new sends wait for the next window or an upgrade |
| Slack: no acknowledgement | Listener down, wrong `xapp-` token, Socket Mode off | `journalctl -u agents-slack-listener`; regenerate the app-level token |
| Slack: ack but no answer | AgentX token wrong or agent failing | Listener log shows the AgentX error; open the `<persona>-slack` bubble in the console |
| Agent is slow or the server swaps | Too many agents for the RAM (~300 MB each while running) | Lower max sessions, add swap, size up |

## Where to look

- Agent transcript: console → agent → bubble.
- Daemon logs: see [02-install.md](02-install.md).
- Agent's own logs: `~/outputs/` in its home.
- As the agent: `sudo -iu agentx-<name>` then `claude doctor`.

## Getting help

AgentX support is on Discord (link in https://www.agentxhq.com/install.md). For this kit, open a GitHub issue. Never paste tokens, claim codes or full logs with secrets.
