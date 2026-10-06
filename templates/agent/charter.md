# <Persona> (<Role>): charter

| | |
|---|---|
| **Outcome** | One sentence: what is true when this agent works. |
| **Never** | What it must not do, beyond the standard rules (no sending, paying, deleting, publishing). |
| **Output goes to** | Slack channel, email drafts, files, a sheet. |
| **Metric** | One number, and where it comes from. |
| **Stop rule** | When we change it or kill it (e.g. "below X after 2 weeks"). |
| **Why it's worth it** | The business number or the hours it moves. |

## Runtime

- **Machine / daemon:**
- **Linux user:** agentx-<persona>
- **Schedule (AgentX automations):**
- **Model:**

## Access

| Tool or token | Scope | Why it needs it | Enforced by |
|---|---|---|---|
| Slack app `agents-<role>` | `chat:write`, its own channel | Report to the owner | Bot invited to one channel |

## Inputs

What it reads, and from where.
