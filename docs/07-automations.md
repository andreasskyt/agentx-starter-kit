# 07. Automations: scheduled runs

An automation sends a fixed message to an agent on a schedule. As of 0.144.x the options are **daily at a set time** or **weekly at a set time**.

## Set one up (console → agent → Automations)

| Field | Value |
|---|---|
| Frequency | Daily (or Weekly) |
| Time | When the output is useful: before you start work for a briefing, before lunch and end of day for an inbox |
| Bubble | `<name>-daily` (a dedicated bubble keeps scheduled runs apart from manual ones) |
| Input | One line that points at the prompt, e.g. `Run your job as described under "Each run" in your instructions.` |

Keep the instruction in the prompt, not in the automation text. Then changing the job is one prompt edit, not a hunt through schedules.

## Patterns

**"React to new things" without webhooks.** There are no event triggers yet. Schedule the agent several times a day (add one automation per time slot) and have it process everything since its last run:

- The agent keeps a checkpoint (last processed ID or timestamp) in a file in its home, e.g. `~/state/checkpoint.json`.
- Each run: read checkpoint, fetch newer items, process, write the new checkpoint last (so a crash means a retry, not a gap).

**Daily digest.** One run, one message, at most 5 items, ranked by what matters most to you. More than 5 and you'll stop reading it.

**Weekly review.** A weekly run that reads the agent's own `~/outputs/` logs and reports its metric. This is how you notice an agent quietly getting worse.

## Checklist before turning one on

- [ ] A manual dry run and one live run looked right.
- [ ] The agent survives an empty run (nothing new) without noise; ideally it posts nothing or one line.
- [ ] Message volume fits your plan: runs per day x messages per run x 30.
- [ ] You know where you'll see failures (its channel, its log).

## Machine sleep

On a laptop, a scheduled run only happens if the machine is awake. That's the main reason to move scheduled agents to a VPS or an always-on Mac mini.
