# self-verification-matrix.md

The 15-row boolean-atomic check that this repo runs against itself on
every change. Loaded on demand by `skills/github-curator/SKILL.md`.
Implemented in `skills/github-curator/scripts/verify-self.sh`.

## Source

The matrix is identical to the one in `skills/publish-readiness-rubric/SKILL.md`.
The same engine scores both the repo (this skill calls it for self-verification)
and external bundles (the `ingest` skill calls it at SCORE).

## The 15 rows

| # | Tag | Mechanical check | Expected |
|---|---|---|---|
| 1 | Essential | `test -f $REPO/AGENTS.md` returns 0 | TRUE |
| 2 | Essential | For each `skills/*/SKILL.md`: parse YAML frontmatter, validate against agentskills.io spec (name, description present; license, compatibility optional) | TRUE |
| 3 | Essential | For each skill: `name` field matches regex `^[a-z0-9][a-z0-9-]*$`, length ≤64, equals parent directory name | TRUE |
| 4 | Essential | For each skill: `description` field length is between 1 and 1024 chars (inclusive) | TRUE |
| 5 | Essential | `test -f $REPO/LICENSE` and file contains a recognized SPDX license header | TRUE |
| 6 | Essential | `grep -rn $'\u2014\|\u2013' $REPO --include='*.md'` returns no matches | TRUE |
| 7 | Essential | Run `references/ip-scrub-tiers.md` tier-1 patterns against the repo. No matches | TRUE |
| 8 | Important | `CLAUDE.md` content matches the 3-line pointer template (or is a real symlink) | TRUE |
| 9 | Important | `CHANGELOG.md` `[Unreleased]` section's diff matches the actual git diff for the change | TRUE |
| 10 | Important | Set of skill folder names equals set of `registry.yaml` `path` entries (no orphans, no missing) | TRUE |
| 11 | Important | Proposed commit message starts with a Conventional Commits type (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `release:`) | TRUE |
| 12 | Optional | Each skill's `compatibility` field lists at least 3 host environments, comma-separated | TRUE |
| 13 | Optional | Reference docs are referenced from `SKILL.md` only by relative path under "Reference docs" section, not inlined | TRUE |
| 14 | Pitfall | Any `SKILL.md` body contains `Read references/` or equivalent eager-load instruction in the activation path | FALSE |
| 15 | Pitfall | Any reference doc body exceeds 5000 lines (suggests it should be split) | FALSE |

## Implementation notes per row

### Row 1
Trivial. `test -f` either succeeds or fails.

### Row 2
The Agent Skills spec at https://agentskills.io/specification defines:
- Required: `name` (1-64 chars, lowercase-hyphenated, regex
  `^[a-z0-9][a-z0-9-]*$`).
- Required: `description` (1-1024 chars).
- Optional: `license` (SPDX identifier or "Proprietary" or free text).
- Optional: `compatibility` (free text).
- Optional: `metadata` (free-form object).
- Optional, experimental: `allowed-tools`.

The validator parses YAML, checks for the two required fields, checks
field types, and emits FAIL on any deviation.

### Row 3
The `name` field must equal the parent directory's basename. This is
the spec's anti-drift rule: if the directory is renamed, the SKILL.md
must be renamed in lockstep.

### Row 4
Char count of the `description` string. The 1-1024 range is the spec.

### Row 5
SPDX identifier matching. Recognized headers include "Apache License,
Version 2.0", "MIT License", "BSD 3-Clause License", "Mozilla Public
License Version 2.0", "GNU General Public License", "Creative Commons".

### Row 6
The em dash is U+2014, the en dash is U+2013. Both are blocked by
pre_submit_gate v1.0 rule 3 in the upstream 143 Protocol governance
set. Replacement guidance:
- U+2014 to comma, semicolon, colon, parentheses, or line break.
- U+2013 to "to" in date ranges.

### Row 7
The IP scrub procedure is in `references/ip-scrub-tiers.md`. Tier-1
patterns are unconditional blocks: machine hostnames, internal
usernames, Windows paths, internal lane codes, API key patterns,
strategy names, file references, NotebookLM UUIDs, personal documents,
operational details. Any tier-1 hit fails this row.

### Row 8
The 3-line pointer template:
```
# CLAUDE.md

This file is functionally a symlink to `AGENTS.md`. Read that file. ...
```
Acceptable variations: any text that explicitly delegates to AGENTS.md
without introducing divergent instructions. A real filesystem symlink
also satisfies the row.

### Row 9
Compute `git diff` between HEAD and the commit being prepared. Compare
the file paths in the diff against the entries in `[Unreleased]`. Each
modified file should be implicitly or explicitly covered.

### Row 10
Walk `skills/` for directory names. Walk `registry.yaml` for `path`
entries. Set difference must be empty in both directions.

### Row 11
The proposed commit message is in the agent's working state. The
verifier accepts it as input. Conventional Commits format: `<type>:
<description>`, with `<type>` one of: feat, fix, docs, style,
refactor, perf, test, build, ci, chore, revert. Breaking changes
append `!`.

### Row 12
Count comma-separated tokens in the `compatibility` field. ≥3 is the
recommendation. Below 3 is a warning, not a block.

### Row 13
Grep `SKILL.md` bodies for filesystem paths under `references/`. Each
match must be inside a "Reference docs" section that explicitly says
"Loaded on demand, not at activation". Eager-load language outside
that section fails this row.

### Row 14
Specifically: the `SKILL.md` body before the "Reference docs" section
must not instruct the agent to load any reference doc. The body is
what loads on activation; reference docs are progressive-disclosure
material that loads only when SKILL.md instructions inside the body
explicitly invoke them.

### Row 15
Line count per reference doc. >5000 lines suggests the doc should
split into smaller docs, each independently loadable.

## Aggregation

```
ESSENTIAL_PASS = all rows 1-7 are TRUE
PITFALL_PASS = rows 14, 15 are FALSE
IMPORTANT_PASS = rows 8-11 are TRUE
OPTIONAL_PASS = rows 12, 13 are TRUE

VERDICT:
  if not (ESSENTIAL_PASS and PITFALL_PASS):
    QUARANTINE
  elif IMPORTANT_PASS:
    PROMOTE
  else:
    PROMOTE-WITH-WARNING
```

## Self-application result on bootstrap

This repo's bootstrap commit (2026-04-26) ran the matrix and produced
15 PASS / 0 FAIL. The result is recorded in `CHANGELOG.md` under
[0.1.0]. Any future change must produce the same result before it
lands on `main`.

## Evolution rule

New rows enter the matrix only after a real publish-time failure.
Speculative rows are forbidden (143 Protocol Axiom 4: "No quick
fixes"). The procedure to add a row:

1. Document the failure in CHANGELOG.md under Fixed or Security.
2. Write the new row text in this file.
3. Add the mechanical check to `scripts/verify-self.sh`.
4. Bump the matrix version (this file is versioned with the repo).
5. Re-run the matrix against this repo. The new row must pass before
   it is canonical.

END_SELF_VERIFICATION_MATRIX
