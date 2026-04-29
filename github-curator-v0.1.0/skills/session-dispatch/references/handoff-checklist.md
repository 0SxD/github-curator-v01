# handoff-checklist.md

The 12-item pre-emit checklist run before the session-dispatch
skill emits a bootstrap. Loaded on demand by
`skills/session-dispatch/SKILL.md` only at the EMIT step.

The checklist is mechanical. Each item returns TRUE or FALSE. Any
FALSE blocks the EMIT until repaired.

## The 12 items

| # | Check | Repair if FALSE |
|---|---|---|
| 1 | Slug is set, lowercase-hyphenated, ≤32 chars. | Ask the human for a valid slug. |
| 2 | Target host is named (Claude Code, NotebookLM, etc). | Ask the human which host. |
| 3 | Workstream scope is one paragraph, ≤500 chars. | Re-draft the scope paragraph. |
| 4 | Canon-attach list is enumerated (every file path). | Re-walk canon, enumerate. |
| 5 | Out-of-scope list is enumerated (anti-goals stated). | Ask the human or extract from prior session. |
| 6 | "Decisions made" section in HANDOFF.md is populated. | Pull from prior session log; if empty, note "no prior decisions". |
| 7 | "Open and pending" list is populated. | Pull from prior session's open questions. |
| 8 | "What this session should accomplish" is concrete. | Re-draft as numbered deliverables with done conditions. |
| 9 | If a packet zip is requested, the attach list contents pass tier-1 IP scrub. | Quarantine the offending file. |
| 10 | Slim AGENTS.md is under 8000 chars (for tokenized hosts). | Trim to overview, scope, canon list, stop conditions only. |
| 11 | Stop conditions are stated (when to STOP and ask the human). | Add: tier-1 IP hit, ambiguous canon, missing input. |
| 12 | Provenance line at the bottom of AGENTS.md cites the parent session. | Add: "Dispatched <ISO> from session <id> via session-dispatch v0.1.0." |

## Item 1: slug

```
echo "$SLUG" | grep -qE '^[a-z0-9][a-z0-9-]*$'
test ${#SLUG} -le 32
```

The slug is used in directory names, filenames, and the bootstrap
metadata. Same regex as the Agent Skills `name` field, narrower
length limit because slugs are often appended to other strings.

## Item 2: target host

The host is one of the names in
`references/host-quirks.md`. If the human names a host not in
that file, ask whether to add it (which makes the host-quirks file
grow per the evolution rule of its containing skill).

## Item 3: scope paragraph

The scope paragraph is the workstream's purpose in one paragraph.
The 500 char limit forces clarity. If the agent cannot fit the
scope in 500 chars, the workstream is too broad and should be
split into two.

## Item 4: canon-attach list

Every file the new session will read must be listed. Two
categories:

- INCLUDE_AS_REFERENCE: the new session loads from URL or local
  path (the host has filesystem or repo access).
- INCLUDE_IN_PACKET: the new session loads from the zip (the host
  has no filesystem access).

The list lives in HANDOFF.md under "Canon files attached" and
"Canon files referenced (not attached)".

## Item 5: out-of-scope list

The anti-goals. Files, topics, decisions the new session must NOT
touch. Examples:

- "Do not modify the FATEx archive metadata."
- "Do not edit the upstream protocol canon."
- "Do not propose changes to the four-skill structure."

Anti-goals prevent context drift. The human enumerates them at
dispatch time so the new session does not waste a turn confirming.

## Item 6: decisions made

Pull from the prior session's log:
- Confirmed answers to questions.
- Choices among options.
- Resolved disagreements.

Each decision is one sentence with a citation to the canon entry
or the chat turn where it was made.

## Item 7: open and pending

The unresolved questions. Each is a load-bearing question awaiting
an answer (per the Socratic Method). Format:

```
- OQ-XX: <one-sentence question>
```

The new session resolves these; resolution is logged in the new
session's own decisions list.

## Item 8: deliverables

What the new session should produce. Format:

```
1. <deliverable name>: <one-sentence description>. Done condition: <measurable>.
2. ...
```

The done condition is mechanical where possible (a file exists, a
test passes, a verifier returns 0) or human-graded where
necessary (a draft acceptable to the human).

## Item 9: packet IP scrub

If the bootstrap includes a zip, every file in the zip is run
through the tier-1 IP scrub from
`skills/publish-readiness-rubric/references/ip-scrub-tiers.md`.
Any tier-1 hit blocks the EMIT.

The scrub is not optional. Forks may not skip this item even if
the human says "skip the scrub for this one". The Zero Assumption
Mandate forbids it.

## Item 10: slim AGENTS.md

For tokenized hosts (NotebookLM, Custom Gem, Custom GPT), the
full AGENTS.md is too long. The slim version contains only:

1. Project overview (one paragraph).
2. Workstream scope (one paragraph).
3. Canon list (file names, no inline content).
4. Stop conditions (numbered list).
5. Provenance (one line).

Maximum 8000 chars (the conservative budget across the three
tokenized hosts). The full AGENTS.md remains the canonical version
for filesystem hosts.

## Item 11: stop conditions

The conditions under which the new session must STOP and ask the
human. Default set:

1. Any tier-1 IP scrub hit in any file the session encounters.
2. Any ambiguous canon (two files contradicting each other without
   an arbitration entry).
3. Any input that is missing, malformed, or absent from the
   attach list.
4. Any deliverable that would require modifying out-of-scope files.

The human may add workstream-specific stop conditions. The default
set is always included.

## Item 12: provenance line

The provenance line cites the parent session and the dispatcher
version:

```
Dispatched 2026-04-26T16:55:00Z from session <prior-session-id>
via session-dispatch v0.1.0.
```

The `<prior-session-id>` is whatever identifier the human or the
host uses for the source session. In Claude.ai it might be a
chat URL fragment; in Claude Code it might be a session UUID; in
NotebookLM it might be the notebook ID. The dispatcher does not
fabricate; it asks the human if the value is unknown.

## Output of the checklist

When all 12 items return TRUE:

```
HANDOFF_CHECKLIST PASS (12/12)
- ready to EMIT
- bootstrap files: dispatch/<timestamp>-<slug>/AGENTS.md, HANDOFF.md
- packet (if any): dispatch/<timestamp>-<slug>/<slug>-packet.zip
```

When any item returns FALSE:

```
HANDOFF_CHECKLIST FAIL (N/12 items pending)
- item N: <one-line description of what is missing>
- repair: <one-line repair instruction>
```

The agent does not EMIT until the checklist passes.

END_HANDOFF_CHECKLIST
