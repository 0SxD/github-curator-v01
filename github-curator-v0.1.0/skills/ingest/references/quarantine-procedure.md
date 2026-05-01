# quarantine-procedure.md

The procedure for handling a packet whose SCORE step returned
QUARANTINE. Loaded on demand by `skills/ingest/SKILL.md` only at
the ROUTE step when the verdict is QUARANTINE.

## When QUARANTINE happens

The publish-readiness-rubric returns QUARANTINE when:
- Any Essential row (rows 1 to 7) returns FALSE.
- Any Pitfall row (rows 14, 15) returns TRUE.

The QUARANTINE verdict is a hard-block. The agent does not promote
the packet into the canonical `skills/` tree. The packet is moved
to a quarantine directory with a complete record of the failure.

## The system_directive_protocol quarantine rule

From system_directive_protocol Section 3 (the Cognitive Mandate):

> Quarantine protocol: Unverified research or uncertain findings
> are moved to a "barrier" for screening; they are never promoted
> to the knowledge base without quorum-based verification.

This procedure implements that rule for skill packets. A failed
packet does not get re-tried silently and does not get repaired
silently. It sits in quarantine until the human (the quorum) makes
a decision.

## Filesystem layout

```
quarantine/
  <ISO-timestamp>-<slug>/
    QUARANTINE.md          # the failure record
    packet/                # the original packet, preserved unmodified
    rubric-report.md       # the full rubric output
    interrogation.md       # the Socratic transcript from INTERROGATE
    inventory.json         # the catalogue from DETECT
```

The slug is derived from the packet's proposed `name` (or
sanitized filename if `name` is absent).

## QUARANTINE.md template

```markdown
# QUARANTINE: <slug>

Created: <ISO 8601>
Source: <original packet path or URL>
Operator: <agent identifier>

## Reason

<one-sentence summary of why the packet was quarantined>

## Failed rows

- Row <N> (Essential): <check description> returned FAIL.
  Reason: <specific reason from rubric report>.
  Repair: <one-line repair instruction>.

[... repeat for each failed Essential row]

- Row <N> (Pitfall): <check description> returned TRUE.
  Reason: <specific reason>.
  Repair: <one-line repair instruction>.

[... repeat for each Pitfall hit]

## Open questions to the human

- <question 1>
- <question 2>

## Decision options

1. Repair and retry: address the failed rows, re-run ingest.
2. Discard: the packet is not worth repairing; mark as discarded.
3. Override: the human accepts the failures and force-promotes
   (this option requires the human to write an override note in
   QUARANTINE.md and re-run ingest with `--override`).

## Audit trail

The packet is preserved unmodified at `packet/`. The full rubric
output is at `rubric-report.md`. The interrogation transcript is
at `interrogation.md`. The catalogue is at `inventory.json`.
```

## Override procedure

The override option exists because some failures are downgrades
the human accepts knowingly:

- A spec-foreign packet from a trusted upstream that intentionally
  uses a non-standard layout.
- A packet whose tier-1 IP scrub hit is actually false-positive
  (e.g., the regex matched a regex example, not a real secret).
- A packet whose Pitfall row triggered on a documented exception.

The override is NOT a way to silence the rubric. The override
requires:

1. The human writes a paragraph in `QUARANTINE.md` under a heading
   `## Override note` explaining why the failure is acceptable.
2. The override note is preserved in the audit trail forever. If
   the packet is later promoted, the note travels with it.
3. The override is logged in the parent repo's `CHANGELOG.md`
   under Security with the date and the reason.

## Repair-and-retry procedure

The most common path is repair. The procedure:

1. Read the `QUARANTINE.md` to understand the failures.
2. Edit the files in `packet/` to address each failure.
3. Run the ingest skill again, pointing at the modified packet.
4. The new run starts fresh: DETECT, NORMALIZE, INTERROGATE, SCORE.
5. If all failures are repaired, the new run returns PROMOTE and
   the packet moves out of quarantine into `skills/`.
6. The old quarantine directory remains in `quarantine/` as the
   audit record. It is not deleted.

## Discard procedure

The human discards a quarantine record by:

1. Adding a `## Discarded` heading to `QUARANTINE.md` with a date
   and reason.
2. Optionally moving the directory to `quarantine/discarded/`
   to keep the active quarantine list clean.
3. Discarded records are still preserved (do not delete).

## What quarantine does NOT do

1. Does not modify the packet under review. The packet is
   preserved exactly as ingested.
2. Does not auto-retry. The agent never retries quarantined
   packets without explicit human direction.
3. Does not surface the quarantine to anyone other than the human.
   The quarantine list is not posted to issue trackers, Slack,
   or external systems unless the human asks.

## Recovery after a tier-1 IP scrub hit

A tier-1 hit in a packet is sensitive. The procedure:

1. Move the packet to `quarantine/<timestamp>-<slug>/packet/`
   immediately on detection.
2. Do NOT include the matched content verbatim in QUARANTINE.md.
   Reference the location and pattern shape only.
3. If the packet was committed to git before the hit was detected,
   the parent repo's release procedure includes a yank protocol
   (see `skills/github-curator/references/release-procedure.md`).
4. The QUARANTINE.md notes the date of detection and the
   corresponding tier-1 pattern, but does not reproduce the
   matched text.

This is the same convention `gitleaks` and `trufflehog` use:
report the location, do not reproduce the secret.

END_QUARANTINE_PROCEDURE
