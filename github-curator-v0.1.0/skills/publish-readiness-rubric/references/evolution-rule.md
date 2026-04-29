# evolution-rule.md

The procedure for adding a new row to the 15-row publish-readiness
matrix. Loaded on demand by
`skills/publish-readiness-rubric/SKILL.md`.

## Source

The evolution rule comes from `pre_submit_gate.md` v1.0 in the
upstream 143 Protocol governance set, verbatim:

> Each hard-fail (an artifact that shipped or was about to ship
> and turned out defective) produces a new rule. Bump version.
> Speculative rules forbidden. Only real-failure-derived rules
> enter the gate.

This rubric inherits that rule. The matrix grows only on real
failures, never on speculation.

## Why speculation is forbidden

Speculative rows accumulate. Each speculative row introduces:
- Another check the verifier runs (cost grows linearly).
- Another false-positive surface (a check that fires on edge
  cases that look like the imagined failure but are not).
- Another opportunity for downstream forks to deviate from the
  spec because they cannot pass the row.

Real-failure rows have a known failure mode they are designed to
catch. They are tightly scoped, evidence-grounded, and worth the
verification cost.

## The procedure

A new row is added when:

1. An artifact shipped (or was about to ship) with a defect.
2. The defect was caught by a human, not by the existing matrix.
3. The defect would have been catchable mechanically.
4. The failure mode is not already covered by an existing row.

If all four are true, follow these steps:

### Step 1: Document the failure

In `CHANGELOG.md`, add an entry under Fixed (or Security if the
defect was a tier-1 IP scrub miss) with:
- Date of detection.
- One-paragraph description of the defect.
- One-line description of why the existing matrix did not catch
  it.

Do not reproduce sensitive content. If the defect was a leaked
secret, describe the location and pattern shape, not the secret
itself.

### Step 2: Draft the row

The row has four parts: number, tag, check, expected. Tag is one
of Essential, Important, Optional, Pitfall (see
`criterion-importance-tags.md`).

The check must be:
- Mechanical (not model-graded).
- Deterministic (same input, same output).
- Tightly scoped (does not produce false positives on legitimate
  artifacts).

The expected value is TRUE for most tags, FALSE for Pitfall.

### Step 3: Implement the check

Add the check to `skills/github-curator/scripts/verify-self.sh`
following the same pattern as the existing 15 rows. The check
should:
- Run in under 1 second on a typical repo.
- Use only standard POSIX tools (bash, grep, awk, sed, find).
- Report the failure with enough detail that the human can locate
  and repair it.

### Step 4: Run against this repo

The new row must pass against this repo before it is canonical.
If this repo currently fails the new row, the failure is repaired
in the same commit as the row addition (the row's purpose is to
catch the defect, so this repo is the first beneficiary).

### Step 5: Update the matrix

The matrix lives in two places that must stay in sync:

- `skills/github-curator/references/self-verification-matrix.md`
  (full table, the source of truth).
- `skills/publish-readiness-rubric/SKILL.md` summary section
  (abridged table that points to the source of truth).
- `skills/publish-readiness-rubric/references/scoring-procedure.md`
  (mechanical check description for the new row).

All three must be updated in the same commit.

### Step 6: Bump the rubric version

The rubric version is in the verifier output ("PUBLISH_READINESS_RUBRIC v0.1.0").
Bump per SemVer:

- New row added: MINOR bump (v0.1.0 to v0.2.0).
- Row tag changed (Important to Essential, demotion is rare):
  MAJOR bump if downstream forks would change behavior.
- Row check refined without changing semantics: PATCH bump.

The repo version (in `CHANGELOG.md`) bumps independently per the
release procedure. They are different version streams.

## What "real failure" means concretely

A real failure is:

- An artifact that shipped to a public surface (GitHub Release,
  Greenhouse, LinkedIn, Substack, public repo) and turned out
  defective.
- A near-miss caught at the moment of ship (the human noticed
  before pushing the button).
- A defect found in a downstream fork that would have been caught
  by the upstream matrix if the upstream matrix had the new row.

A real failure is NOT:

- A hypothetical defect imagined during planning.
- A best-practice from another project that has not actually
  failed in this repo's history.
- A failure mode found in the literature but not seen in
  practice here.

The boundary matters because well-meaning expansion of the matrix
quickly accumulates rows that cost more in false-positives than
they save in catches.

## Trinity escalation cells

The Trinity Dialectic 9 cells (in
`references/trinity-3x3-output.md`) follow a different evolution
rule. The cells are fixed at 9, derived from 143 Protocol Section
5. The cell *questions* may be refined as the rubric matures, but
the count of cells does not change. The 3x3 structure is the
constraint.

## Examples of valid evolution

Hypothetical row additions that would be valid (none of these are
canonical until a real failure justifies them):

- Row 16 (Essential): "No `.env` file is committed at any path in
  the repo." Triggered if a downstream fork ships a release with
  `.env` accidentally included.
- Row 17 (Pitfall): "No skill body exceeds 1000 lines." Triggered
  if a real skill becomes hard to read because the body
  ballooned.
- Row 18 (Important): "Every reference doc has a one-line
  description in `SKILL.md` of when to load it." Triggered if a
  downstream fork loads references at the wrong time because the
  trigger condition was unclear.

Each of these would require a documented failure in `CHANGELOG.md`
under Fixed before being added.

## What if a row produces too many false positives

If a new row turns out to false-positive on legitimate artifacts:

1. Document the false positive in `CHANGELOG.md` under Fixed.
2. Refine the check to be more specific (tighter regex, narrower
   path glob).
3. PATCH-bump the rubric version.
4. Re-run the matrix against this repo and against any quarantined
   packets to confirm the refinement does not regress.

If the row is fundamentally unworkable (cannot be made specific
enough), the row is removed. Removal requires:

- A `CHANGELOG.md` entry under Removed.
- A MINOR bump (the row is gone, but the matrix's overall ability
  did not catastrophically regress).
- A note in the next session-dispatch handoff so future sessions
  do not re-add the same row from memory.

## Provenance

This evolution rule is verbatim derived from `pre_submit_gate.md`
v1.0 by Austin B. Green. The principle (real failures only, no
speculation) is invariant. The mechanics (the steps above) are
specific to this rubric.

END_EVOLUTION_RULE
