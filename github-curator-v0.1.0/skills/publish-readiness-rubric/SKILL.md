---
name: publish-readiness-rubric
description: "Use this skill when scoring an artifact's readiness for publication on GitHub, especially when the artifact must pass a deterministic boolean-atomic check before it ships. Triggers: any request to evaluate an artifact for publish-readiness, run the four-gate check, score against the Trinity Dialectic 3x3, generate a publish-readiness report, or apply criterion tags (Essential / Important / Optional / Pitfall) to a structured evaluation. The skill returns a binary verdict per row plus an aggregate verdict (PROMOTE / QUARANTINE / PROMOTE-WITH-WARNING). The rubric is mechanical, deterministic, and reproducible: the same input produces the same output. Do NOT use this skill for subjective quality assessment, for free-form code review, or as a substitute for the human's Pathos-Ethos-Logos verdict (PEL=1 is required and cannot be self-issued by the agent)."
license: Apache-2.0
compatibility: "Claude Code, Codex, Cursor, Aider, Gemini CLI, Antigravity, Claude.ai projects, NotebookLM (via packet zip), custom Gems, custom GPTs"
---

# publish-readiness-rubric

The rubric engine. Scores an artifact against a 15-row boolean-atomic
matrix, applies criterion-importance tags from the Rubrics-as-Rewards
pattern (arXiv 2507.17746), and emits a deterministic verdict.

## Why this skill exists

Subjective publish-readiness assessments fail predictably. Two reviewers
score the same artifact differently, a single reviewer scores the same
artifact differently on different days, and the criteria drift over
time as edge cases accumulate. The boolean-atomic rubric pattern
solves all three: each row returns TRUE or FALSE, each row has a
single objective check, and the criteria are version-controlled in
this file.

The criterion-importance taxonomy (Essential / Important / Optional /
Pitfall) is taken from "Rubrics as Rewards" (Viswanathan et al., arXiv
2507.17746). The hard-rules-vs-principles split is taken from
"OpenRubrics" (arXiv 2510.07743). The atomic-criteria approach is the
same one Anthropic, OpenAI HealthBench (`openai/simple-evals`), and
Scale AI use internally for evaluation.

This skill is the engine. It is called by `ingest` at SCORE, by
`github-curator` at STOP, and by the human directly when running an
ad-hoc check.

## When to use

Load this skill when the agent is asked to:

1. Evaluate any artifact (skill folder, markdown doc, packet zip) for
   publish-readiness.
2. Run the four-gate check (IP scrub, date consistency, no em dashes,
   PEL packet preparation).
3. Produce a Trinity Dialectic 3x3 report.
4. Apply criterion-importance tags to an existing checklist.

Do not load this skill for subjective review, for arbitrary code
review, or to issue a PEL=1 verdict. The agent never self-issues PEL.
The human runs PEL after the rubric returns PROMOTE.

## The 15-row matrix

The rubric is fixed at 15 rows. New rows are added only when a real
publish-time failure surfaces a gap (the evolution rule from
pre_submit_gate v1.0). Speculative rows are forbidden.

Each row has four parts:

```
| # | Tag | Check | Expected |
```

`Tag` is one of: Essential, Important, Optional, Pitfall.
`Check` is a single objective question with a TRUE/FALSE answer.
`Expected` is the value that means PASS (TRUE for most rows; FALSE for
Pitfall rows).

| # | Tag | Check | Expected |
|---|---|---|---|
| 1 | Essential | `AGENTS.md` exists at repo root. | TRUE |
| 2 | Essential | Each `skills/<n>/SKILL.md` frontmatter validates against agentskills.io spec. | TRUE |
| 3 | Essential | Skill `name` field equals parent directory name, lowercase-hyphenated, ≤64 chars. | TRUE |
| 4 | Essential | `description` field length is between 1 and 1024 chars. | TRUE |
| 5 | Essential | `LICENSE` exists at repo root and is a recognized open license. | TRUE |
| 6 | Essential | No em dashes (U+2014) and no en dashes (U+2013) anywhere in the artifact. | TRUE |
| 7 | Essential | No tier-1 IP scrub hits (see references/ip-scrub-tiers.md). | TRUE |
| 8 | Important | `CLAUDE.md` is the 3-line pointer to `AGENTS.md` (or symlink). | TRUE |
| 9 | Important | `CHANGELOG.md` `[Unreleased]` reflects the diff being scored. | TRUE |
| 10 | Important | `registry.yaml` rows match the `skills/` tree (no orphans, no missing). | TRUE |
| 11 | Important | Conventional Commits message proposed for the change. | TRUE |
| 12 | Optional | Compatibility field lists at least 3 host environments. | TRUE |
| 13 | Optional | Reference docs follow progressive-disclosure conventions (loaded on demand, not eagerly). | TRUE |
| 14 | Pitfall | Skill loads more than one body at activation time. | FALSE |
| 15 | Pitfall | Reference doc is loaded eagerly in `SKILL.md` body (not on demand). | FALSE |

## Scoring procedure

1. Load the artifact under review. If it is a directory, walk it
   recursively. If it is a zip, unpack to `/tmp/score/<timestamp>/`.
2. For each row, run the check. The check is mechanical:
   - Row 1: `test -f $REPO/AGENTS.md` returns 0.
   - Row 2: parse YAML frontmatter, validate against the spec.
   - Row 3: regex `^[a-z0-9][a-z0-9-]*$`, length ≤64, equals dirname.
   - Row 4: char count of description string, 1 to 1024.
   - Row 5: `LICENSE` file exists, contains "Apache License" or "MIT
     License" or another SPDX identifier.
   - Row 6: grep for U+2014 and U+2013 across the artifact tree.
   - Row 7: run the IP scrub against tier-1 patterns (see
     `references/ip-scrub-tiers.md`).
   - Rows 8 to 15: see `references/scoring-procedure.md` for full
     mechanical checks.
3. Record TRUE/FALSE per row.
4. Aggregate.

## Aggregation

```
ESSENTIAL_PASS = all Essential rows TRUE
PITFALL_PASS = all Pitfall rows FALSE
IMPORTANT_PASS = all Important rows TRUE
OPTIONAL_PASS = all Optional rows TRUE

VERDICT:
  if not (ESSENTIAL_PASS and PITFALL_PASS):
    QUARANTINE
  elif IMPORTANT_PASS:
    PROMOTE
  else:
    PROMOTE-WITH-WARNING
```

## Output format

The rubric returns a deterministic markdown report:

```
PUBLISH_READINESS_RUBRIC v0.1.0
artifact: <path or identifier>
date: <ISO 8601>
scorer: publish-readiness-rubric

| # | Tag | Result | Reason if FAIL |
|---|---|---|---|
| 1 | Essential | PASS | |
| 2 | Essential | PASS | |
... (15 rows total)

Aggregate:
  Essential: N PASS / M FAIL
  Important: N PASS / M FAIL
  Optional: N PASS / M FAIL
  Pitfall: N FALSE (good) / M TRUE (bad)

VERDICT: PROMOTE / QUARANTINE / PROMOTE-WITH-WARNING

Repair list (if QUARANTINE):
  - row N: <one-line repair instruction>
  ...
```

The same input produces the same output. The rubric is reproducible.

## The Trinity Dialectic 3x3 (escalation)

For artifacts the human tags "run Trinity" (Greenhouse submission,
public paper publication, public repo release), this skill also runs
the 9-cell matrix from system_directive_protocol Section 5. The 9 cells are:

| Cell | Question |
|---|---|
| Logos x Form | Is the artifact's structure logically sound, free of contradictions, atomically organized? |
| Logos x Kind | Are the artifact's claims supported by traceable evidence (canon citation or human confirmation)? |
| Logos x State | Does the artifact's reasoning chain match the human's current technical position (not stale)? |
| Pathos x Form | Does the structure serve its persuasive purpose? |
| Pathos x Kind | Will the artifact land with the intended reader as the human hopes? |
| Pathos x State | Does the artifact express the human's voice as the human wants to be heard right now? |
| Ethos x Form | Is the structure within the bounds of the human's professional and personal ethics? |
| Ethos x Kind | Are the consequences of shipping net-positive across all stakeholders? |
| Ethos x State | Does shipping preserve the human's integrity given current commitments and identity? |

Trinity is escalation, not default. The default consequential-action
gate is the simpler 15-row matrix above. Trinity is reserved for
explicit "run Trinity" tags.

The full Trinity output format is in
`references/trinity-3x3-output.md`.

## What this skill does NOT do

1. Does not issue PEL (Pathos-Ethos-Logos) verdicts. PEL is the
   human's role per pre_submit_gate v1.0 rule 4.
2. Does not score subjective quality. "Is this prompt good" is not
   in the matrix; "does this prompt's frontmatter validate" is.
3. Does not modify the artifact. The rubric is read-only on the
   artifact under review.
4. Does not invent rows. New rows enter the matrix only after a
   real failure documented in CHANGELOG.

## Reference docs

Loaded on demand, not at activation:

- `references/scoring-procedure.md` the full mechanical check per row,
  including regex patterns and exact commands.
- `references/ip-scrub-tiers.md` the tier-1, tier-2, tier-3 IP scrub
  patterns from the system_directive_protocol governance set.
- `references/trinity-3x3-output.md` the 9-cell escalation format.
- `references/criterion-importance-tags.md` the Essential / Important
  / Optional / Pitfall taxonomy with examples and arXiv lineage.
- `references/evolution-rule.md` the procedure for adding a new row
  (real failure required, no speculation).

## Provenance

This SKILL.md was authored 2026-04-26 by 0SxD. The
boolean-atomic rubric pattern composes the Rubrics-as-Rewards
importance taxonomy (arXiv 2507.17746), the OpenRubrics
hard-rules-vs-principles split (arXiv 2510.07743), the
HealthBench atomic-criterion approach (`openai/simple-evals`), the
pre_submit_gate v1.0 four-rule pattern, and the Trinity Dialectic
3x3 from system_directive_protocol Section 5. All authored or composed by 0SxD; arXiv references are upstream.

END_PUBLISH_READINESS_RUBRIC_SKILL
