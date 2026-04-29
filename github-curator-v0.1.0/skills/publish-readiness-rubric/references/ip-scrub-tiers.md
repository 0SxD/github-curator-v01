# ip-scrub-tiers.md

The IP scrub patterns the publish-readiness-rubric runs against any
artifact under review. Loaded on demand by
`skills/publish-readiness-rubric/SKILL.md` only when row 7 of the
verification matrix executes.

This file is the publishable, host-neutral version of the IP scrub.
The upstream version with project-specific exclusions (named
employers, NDA flags, personal identifiers specific to one author)
lives in private governance and is composed in only at runtime by
each individual using this skill, never checked into the public repo.

## Three tiers

The scrub uses three severity tiers from the upstream pattern:

| Tier | Behavior on hit |
|---|---|
| 1 | HARD BLOCK. The artifact does not ship until the hit is removed. |
| 2 | CONDITIONAL BLOCK. Requires the human's per-artifact clearance before ship. |
| 3 | PASSIVE FLAG. Ships, but surfaces in the rubric report for human awareness. |

## Tier 1 patterns (publish-neutral defaults)

These are the patterns every fork should keep. Forks may add to this
list; they should not remove from it without justification.

### Credentials and secrets
- `sk-[a-z]+-v[0-9]-[a-zA-Z0-9]{20,}` (vendor API key prefix family).
- `[a-fA-F0-9]{40,}` adjacent to words `key`, `token`, `secret`,
  `password`, `bearer`.
- AWS access key pattern `AKIA[0-9A-Z]{16}`.
- GitHub token pattern `ghp_[0-9A-Za-z]{36}` and `gho_`, `ghu_`,
  `ghs_`, `ghr_` variants.
- Private key headers `-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----`.
- JSON Web Token shape `eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.`.
- Database connection string fragments `://[^/]+:[^@]+@` (user:pass).

### Machine and path identifiers
- Windows hostname pattern `DESKTOP-[A-Z0-9]{7}`.
- Windows user paths `C:\\Users\\[^\\]+\\` (strip even if user is
  generic; paths leak environment shape).
- Unix home-directory paths `/home/[^/]+/\.` containing dotfile
  names of dev tools (`.aws`, `.ssh`, `.kube`, `.docker`).
- Git config fragments containing email addresses inside
  `.git/config` files.

### Personally identifiable information
- US Social Security Number pattern `\b\d{3}-\d{2}-\d{4}\b`.
- Credit card number patterns (Luhn-checkable digit groups).
- Driver's license patterns (state-specific, conservative regex set).
- Phone number fragments tied to address inference (older numbers
  that pre-date a publicly listed move).

### EXIF in images
- Run `exiftool -all=` on every image in the artifact tree before
  ship. EXIF can carry GPS coordinates, camera serial numbers, and
  software fingerprints.

## Tier 2 patterns (conditional, require per-artifact clearance)

Tier 2 patterns hit on names, places, or affiliations whose
publication is acceptable in some artifacts but not others.
Each tier-2 hit produces a question to the human.

Examples (your tier-2 set is your own; these are illustrative):

- Employer names under active NDA. Hit produces: "Confirm that
  mentioning <employer> is permitted in this destination?"
- Old physical addresses that pre-date a move. Hit produces:
  "Confirm that this old address is acceptable in this artifact?"
- Personal first name vs preferred handle. Hit produces:
  "Use legal name or preferred handle in this destination?"

The skill never resolves tier-2 hits silently. Each one is a
load-bearing question.

## Tier 3 patterns (passive, flag for awareness)

Tier 3 surfaces patterns that are probably fine but worth
mentioning. The rubric report includes them under a separate
"flags" heading. They do not block.

Examples:

- Project codenames that have been publicly mentioned but might
  warrant a pseudonym in a specific destination.
- Counterparty names in completed deals (legal but possibly
  awkward depending on the artifact tone).

## Procedure

Given an artifact under review:

```
for each tier-1 pattern:
  if pattern matches anywhere in the artifact tree:
    record HARD_BLOCK with file path and match position

for each tier-2 pattern:
  if pattern matches:
    if human has cleared this match in current session:
      record OK_CLEARED
    else:
      record CONDITIONAL_BLOCK with question

for each tier-3 pattern:
  if pattern matches:
    record FLAG

run exiftool on each image:
  if EXIF data present:
    strip EXIF, record EXIF_STRIPPED
```

## Output format

```
IP_SCRUB_REPORT
artifact: <path or identifier>
date: <ISO 8601>

Tier 1 (HARD_BLOCK):
  - (none)
  OR
  - [pattern]: matched at <file>:<line>:<col>, context: "<fragment>"

Tier 2 (CONDITIONAL_BLOCK):
  - (none)
  OR
  - [pattern]: matched at <file>:<line>, requires clearance:
    "<question to human>"

Tier 3 (FLAG):
  - (none)
  OR
  - [pattern]: matched at <file>:<line>, flagged for awareness

EXIF: <n images scanned>, <m stripped>

verdict: PASS / CONDITIONAL_BLOCK / HARD_BLOCK
```

## Forks add patterns; forks do not subtract

The Apache 2.0 license permits modification, but the scrub patterns
are governance, not code. A fork that publishes claiming to be an
agent skills repo while removing tier-1 patterns from the scrub is
still legally compliant but materially weaker. The verification
matrix does not enforce tier-1 set inclusion across forks; that is
each maintainer's responsibility.

The recommended posture is to fork this file, add patterns specific
to your context, and never remove patterns. Patterns are append-only.

## How this file avoids self-triggering

The publish-readiness-rubric runs row 7 against every file in the
repo on every change. This file (`ip-scrub-tiers.md`) is itself a
file in the repo. To avoid the scrubber triggering on its own
documentation:

1. Patterns are written as regex strings inside backticks, not as
   raw matchable instances. Example: `` `sk-[a-z]+-v[0-9]-...` `` is
   safe because the regex itself does not match the regex.
2. Concrete example values are wildcarded. We do not write a real
   API key as an example; we write the regex shape.
3. Forty-character hex strings adjacent to "key" are also wildcarded
   in this file's prose.

This is the same convention used by tools like `gitleaks` and
`trufflehog`: pattern documentation is structurally distinct from
pattern matches.

END_IP_SCRUB_TIERS
