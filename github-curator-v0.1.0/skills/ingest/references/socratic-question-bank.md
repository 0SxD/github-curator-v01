# socratic-question-bank.md

The library of load-bearing question patterns used at the
INTERROGATE step. Loaded on demand by `skills/ingest/SKILL.md`.

## What "load-bearing" means

A load-bearing question is one that closes a specific gap which
would otherwise force the agent to make an assumption. Three
properties:

1. The answer changes downstream behavior. (Not informational.)
2. There is no inferable default the human would accept blindly.
3. The agent cannot proceed past the current step without the
   answer.

The Socratic interaction rule from system_directive_protocol caps questions at
3 per turn. Every question in this bank is load-bearing. Filler
questions are forbidden.

## Question patterns by ambiguity

### Missing or invalid `name`

When the packet has no `name` field, or the field fails the regex
`^[a-z0-9][a-z0-9-]*$`, or the field is longer than 64 chars, or
the field does not equal the parent directory name:

```
The folder is `<dir>`. The Agent Skills spec requires `name` to
equal the parent directory name, lowercase-hyphenated, max 64
chars. The current value is `<value or empty>`.

Confirm `name: <proposed>` (which would also rename the folder
if needed), or supply a different name?
```

### Short or generic `description`

When the description is shorter than the recommended threshold
(approximately 100 chars covering the "when to load" clause), or
the description covers only "what" without "when":

```
The current description is N chars. The spec accepts 1 to 1024
chars; the practical minimum for trigger detection is around 100.
The current text covers <what the skill does>. It does not
cover <when the agent should load it>.

Add a "Load this skill when ..." clause, or approve the current
text as-is?
```

### Missing `license`

When the license field is empty or unrecognized:

```
The license field is empty (or unrecognized). This repo's default
is Apache-2.0. The packet appears to be derived from upstream
sources licensed under <X>.

Migrate under Apache-2.0 (re-license, original notices preserved
per Apache 2.0 Section 4), keep upstream license as-is, or
exclude the packet?
```

### Missing or thin `compatibility`

When the compatibility field is empty or lists fewer than 3 hosts:

```
The compatibility field lists <N> host(s). The verification matrix
recommends 3 or more for portability. Common hosts: Claude Code,
Codex, Cursor, Aider, Gemini CLI, NotebookLM (via packet zip),
Claude.ai projects, custom Gems, custom GPTs.

Approve the current list, or expand to include the additional
hosts the skill should declare support for?
```

### Spec-foreign content (binary attachments)

When the packet contains PDFs, images, or other binary files at
the top level:

```
The packet contains <N> binary files (<list>). The Agent Skills
spec recommends `assets/` for binary attachments, separated from
`SKILL.md` and `references/`.

Move the binaries to `assets/`, exclude them from the migration,
or treat the packet as a documentation bundle (not a skill)?
```

### Multiple candidate skills in one packet

When DETECT identifies more than one possible skill in a single
packet (e.g., a prompt pack with 12 prompts):

```
The packet contains <N> candidate skills (<list of slugs>).

Migrate as <N> separate skills (one folder each, each with its
own SKILL.md), as 1 skill with 12 references (single SKILL.md
that points to references/<n>.md per prompt), or split (some
become skills, some become references)?
```

### Tier-2 IP-scrub hit

When the packet contains a pattern from tier-2 (conditional):

```
The packet contains a tier-2 pattern at <file>:<line>. The
pattern shape is <description, not the literal match>. Tier-2
patterns require per-artifact clearance.

Confirm this content is acceptable in the destination
<destination>, redact, or quarantine?
```

### Conflicting facts across sources

When two sources in a foreign packet make contradictory claims:

```
Source <A> at <file:line> states <claim A>.
Source <B> at <file:line> states <claim B that contradicts A>.

Choose the canonical source, mark both as "perspectives" with
attribution, or quarantine the packet for human reconciliation?
```

### Unclear "when to load" trigger

When the agent has drafted a description but cannot confidently
identify the trigger surface:

```
The packet's content suggests it might trigger on:
1. <trigger surface 1>
2. <trigger surface 2>
3. <trigger surface 3>

Which of these (multi-select allowed) should the description
declare? The trigger surface determines when other agents will
load this skill.
```

## Anti-patterns (questions to NOT ask)

The bank explicitly excludes:

- "Is this OK?" (not load-bearing; the human would say yes by
  default).
- "Should I proceed?" (not load-bearing; the agent should know
  whether it has enough information).
- "What do you think?" (not load-bearing; opinion-seeking).
- Questions whose answer the human cannot reasonably know without
  reading the same files the agent just read (the agent has the
  burden of summarization first).
- Questions whose answer is in the canon already (the agent
  should have read the canon first).

## Question budget

Per turn, the agent asks at most 3 questions. If more than 3 gaps
exist, the agent picks the 3 most blocking and queues the rest
for the next turn. Queued questions are written to
`interrogation.md` so the next turn can resume cleanly.

## Format

Each question in a turn is numbered. Each question states:
- The gap (one sentence).
- The proposed default (if one exists).
- The options the human can pick from, or a clear "free text" tag
  if the answer is open-ended.

The agent waits for the human's reply before proceeding to the
next step.

END_SOCRATIC_QUESTION_BANK
