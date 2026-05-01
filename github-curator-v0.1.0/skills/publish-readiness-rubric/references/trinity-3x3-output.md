# trinity-3x3-output.md

The 9-cell Trinity Dialectic output format. Loaded on demand by
`skills/publish-readiness-rubric/SKILL.md` only when the human
tags an artifact "run Trinity".

## Source

The 3x3 matrix is from system_directive_protocol Section 5 (the 100% Confidence
Loop and Trinity Dialectic). The matrix decomposes evaluation along
two axes: paths (Logos, Pathos, Ethos) and kinds (Form, Kind,
State). Their product is 9 sub-evaluations.

The rubric engine in `SKILL.md` provides the cell list. This
reference doc provides the output format and the promotion rule.

## When to escalate to Trinity

The default consequential-action gate is the 15-row matrix. Trinity
is reserved for:

- Greenhouse submission (job application).
- Public paper publication (arXiv, peer-reviewed journal).
- Public repo release (a tagged release on a public GitHub repo).
- Any artifact the human explicitly tags "run Trinity".

The 15-row matrix runs unconditionally. Trinity layers on top.

## Output format

```
TRINITY_DIALECTIC_REPORT v0.1.0
artifact: <path or identifier>
date: <ISO 8601>
scorer: publish-readiness-rubric (Trinity escalation)

| Cell | Result | One-line reason |
|---|---|---|
| Logos x Form | PASS / FAIL | <reason> |
| Logos x Kind | PASS / FAIL | <reason> |
| Logos x State | PASS / FAIL | <reason> |
| Pathos x Form | PASS / FAIL | <reason> |
| Pathos x Kind | PASS / FAIL | <reason> |
| Pathos x State | PASS / FAIL | <reason> |
| Ethos x Form | PASS / FAIL | <reason> |
| Ethos x Kind | PASS / FAIL | <reason> |
| Ethos x State | PASS / FAIL | <reason> |

Aggregate per axis:
  Logos:  N PASS / 3-N FAIL
  Pathos: N PASS / 3-N FAIL
  Ethos:  N PASS / 3-N FAIL

Verdict: 100% confidence (9 PASS) or BELOW with cell-by-cell repair list.
```

## Promotion rule (the rule of three accord)

From system_directive_protocol Section 5 verbatim: "Action is only justified
when both [Logos and Pathos] are in accord and validated by 9
sub-evaluators."

Implementation: action is justified ONLY when all three axes score
3 PASS each (9 PASS total). ANY axis with at least one FAIL pauses
ship and produces a repair list.

```
def trinity_verdict(cells):
    logos_pass = all(cells[k] == "PASS" for k in logos_cells)
    pathos_pass = all(cells[k] == "PASS" for k in pathos_cells)
    ethos_pass = all(cells[k] == "PASS" for k in ethos_cells)
    if logos_pass and pathos_pass and ethos_pass:
        return "100%_CONFIDENCE_PROMOTE"
    return "REPAIR_REQUIRED"
```

## Cell-evaluation guidance

Each cell asks a specific question. The rubric engine surfaces the
question, runs the check (mechanical where possible, model-graded
where necessary), and records PASS/FAIL with a one-line reason.

The cell questions are in `skills/publish-readiness-rubric/SKILL.md`
under "The Trinity Dialectic 3x3 (escalation)". Repeated here for
self-containment of this reference doc:

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

## Mechanical vs model-graded cells

Three cells are mechanically checkable:

- Logos x Form: structural validation overlaps with rows 1-5 and
  10 of the 15-row matrix. The Trinity escalation re-runs them and
  also checks for internal logical contradictions across the
  artifact (a stronger check than the 15-row baseline).
- Logos x Kind: each claim in the artifact is traced. If the
  artifact has citation infrastructure (footnotes, inline links,
  evidence blocks), each citation is verified resolvable. Untraced
  claims surface as FAIL.
- Ethos x Form: ethics-bounds check overlaps with row 7 (IP
  scrub). The Trinity escalation extends to tier-3 patterns and
  flags any unconfirmed.

Six cells are model-graded or human-graded:

- Logos x State, Pathos x Form/Kind/State, Ethos x Kind/State all
  require judgment about reception, voice, current identity,
  consequences. The agent surfaces the cell with its draft
  assessment and asks the human to confirm PASS or supply the
  FAIL reason.

The agent never self-issues the model-graded cells. It surfaces
its draft and waits for the human's verdict.

## What this report does NOT do

1. Does not bypass the 15-row matrix. Trinity is in addition,
   never instead.
2. Does not bypass the human's PEL verdict. PEL is the final
   gate per pre_submit_gate v1.0 rule 4.
3. Does not auto-repair. A FAIL cell produces a repair item; the
   human decides whether to repair, override, or quarantine.

## Cell repair format

When a cell fails:

```
REPAIR ITEM
cell: <axis> x <kind>
status: FAIL
reason: <one line>
proposed repair: <one or two specific edits to the artifact>
```

The repair item enters the next ingest cycle as a focused edit
target.

END_TRINITY_3X3_OUTPUT
