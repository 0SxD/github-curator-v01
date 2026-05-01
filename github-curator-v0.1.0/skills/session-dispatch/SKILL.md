---
name: session-dispatch
description: "Use this skill when spawning a new chat session for a focused workstream that exceeds the current session's context budget, especially when the new session must run in any agent (Claude Code, Codex, Cursor, Aider, Gemini CLI) or any host (Claude.ai project, NotebookLM, custom Gem, custom GPT). Triggers: any request to write a handoff prompt, dispatch a workstream, spawn a sub-agent session, prepare a paste-ready bootstrap for a new chat, or generate a HANDOFF document at 75% context. The skill emits a single AGENTS.md-shaped bootstrap file plus an optional packet zip that the human pastes or drops into the new session. The handoff is host-neutral: the same file works in every supported environment because it conforms to the AGENTS.md standard. Do NOT use this skill for in-session task delegation (use the agent's own subagent feature), for resuming an existing session, or for arbitrary chat templates unrelated to workstream dispatch."
license: Apache-2.0
compatibility: "Claude Code, Codex, Cursor, Aider, Gemini CLI, Antigravity, Claude.ai projects, NotebookLM (via packet zip), custom Gems, custom GPTs"
---

# session-dispatch

The handoff skill. Produces a single paste-ready bootstrap file that a
human (or another agent) can drop into a fresh chat session in any
supported host. The bootstrap is the AGENTS.md standard plus a
workstream-specific scope; the same file works in Claude Code, Codex,
Cursor, Aider, Gemini CLI, NotebookLM, a Claude.ai project, a custom
Gem, or a custom GPT.

## Why this skill exists

Sessions hit context limits. Workstreams sprawl. The system_directive_protocol
zero-context-persistence rule (Section 2) forbids carrying assumptions
across sessions. The combination produces a recurring need: at the
edge of a session, the agent must hand off to a fresh session with
enough context to resume cleanly and zero context to drift into.

The naive handoff is a wall of conversational summary that the next
session cannot mechanically parse. The structured handoff is an
AGENTS.md-shaped file plus optional packet, which the next session
loads as governance. This skill emits the structured form.

## When to use

Load this skill when:

1. The current session is near the context budget (75% rule from
   the broader governance set).
2. The user asks for a "handoff" or "dispatch" or "next session
   bootstrap".
3. A workstream is being spawned that should run in a different
   host (e.g., the long ingest belongs in NotebookLM, the coding
   work belongs in Claude Code, the visual diagram work belongs
   in Antigravity).
4. The user wants a paste-ready prompt to give a coding agent
   that has access to the working directory.

Do not load this skill for in-session subagent delegation (use the
host's own subagent mechanism), for resuming a session that is
already mid-workstream, or for non-workstream chat templates.

## The output

The skill emits one or two files:

1. Always: `dispatch/<timestamp>-<slug>/AGENTS.md` plus
   `dispatch/<timestamp>-<slug>/HANDOFF.md`.
2. Optional: `dispatch/<timestamp>-<slug>/<slug>-packet.zip` if the
   workstream needs a portable bundle (e.g., for NotebookLM).

`AGENTS.md` is the agent governance for the new session. It conforms
to https://agents.md and uses this repo's root AGENTS.md as the
template.

`HANDOFF.md` is the human-readable summary of:
- What was decided in the previous session.
- What is open and pending.
- What the new session should accomplish.
- What canon files the new session must read first.

The packet zip (optional) carries the canon files plus this skill's
AGENTS.md, so a host that does not have repo access (NotebookLM,
custom Gem) can still bootstrap.

## The dispatch loop

```
SCOPE -> ENUMERATE -> PACKAGE -> EMIT
```

### SCOPE (active sensing)

1. Confirm the workstream slug. The slug is lowercase-hyphenated,
   ≤32 chars, descriptive (e.g., `fatex-archive-publish`,
   `143-protocol-diagrams`, `prompt-pack-ingest`).
2. Confirm the target host. Common hosts:
   - Claude Code (CLI in repo working directory)
   - Codex (similar)
   - Cursor (IDE plus rules)
   - Aider (CLI)
   - Gemini CLI
   - Antigravity
   - Claude.ai project (web)
   - NotebookLM (web, source-bundle ingestion)
   - Custom Gem (web)
   - Custom GPT (web)
3. Confirm the canon files the new session needs. These come from
   the current repo (read-only references) or from the packet zip
   (if the host has no repo access).

### ENUMERATE (reasoning)

Walk the canon set. For each file, decide:
- INCLUDE_AS_REFERENCE: the new session loads from URL or local
  path.
- INCLUDE_IN_PACKET: the new session loads from the zip.
- EXCLUDE: not relevant to this workstream.

Excluded files are not just unmentioned; they are explicitly listed
in HANDOFF.md as "out of scope for this workstream" so the next
session does not waste a turn confirming.

### PACKAGE (artifact generation)

1. Write `dispatch/<timestamp>-<slug>/AGENTS.md`. Template below.
2. Write `dispatch/<timestamp>-<slug>/HANDOFF.md`. Template below.
3. If packet needed:
   - Copy each INCLUDE_IN_PACKET file into
     `dispatch/<timestamp>-<slug>/packet/`.
   - Run `zip -r <slug>-packet.zip packet/`.
   - Compute sha256, write `<slug>-packet.zip.sha256`.

### EMIT (termination)

Produce a single chat output containing:
- The `AGENTS.md` path for the new session.
- The `HANDOFF.md` path.
- The packet zip path (if produced).
- A 3-line "what to do next" instruction for the human.

The human pastes `AGENTS.md` (or `HANDOFF.md`, depending on host) as
the first message of the new chat session, attaches the zip if
needed, and begins.

## AGENTS.md template for new session

```
# AGENTS.md (workstream: <slug>)

Conforms to the AGENTS.md standard at https://agents.md.

## Workstream

<one paragraph: what this session does>

## Canon to read first (in this order)

1. <file 1>
2. <file 2>
3. <file 3>

## Out of scope

- <thing 1>
- <thing 2>

## Build, test, release

<commands specific to the workstream>

## Code style

- No em dashes (U+2014), no en dashes (U+2013).
- <other rules specific to workstream>

## Stop conditions

- <condition 1: when to STOP and ask the human>
- <condition 2>

## Provenance

Dispatched <ISO timestamp> from session <prior-session-id> via
github-curator/session-dispatch v0.1.0.
```

## HANDOFF.md template

```
# HANDOFF: <slug>

Created: <ISO timestamp>
From session: <prior-session-id>
To host: <host name>

## Decisions made in prior session

- <decision 1, with citation to canon if applicable>
- <decision 2>

## Open and pending

- <open question 1>
- <open question 2>

## What this session should accomplish

<numbered list of concrete deliverables, each with a measurable
done condition>

## Canon files attached

- <file 1 with path>
- <file 2 with path>

## Canon files referenced (not attached)

- <file 1 with URL or repo path>
- <file 2>

## What NOT to do

- <explicit anti-goals to prevent context drift>
```

## Stop conditions for this skill

The Zero Assumption Mandate applies. If any of the following is true,
this skill stops and asks:

1. The slug is missing or non-conformant.
2. The target host is unspecified.
3. The canon set has unresolved conflicts (two files claim different
   facts about the same thing without an arbitration entry).
4. A packet is requested but the source files contain tier-1 IP
   scrub hits.

## Reference docs

Loaded on demand, not at activation:

- `references/host-quirks.md` the per-host idiosyncrasies (NotebookLM
  source-bundle format, custom Gem token limits, custom GPT
  attachment rules, Claude Code working-directory expectations).
- `references/handoff-checklist.md` the 12-item pre-emit checklist.
- `references/canonical-workstream-examples.md` worked examples for
  the most common workstreams (FATEx archive publish, system_directive_protocol
  diagrams, prompt pack ingest, MNS demo bootstrap).

## Provenance

This SKILL.md was authored 2026-04-26 by 0SxD. The
session-dispatch pattern composes the AGENTS.md standard
(https://agents.md), the system_directive_protocol zero-context-persistence rule
(Section 2), the 75% context rule from the broader governance set,
and the host-neutrality principle from the Agent Skills
specification (https://agentskills.io/specification).

END_SESSION_DISPATCH_SKILL
