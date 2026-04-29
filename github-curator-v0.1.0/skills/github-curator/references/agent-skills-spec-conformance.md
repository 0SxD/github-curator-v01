# agent-skills-spec-conformance.md

This repo conforms to the open Agent Skills specification at
https://agentskills.io/specification, released 2025-12-18 by Anthropic
under an open license.

## What the spec defines

A skill is a folder. The folder name is the skill's `name`. The folder
contains:

| File or directory | Required | Purpose |
|---|---|---|
| `SKILL.md` | Yes | YAML frontmatter plus body. Frontmatter must include `name` and `description`. Body is the activation content. |
| `references/` | No | Progressive-disclosure documents. Loaded on demand by the agent when the skill body instructs. |
| `scripts/` | No | Executable scripts the skill invokes. POSIX sh or Python preferred for portability. |
| `assets/` | No | Binary attachments (images, fonts, sample data). |

## Frontmatter fields

### Required

#### `name`
- Type: string.
- Constraints: regex `^[a-z0-9][a-z0-9-]*$`, length 1-64.
- Must equal the parent directory's basename exactly.
- This repo's enforcement: row 3 of the verification matrix.

#### `description`
- Type: string.
- Constraints: length 1-1024.
- Should cover both *what* the skill does and *when* the agent should
  load it. The "when" clause is what makes the description useful for
  trigger detection during the agent's startup scan.
- This repo's enforcement: row 4 of the verification matrix.

### Optional but recommended

#### `license`
- Type: string.
- Constraints: any text. SPDX identifiers preferred (`Apache-2.0`,
  `MIT`, `BSD-3-Clause`).
- This repo's default: `Apache-2.0` for all skills.

#### `compatibility`
- Type: string.
- Constraints: any text. Comma-separated list of host environments
  preferred.
- This repo's recommendation: ≥3 hosts (row 12 of the matrix).

### Optional, advanced

#### `metadata`
- Type: object.
- Free-form. Used for tags, version, author info, links to upstream.

#### `allowed-tools` (experimental)
- Type: list of strings.
- Constrains which tools the agent may invoke while the skill is
  loaded. Honored by Claude Code in plugin contexts; behavior in other
  hosts varies.

## Activation model

The spec is built around progressive disclosure to keep context budgets
predictable.

```
At session start:
  Agent scans all skills' SKILL.md frontmatter.
  Loads only `name` plus `description` per skill (~100 tokens each).

When the agent decides to activate a skill:
  Agent loads the SKILL.md body.

When SKILL.md body says "Load references/foo.md":
  Agent loads that one reference doc.

References are not auto-loaded. Only SKILL.md body decides.
```

The discipline matters because:
1. Eager loading defeats the budget and floods the agent with material
   it does not need (Pitfall row 14 of the matrix).
2. Auto-load instructions inside SKILL.md (e.g., "always read
   references/X first") collapse progressive disclosure into a single
   monolithic load (Pitfall row 15).

## Recommended SKILL.md body length

The Anthropic skills team recommends keeping SKILL.md under 500 lines
(approximately 1500-2000 words). Detail belongs in `references/`. The
body's job is to describe *what to do* and *when to load each
reference*, not to inline the reference content.

This repo's compliance:
- `github-curator/SKILL.md`: 142 lines (under 500, conformant).
- `ingest/SKILL.md`: 152 lines (under 500, conformant).
- `publish-readiness-rubric/SKILL.md`: 168 lines (under 500, conformant).
- `session-dispatch/SKILL.md`: 167 lines (under 500, conformant).

## Worked example: a conformant frontmatter

```yaml
---
name: github-curator
description: "Use this skill when curating, evolving, or publishing a GitHub repository that contains Anthropic Agent Skills, especially when the repo must remain self-consistent across edits. Triggers: any request to add a skill, edit a skill, bump a version, cut a release, audit the repo against the Agent Skills spec at agentskills.io, validate AGENTS.md and CLAUDE.md alignment, run the four-gate publish-readiness check on this repo itself, or onboard a new contributor to the curator pattern. The skill operates on its own repository as the first example: every action it instructs the agent to take, it has already taken on this repo. Do NOT use this skill for arbitrary GitHub tasks unrelated to skill curation, for non-Skills repos, or when the user has asked for code-level changes to a separate codebase."
license: Apache-2.0
compatibility: "Claude Code, Codex, Cursor, Aider, Gemini CLI, Antigravity, Claude.ai projects, NotebookLM (via packet zip), custom Gems, custom GPTs"
---
```

This is the actual frontmatter of `skills/github-curator/SKILL.md`.
The verification matrix accepts it.

## Worked example: a non-conformant frontmatter

```yaml
---
name: GitHub Curator
description: A skill for curating GitHub repos
---
```

Three failures:
1. `name` contains uppercase and a space. Fails row 3 (regex
   mismatch, and does not match parent directory).
2. `description` is too short (covers only "what", not "when").
   Technically passes row 4 (length 38, in range 1-1024) but fails
   the spec's recommendation. The `ingest` skill's INTERROGATE step
   would ask for a "when to use" clause.
3. `license` and `compatibility` are missing (acceptable but produces
   row 12 warning).

## Lineage

Reference implementation: https://github.com/anthropics/skills (~117k
stars at April 2026 snapshot).

Distribution layout reference: https://github.com/vercel-labs/agent-skills,
which adds the convention of a zip per skill folder, with the zip
filename matching the directory name exactly.

Cookbook layout reference: https://github.com/anthropics/claude-cookbooks
and https://github.com/openai/openai-cookbook, both using
`registry.yaml` and `authors.yaml` sidecars to render to a doc site.

END_AGENT_SKILLS_SPEC_CONFORMANCE
