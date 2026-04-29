---
name: ingest
description: "Use this skill when absorbing an external project bundle, prompt pack, agent packet, or skill folder into a curated repository, especially when the source needs to be evaluated for publish-readiness before it lands in the canonical tree. Triggers: any request to ingest a packet, absorb a folder, evaluate a prompt pack against a rubric, route a third-party skill through gates, or convert a NotebookLM source bundle into a SKILL.md-conformant skill. The skill runs an interrogation loop with the human if the source is incomplete, never assumes missing fields, and produces a quarantine-or-promote verdict at the end. Do NOT use this skill for editing skills already in the canonical tree (use github-curator), for evaluating finished artifacts ready to publish (use publish-readiness-rubric), or for arbitrary file ingestion unrelated to the Agent Skills format."
license: Apache-2.0
compatibility: "Claude Code, Codex, Cursor, Aider, Gemini CLI, Antigravity, Claude.ai projects, NotebookLM (via packet zip), custom Gems, custom GPTs"
---

# ingest

The absorption skill. Takes a packet from outside the repo, routes it
through the four-gate publish-readiness pattern, and emits either a
promotion to the canonical `skills/` tree or a quarantine record with
the specific failed gates listed.

## Why this skill exists

Bundles arrive in many shapes: a prompt pack from another agent, a
NotebookLM source bundle, a folder dragged out of a Claude project, a
zip downloaded from a colleague's GitHub release. The Agent Skills
specification at https://agentskills.io/specification defines a single
canonical shape: a folder named after the skill, containing
`SKILL.md` with valid YAML frontmatter, plus optional `references/`,
`scripts/`, `assets/`. Anything that does not match the spec must be
either repaired into spec conformance or quarantined.

The Zero Assumption Mandate from 143 Protocol Section 3 forbids the
agent from inferring missing frontmatter, padding short descriptions,
or guessing at host compatibility. When information is missing, this
skill asks the human, using the Socratic Method (max 3 load-bearing
questions per turn).

## When to use

Load this skill when any of the following is true:

1. The user has dropped a folder, zip, or markdown file into the
   working directory and asked the agent to absorb it.
2. The user has named a packet by URL or local path and asked for it
   to be added to `skills/`.
3. The user has asked the agent to evaluate whether a third-party
   skill is publish-ready before it is checked in.
4. The user is migrating a NotebookLM-shaped source bundle into the
   Agent Skills format.

Do not load this skill for editing existing canonical skills (load
`github-curator`), for the final publish-readiness check on a
finished artifact (load `publish-readiness-rubric`), or for arbitrary
file ingestion such as importing data files for analysis.

## The loop

```
DETECT -> NORMALIZE -> INTERROGATE -> SCORE -> ROUTE
```

Each step writes to the file system. None of the steps mutate the
canonical `skills/` tree until ROUTE returns PROMOTE.

### DETECT (active sensing)

1. Locate the source. If it is a zip, unpack to a working directory
   under `/tmp/ingest/<timestamp>/`.
2. Catalogue every file. Compute sha256 per file. Save the catalogue
   to `/tmp/ingest/<timestamp>/manifest.json`.
3. Identify the packet shape:
   - Spec-conformant: a folder containing `SKILL.md` with valid
     frontmatter.
   - Spec-adjacent: a folder containing markdown files but missing
     frontmatter, or with frontmatter that does not validate.
   - Spec-foreign: a folder of mixed content (PDFs, prompts in plain
     text, scattered markdown, JSON files, no clear skill structure).

The shape determines the NORMALIZE strategy.

### NORMALIZE (reasoning)

For spec-conformant packets, NORMALIZE is a no-op. Proceed to
INTERROGATE only if the human has flagged a known issue.

For spec-adjacent packets:
1. Propose the missing frontmatter fields.
2. The agent does not write proposed values silently. The proposed
   values become the first round of interrogation questions.

For spec-foreign packets:
1. Identify the candidate skill or skills hidden in the bundle. A
   prompt pack with 12 prompts produces 12 candidate skills. A
   NotebookLM bundle with 5 markdown files plus 3 PDFs produces a
   structured proposal: which markdown becomes a `SKILL.md`, which
   become `references/`, which PDFs become assets.
2. The proposal is a write-list. It is not executed until INTERROGATE
   returns answers.

### INTERROGATE (Socratic Method, max 3 load-bearing questions per turn)

For each missing or ambiguous field, the skill asks the human a
load-bearing question. Each question must close a specific gap that
would otherwise force an assumption. The total per turn is capped at
3, in line with 143 Protocol's Socratic interaction rule.

Common interrogation patterns:

- Missing `name`: "The folder is called `X`. The Agent Skills spec
  requires `name` to equal the parent directory name, lowercase
  hyphenated, ≤64 chars. Confirm `name: X`, or supply a different
  name and rename the folder?"
- Short `description`: "The current description is N chars. The spec
  requires 1 to 1024 chars and recommends covering both *what* the
  skill does and *when* to use it. Add a 'when to use' clause, or
  approve the current text?"
- Missing `license`: "The license field is empty. Recommended values:
  `Apache-2.0` (this repo's default) or `MIT`. Confirm Apache-2.0?"
- Missing `compatibility`: "The compatibility field is empty.
  Recommend listing at least 3 host environments. Confirm
  'Claude Code, Cursor, NotebookLM (via packet zip)'?"
- Spec-foreign content: "The bundle contains 3 PDFs. The Agent Skills
  spec recommends `assets/` for binary attachments. Move them to
  `assets/`, or strip them?"

If the human supplies an answer, the value is locked into the
proposal and the next round of interrogation runs. If the human
declines to answer or marks the field "leave empty", the gap is
recorded in the quarantine record.

### SCORE (boolean-atomic rubric)

Once interrogation is complete, run the
`publish-readiness-rubric` skill against the proposed packet. The
rubric returns a 15-row matrix per the same schema used by
`github-curator`'s self-verification. The rubric is not part of this
skill; it is a sibling, loaded on demand.

The rubric output is binary per row. Aggregate verdict:

- All Essential rows TRUE and no Pitfall rows TRUE: PROMOTE.
- Any Essential row FALSE: QUARANTINE.
- Any Pitfall row TRUE: QUARANTINE.
- Important rows FALSE: PROMOTE-WITH-WARNING (human confirms).

### ROUTE (artifact generation)

PROMOTE:
1. Move the working directory contents to `skills/<n>/` in the
   canonical tree.
2. Append a row to `registry.yaml`.
3. Update `CHANGELOG.md` `[Unreleased]` with an Added entry.
4. Run `skills/github-curator/scripts/verify-self.sh`. The matrix
   must PASS before the change is committable.

QUARANTINE:
1. Move the working directory to `quarantine/<timestamp>-<n>/`.
2. Write `quarantine/<timestamp>-<n>/QUARANTINE.md` containing the
   rubric output, the failed rows, the interrogation transcript, and
   the human's decisions.
3. Do not modify the canonical tree.
4. Surface the quarantine record to the human with a numbered list
   of remediation steps. The human decides whether to repair and
   retry, or to discard.

PROMOTE-WITH-WARNING:
1. Same as PROMOTE, but `CHANGELOG.md` entry includes the warning
   list.
2. Surface the warnings to the human in the turn summary.

## The interrogation rule (Zero Assumption)

If the agent ever finds itself filling in a field on the human's
behalf without an explicit answer, the skill has failed. The agent
must STOP and ask. This is verbatim from 143 Protocol Axiom 1:
"Never provide unverified or incorrect assumptions. If uncertain,
STOP and ask."

Common failure modes to catch:

- The agent guesses the `description` text from the file contents.
  Wrong: the description is a contract with future agents about
  *when* to load the skill, and only the human knows the intended
  trigger surface.
- The agent infers compatibility from the presence of `.cursor/` or
  `.claude/` markers. Wrong: presence of an artifact is not consent
  to declare host compatibility.
- The agent picks a license because the source repo had one.
  Partially correct: only PROMOTE if the upstream license is
  preserved unmodified per Apache 2.0 Section 4 (or the source's
  equivalent). The human confirms the relicensing posture.

## Reference docs

Loaded on demand, not at activation:

- `references/packet-shapes.md` the three packet shapes (conformant,
  adjacent, foreign) with detection rules and examples.
- `references/notebooklm-migration.md` the specific procedure for
  converting a NotebookLM source bundle (manifest plus sources) into
  Agent Skills format.
- `references/quarantine-procedure.md` the QUARANTINE.md template
  and the remediation playbook.
- `references/socratic-question-bank.md` the load-bearing question
  patterns for each common ambiguity (name, description, license,
  compatibility, content shape, IP posture).

## Composition with other skills

- `publish-readiness-rubric` is loaded at SCORE. Always.
- `github-curator` is loaded after PROMOTE to register the new skill
  in the tree and run the self-verification matrix.
- `session-dispatch` is loaded when the bundle is large enough that
  the ingest exceeds a single chat session's context budget. The
  dispatcher writes a HANDOFF document and the human resumes in a
  fresh session.

## Provenance

This SKILL.md was authored 2026-04-26 by Austin B. Green. The
ingest pattern composes the Zero Assumption Mandate (143 Protocol
Section 3), the Socratic Method (143 Protocol interaction rule),
the four-gate publish-readiness pattern (pre_submit_gate v1.0
authored by Austin B. Green), and the open Agent Skills
specification (https://agentskills.io/specification).

END_INGEST_SKILL
