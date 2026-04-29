# canonical-workstream-examples.md

Worked examples of the most common workstreams the
session-dispatch skill bootstraps. Loaded on demand by
`skills/session-dispatch/SKILL.md` only when the human asks for
a template or a starting point.

Each example shows the slug, the target host, the canon-attach
list, and a draft AGENTS.md plus HANDOFF.md.

## Example 1: ingest a new prompt pack

```
slug: prompt-pack-ingest-2026-04-26
host: Claude Code
scope: Ingest a third-party prompt pack from a colleague,
       evaluate against publish-readiness-rubric, route to
       quarantine or skills/.
canon attached:
  - skills/ingest/SKILL.md (in repo)
  - skills/publish-readiness-rubric/SKILL.md (in repo)
  - the prompt pack zip (the bundle being ingested)
canon referenced (not attached):
  - https://agentskills.io/specification
out of scope:
  - editing existing canonical skills
  - cutting a release
deliverables:
  1. Each prompt classified as conformant, adjacent, or foreign.
     Done condition: inventory.json exists.
  2. Each candidate skill scored. Done condition: rubric report
     per candidate exists.
  3. Promoted candidates moved to skills/. Quarantined candidates
     moved to quarantine/. Done condition: tree state matches
     decisions.
```

The dispatcher emits AGENTS.md for the new Claude Code session
that mirrors the repo's root AGENTS.md but with a "Workstream"
section pasted at the top describing this scope.

## Example 2: archive sunset (DeFi or other deprecated project)

```
slug: project-sunset-archive-<projectname>
host: Claude Code
scope: Apply the standard sunset banner to N forked repos,
       set GitHub archived flag, link to project's GitBook or
       blog post, preserve upstream attribution per Apache 2.0
       Section 4.
canon attached:
  - skills/github-curator/SKILL.md (in repo)
  - skills/publish-readiness-rubric/references/ip-scrub-tiers.md
  - the list of repos to archive
canon referenced (not attached):
  - https://github.com/makerdao/dai.js (sunset banner exemplar)
  - https://github.com/yearn/yearn-protocol (archived flag exemplar)
  - the project's GitBook URL
out of scope:
  - modifying upstream LICENSE files (preservation only)
  - deleting commit history
deliverables:
  1. Each forked repo has a # ARCHIVED banner prepended to README.
  2. Each forked repo has the GitHub archived flag set.
  3. An index repo lists all archived repos plus the GitBook URL.
  4. Pre-submit gate v1.0 returns PASS for the index repo.
```

The dispatcher attaches the canon-attach list, the slim sunset
banner template, and the verification matrix for the index repo.
The new session does the work in a fresh chat without dragging in
context from the parent.

## Example 3: NotebookLM source bundle migration

```
slug: notebooklm-migrate-<notebook-name>
host: Claude Code
scope: Migrate a NotebookLM notebook's sources into a single
       Agent Skills spec-conformant skill folder under skills/.
canon attached:
  - skills/ingest/SKILL.md
  - skills/ingest/references/notebooklm-migration.md
  - skills/ingest/references/socratic-question-bank.md
  - the NotebookLM export folder (or zip)
canon referenced (not attached):
  - https://agentskills.io/specification
out of scope:
  - migrating into multiple skills (use the multi-skill workflow
    instead if the bundle is actually multiple skills)
  - exporting to a wiki or doc site format
deliverables:
  1. INVENTORY of the bundle (sha256 per file).
  2. CLASSIFY per file (SKILL.md body, reference, asset, exclude).
  3. SKILL.md drafted with frontmatter, INTERROGATE rounds
     resolved.
  4. references/ and assets/ populated.
  5. Rubric returns PROMOTE.
```

The dispatcher emits this as a Claude Code session because the
working-directory model fits the iterative migration. NotebookLM
itself is the source, not the target host for the session.

## Example 4: Trinity escalation for a public release

```
slug: trinity-public-release-<artifact-name>
host: Claude Code
scope: Run the 9-cell Trinity Dialectic on an artifact about to
       publish to a public surface (Greenhouse, arXiv, public
       repo).
canon attached:
  - skills/publish-readiness-rubric/SKILL.md
  - skills/publish-readiness-rubric/references/trinity-3x3-output.md
  - the artifact under review
canon referenced (not attached):
  - skills/publish-readiness-rubric/references/criterion-importance-tags.md
out of scope:
  - issuing the human's PEL verdict (PEL is the human's role only)
  - mechanical 15-row matrix changes (separate workstream)
deliverables:
  1. Trinity report with 9 cells PASS/FAIL plus reason per cell.
  2. Repair list for any FAIL cells.
  3. Verdict: 100% confidence (9 PASS) or BELOW.
  4. PEL packet drafted (Architecture, Evidence, Intent triplet)
     for the human to sign.
```

This workstream typically runs in a single session (Trinity is not
context-heavy); the dispatcher exists so the work is auditable as
its own session-record rather than embedded in a larger thread.

## Example 5: ad-hoc personal-data ingestion

The simplest workstream: the human has a folder of personal
material (notes, journal entries, prompts they wrote, references)
and wants it ingested as a new skill or skill set.

```
slug: personal-data-ingest-<topic>
host: Claude Code (or NotebookLM if Claude Code not available)
scope: Absorb the human's personal folder into a spec-conformant
       skill, with full Socratic interrogation on identity,
       voice, and IP exclusions.
canon attached:
  - skills/ingest/SKILL.md
  - skills/ingest/references/socratic-question-bank.md
  - skills/publish-readiness-rubric/references/ip-scrub-tiers.md
  - the personal data folder
canon referenced (not attached):
  - https://agentskills.io/specification
out of scope:
  - publishing the resulting skill (separate workstream)
deliverables:
  1. INTERROGATE resolves all gaps.
  2. SKILL.md draft with frontmatter approved by the human.
  3. references/ populated, IP scrub PASS.
  4. Skill placed in skills/ with [Unreleased] CHANGELOG entry.
```

This is the workstream that lets a human turn personal context
into a portable skill. The session-dispatch skill is the
recurring entry point; the human creates a new session per topic
without losing the conversation in a giant thread.

## Pattern: every example has the same shape

The five examples differ in scope but share the structure:

- Slug, host, scope (the SCOPE step).
- Canon attached, canon referenced, out-of-scope (the ENUMERATE
  step).
- Deliverables with done conditions.

This shape is the contract. Future workstreams that follow it
reuse the dispatcher with no template changes; future workstreams
that deviate from it should explain why before they emit.

## When to NOT use a worked example

The examples above are starting points. The dispatcher does NOT
copy them verbatim. Each new workstream gets its own slug, its
own canon list, its own deliverables. The example is shape, not
content.

If the human asks for "the canonical FATEx workstream" or "the
canonical resume workstream", the answer is: the workstream-specific
canon and deliverables come from the human, the shape comes from
this file.

END_CANONICAL_WORKSTREAM_EXAMPLES
