# criterion-importance-tags.md

The criterion-importance taxonomy used by the publish-readiness
rubric. Loaded on demand by
`skills/publish-readiness-rubric/SKILL.md`.

## Source

The four-tag taxonomy is from "Rubrics as Rewards" (Viswanathan et
al., arXiv 2507.17746). The original paper assigns numeric weights
to each tag for reward shaping in RLHF. This rubric uses the tag
names but not the weights, because the rubric is a binary
publish-gate, not a continuous scoring function.

The hard-rules-vs-principles split is from "OpenRubrics" (arXiv
2510.07743). In that taxonomy, hard rules are objectively
checkable and principles are implicit qualities. This rubric maps
hard rules to Essential and Pitfall tags, principles to Important
and Optional tags.

## The four tags

### Essential

The criterion is a hard requirement. Failure blocks publication.
There is no negotiation, no override at this layer. (The
QUARANTINE workflow allows a human-witnessed override at a
higher layer, with documentation.)

Essential criteria are:
- Spec-conformance (the Agent Skills spec at agentskills.io).
- Legal posture (LICENSE present, recognized).
- Safety posture (no tier-1 IP-scrub hits).
- Format posture (no em dashes or en dashes per pre_submit_gate
  v1.0 rule 3).

In the 15-row matrix, rows 1-7 are Essential.

### Important

The criterion is a strong recommendation. Failure produces
PROMOTE-WITH-WARNING. The packet ships, but the warning is
recorded in the changelog and surfaced to the human.

Important criteria are:
- Cross-vendor compatibility (CLAUDE.md as 3-line pointer).
- Audit trail (CHANGELOG `[Unreleased]` matches diff).
- Tree-registry consistency (registry.yaml matches `skills/`).
- Commit-message hygiene (Conventional Commits).

In the 15-row matrix, rows 8-11 are Important.

### Optional

The criterion is a "nice to have". Failure produces a flag in the
report, no warning, no block. The packet ships normally.

Optional criteria are:
- Compatibility breadth (≥3 hosts listed).
- Progressive-disclosure discipline (references not eagerly loaded).

In the 15-row matrix, rows 12-13 are Optional.

### Pitfall

The criterion is a *negative* check. The expected value is FALSE
(the bad pattern is absent). If the bad pattern is present, the
packet has a structural bug and is blocked, same as Essential.

Pitfall criteria are:
- Eager-load instructions in SKILL.md body (defeats progressive
  disclosure).
- Reference doc body exceeds 5000 lines (suggests it should be
  split).

In the 15-row matrix, rows 14-15 are Pitfall.

## Why two block-tags (Essential and Pitfall) instead of one

Essential and Pitfall both block, but they have opposite truth-table
expectations:

| Tag | Expected | Block on |
|---|---|---|
| Essential | TRUE | FALSE |
| Pitfall | FALSE | TRUE |

The split matters at scoring time:
- Essential rows are positive checks ("the LICENSE file exists").
- Pitfall rows are negative checks ("the body does NOT eagerly load
  references").

Conflating them confuses the report. Keeping them separate makes
the truth table mechanical and unambiguous.

## Why Important is not Essential

The Important tier exists for criteria that are real best practices
but where a one-time exception is sometimes legitimate:

- A repo migrating from a different format may have a temporary
  diff between `registry.yaml` and `skills/` while the migration
  is in progress.
- A first commit may not yet have a Conventional Commits message
  (the hook is not yet installed).
- An emergency security patch may bypass the changelog protocol
  for a few hours, with the changelog updated afterward.

Important produces a warning the human acknowledges. The
acknowledgment is recorded; the warning does not silently
disappear.

## Adding new rows to the matrix

The evolution rule (in `references/evolution-rule.md`) governs new
rows. The tag of a new row is determined by the failure type that
introduced it:

- A failure that shipped and caused real harm: Essential.
- A failure that produced a confusing or hard-to-audit ship but
  no harm: Important.
- A failure that produced a cosmetic issue: Optional.
- A failure pattern that is the negative form of one of the above:
  Pitfall.

The tag is recorded in the matrix at the time the row is added.
Tag changes (Essential becoming Important, for example) require
the same evolution-rule procedure: a documented failure that
justifies the demotion.

## Importance-aware aggregation

The aggregation rule from `SKILL.md`:

```
ESSENTIAL_PASS = all Essential rows TRUE
PITFALL_PASS = all Pitfall rows FALSE
IMPORTANT_PASS = all Important rows TRUE
OPTIONAL_PASS = all Optional rows TRUE  # informational only

if not (ESSENTIAL_PASS and PITFALL_PASS):
    VERDICT = QUARANTINE
elif IMPORTANT_PASS:
    VERDICT = PROMOTE
else:
    VERDICT = PROMOTE-WITH-WARNING
```

Optional rows do not affect the verdict. They surface in the
report so the human sees them, but they do not gate.

## What this taxonomy is NOT

1. Not a numeric weighting scheme. The rubric is binary per row.
   The arXiv 2507.17746 weights are useful for RLHF reward shaping
   but introduce false precision in a publish-gate.
2. Not a substitute for human judgment. The rubric is mechanical;
   the human's PEL verdict is the final gate.
3. Not extensible by speculation. New rows enter via the evolution
   rule (a real failure documented in CHANGELOG.md), not by
   imagining future failure modes.

END_CRITERION_IMPORTANCE_TAGS
