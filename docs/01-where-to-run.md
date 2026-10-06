# 01. Where should the daemon run?

Pick one to start. You can add more machines later; they all show up in the same console.

| Option | Good for | Watch out for |
|---|---|---|
| **Your own laptop** | Trying AgentX today, coding agents that work in your local repos. | Agents stop when the lid closes. The agents can reach everything on the machine, including your personal files, browser sessions and secrets. |
| **A dedicated Mac mini (or old desktop)** | Always-on agents at home or in the office, Mac-only tools, video work (ffmpeg likes RAM). One per employee is a common pattern. | Hardware cost, home network, power cuts. Still give each agent its own user if it touches anything sensitive. |
| **A VPS (Linux server)** | Always-on business agents (inbox, CRM, reports) that should be isolated from your laptop. Cheapest always-on option. | You manage a server: updates, firewall, SSH keys. [03-vps.md](03-vps.md) covers it. |
| **Windows** | Runs via Docker Desktop (WSL 2). | Follow https://www.agentxhq.com/install/docker. Less tested. |
| **Hosted Runtime (AgentX runs it)** | Teams that don't want to operate machines. | Sold by AgentX on enquiry; see their pricing page. |

## A simple rule

- **Coding agents for you** → your laptop or Mac mini, next to your repos.
- **Business agents that touch email, CRM, calendars or customers** → a VPS with one Linux user per agent, never your laptop. If one is tricked by a malicious email, it should find nothing else to steal.
- **Never** run agents on the server that hosts your production website, database or customer systems.

## VPS sizing

- 4 vCPU / 8 GB RAM / 80 GB disk runs 5 to 10 mostly idle agents comfortably. 2 vCPU / 4 GB is enough for 2 or 3.
- Ubuntu LTS or Debian. ARM or x86 both have packages; check the install page for your architecture.
- Turn on the provider's backups (usually about 20% of the server price).
- Hetzner, DigitalOcean, Vultr, OVH, Scaleway and AWS Lightsail all work. Pick a region close to you.

## Laptop + VPS together

A common setup: daemon on the laptop for coding, daemon on a VPS for business agents. Both appear in the console; when you create an agent you pick which daemon it runs on.
