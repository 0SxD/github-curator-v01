---
name: github-curator
description: "Use this skill when curating, evolving, or publishing a GitHub repository that contains Anthropic Agent Skills, especially when the repo must remain self-consistent across edits. Triggers: any request to add a skill, edit a skill, bump a version, cut a release, audit the repo against the Agent Skills spec at agentskills.io, validate AGENTS.md and CLAUDE.md alignment, run the four-gate publish-readiness check on this repo itself, or onboard a new contributor to the curator pattern. The skill operates on its own repository as the first example: every action it instructs the agent to take, it has already taken on this repo. Do NOT use this skill for arbitrary GitHub tasks unrelated to skill curation, for non-Skills repos, or when the user has asked for code-level changes to a separate codebase."
license: Apache-2.0
compatibility: "Claude Code, Codex, Cursor, Aider, Gemini CLI, Antigravity, Claude.ai projects, NotebookLM (via packet zip), custom Gems, custom GPTs"
---

# github-curator

The meta-skill. This skill curates a repository of Agent Skills,
including the repository it lives in. It is the first and canonical
example of its own output.

## Why this skill exists

Skill repositories rot. Frontmatter drifts from the spec, AGENTS.md
falls out of sync with CLAUDE.md, version numbers get bumped without
changelog entries, packets ship without IP scrubs, and the four-gate
publish-readiness pattern becomes ceremonial rather than enforced. The
github-curator skill prevents drift by making the repo verify itself on
every change and by treating the repo as its own first audited artifact.

The Anthropic Agent Skills specification at
https://agentskills.io/specification (released 2025-12-18) is the
source of truth for skill structure. The AGENTS.md standard at
https://agents.md is the source of truth for repo-root agent
instructions. This skill enforces both, and rejects any composition
that deviates from them.

## When to use

Load this skill when the agent is asked to do any of the following on a
Skills-pattern repo:

1. Add a new skill folder.
2. Edit an existing skill's `SKILL.md` or reference docs.
3. Cut a SemVer release.
4. Produce a packet zip for distribution.
5. Audit the repo against the Agent Skills spec or the AGENTS.md standard.
6. Onboard a new contributor (humans or agents) to the curator pattern.
7. Resolve drift between `AGENTS.md` and `CLAUDE.md`.
8. Resolve drift between `registry.yaml` and the actual `skills/` tree.

Do not load this skill for unrelated repository tasks.

## The loop

This skill runs a four-step loop. Every step writes to the file system.
None of the steps mutate state without producing a verification record.

```
READ -> WORK -> WRITE -> STOP
```

The loop is taken verbatim from 143 Protocol Section 4 (Episodic Runtime
Loop). It is the same loop the `ingest` skill uses on external bundles.
The point of using the same loop in both places is that this repo is
auditable by `ingest` itself, the repo IS an external bundle to its own
ingest skill, and the recursion terminates correctly.

### READ (active sensing)

1. Read `AGENTS.md` at repo root.
2. Read `registry.yaml` at repo root.
3. Read each `skills/<n>/SKILL.md`. Confirm frontmatter is valid:
   - `name` field is present, lowercase-hyphenated, ≤64 chars, equals
     the parent directory name.
   - `description` field is present, between 1 and 1024 characters.
   - `license` and `compatibility` are optional but recommended.
4. Confirm `CLAUDE.md` content is the 3-line pointer to `AGENTS.md` (no
   divergent instructions).
5. Confirm `CHANGELOG.md` has an `[Unreleased]` section.

If any READ step fails, STOP and surface the failure. Do not proceed
to WORK.

### WORK (reasoning)

The agent may now plan the requested change. Planning produces a
write-list: every file path that will be modified, created, or deleted
in WRITE.

The write-list must be reviewable in plain text. No silent file
modifications.

### WRITE (artifact generation)

1. Apply the write-list.
2. Update `CHANGELOG.md` `[Unreleased]` with one entry per modified
   skill. Use Keep a Changelog categories: Added, Changed, Deprecated,
   Removed, Fixed, Security.
3. If a new skill was added, append a row to `registry.yaml` and a
   row to `skills.md` if the parent repo also maintains a tree index.
4. Run the verification matrix (next step).

### STOP (termination with verification)

Run `skills/github-curator/scripts/verify-self.sh`. The matrix output
must be PASS before the change is considered done. Any FAIL halts the
loop. The loop does not retry automatically; the agent surfaces the
failure to the human.

## The verification matrix

The matrix is a boolean-atomic check list. Each row returns TRUE or
FALSE. Each row has one importance tag (Essential / Important /
Optional / Pitfall) following the Rubrics-as-Rewards pattern (arXiv
2507.17746). The full matrix lives in
`references/self-verification-matrix.md`. Load it on demand, not at
skill-activation time.

Summary of the rows (full text in references):

| # | Tag | Check |
|---|---|---|
| 1 | Essential | `AGENTS.md` exists at repo root. |
| 2 | Essential | Each `skills/<n>/SKILL.md` frontmatter validates. |
| 3 | Essential | Skill `name` equals parent directory name. |
| 4 | Essential | `description` length is between 1 and 1024 chars. |
| 5 | Essential | `LICENSE` exists and is a recognized open license. |
| 6 | Essential | No em dashes (U+2014) and no en dashes (U+2013). |
| 7 | Essential | No tier-1 IP scrub hits (see publish-readiness-rubric). |
| 8 | Important | `CLAUDE.md` is the 3-line pointer to `AGENTS.md`. |
| 9 | Important | `CHANGELOG.md` `[Unreleased]` reflects the diff. |
| 10 | Important | `registry.yaml` rows match the `skills/` tree. |
| 11 | Important | Conventional Commits message proposed for the change. |
| 12 | Optional | Compatibility field lists at least 3 host environments. |
| 13 | Optional | Reference docs follow progressive-disclosure conventions. |
| 14 | Pitfall | No skill loads more than one body at activation time. |
| 15 | Pitfall | No reference doc is loaded eagerly in `SKILL.md`. |

Any row tagged Essential that returns FALSE blocks the WRITE. Important
rows that return FALSE produce a warning; the agent surfaces them but
proceeds at the human's explicit confirmation. Optional rows surface as
flags. Pitfall rows that return TRUE are bugs that must be repaired
before the change lands.

## Self-application: this skill on this repo

This skill was the first artifact this repo produced. The verification
matrix has been run against this repo. The result on bootstrap was 15
PASS / 0 FAIL. The output lives in
`scripts/verify-self.sh` and reproduces that result on every commit.

The dogfood is complete: this `SKILL.md` is the first row in the
`registry.yaml`, the AGENTS.md describes the build/test/release
commands that `scripts/` implements, the LICENSE matches the
frontmatter `license:` field, and CLAUDE.md is the 3-line pointer
described in `AGENTS.md`. The repo passes its own gate.

## Composition with other skills

The github-curator skill calls three siblings:

- `ingest` runs at WORK step when an external bundle is being absorbed
  into the repo.
- `publish-readiness-rubric` runs at STOP step as the boolean-atomic
  verification matrix.
- `session-dispatch` runs when the change is large enough to warrant a
  fresh chat session (the human spawns a new workstream).

A typical multi-skill turn loads `github-curator` plus exactly one of
the three siblings. Loading more than one sibling body at once is a
Pitfall row in the matrix.

## Versioning rules

The repo follows SemVer 2.0.0 (https://semver.org):

- PATCH: typo fixes in skill bodies, link fixes, reference doc clarifications.
- MINOR: new skill added, new reference doc, new packet, new compatibility entry.
- MAJOR: removed skill, moved file path that downstream packets reference,
  breaking change to a `SKILL.md` frontmatter (renamed `name`, removed
  required field), or a change in the four-gate semantics that downstream
  consumers depend on.

A release is cut by `make release VERSION=vX.Y.Z`, which produces a
git annotated tag, a `packets/github-curator-vX.Y.Z.zip`, and a
`checksums.txt` containing sha256 lines per asset. The zip filename
matches the directory name exactly, per the vercel-labs/agent-skills
convention.

## Distribution

The repo is "Use this template" enabled on GitHub. Forks get a clean
history. Each release attaches the zip to a GitHub Release at
`https://github.com/austinbgreen/github-curator/releases`. Drop the
zip's contents into NotebookLM, a Claude project, a custom Gem, or a
custom GPT, and the skills behave identically: the SKILL.md format is
host-neutral, only `name` plus `description` load on activation, and
the references load on demand.

## When this skill should fail closed

The Zero Assumption Mandate from 143 Protocol Section 3 is hard. If any
of the following is true, this skill stops and asks the human:

1. A `SKILL.md` `name` field does not match the parent directory.
2. A `description` is missing or longer than 1024 characters.
3. A skill is referenced in `registry.yaml` but its directory does not exist.
4. A skill directory exists but is missing from `registry.yaml`.
5. `CLAUDE.md` contains divergent instructions from `AGENTS.md`.
6. The IP scrub gate (tier-1) hits on any file in the repo.
7. The repo contains an em dash or en dash (rule 3 of pre_submit_gate).

The skill does not attempt to repair these silently. Each is a STOP
condition with a numbered question to the human.

## Reference docs

Loaded on demand, not at activation:

- `references/self-verification-matrix.md` the full 15-row matrix.
- `references/agent-skills-spec-conformance.md` the agentskills.io spec
  fields this repo enforces, with examples.
- `references/agents-md-conformance.md` the AGENTS.md standard fields
  this repo includes, with the discovery-order rules.
- `references/release-procedure.md` the SemVer + GitHub Releases
  procedure, including the `make release` script breakdown.
- `references/upstream-lineage.md` the list of repos and standards this
  bundle composes (vercel-labs/agent-skills, anthropics/skills,
  anthropics/claude-cookbooks, openai/openai-cookbook, agents.md,
  agentskills.io, semver.org, keepachangelog.com).

## Provenance

This SKILL.md was authored 2026-04-26 by Austin B. Green as the first
publishable composition of the 143 Protocol governance set onto the
open Agent Skills standard.

END_GITHUB_CURATOR_SKILL
