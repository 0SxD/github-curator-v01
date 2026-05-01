# upstream-lineage.md

This bundle composes existing standards rather than inventing new
ones. The full lineage is documented here so any downstream consumer
can audit each layer.

## Specifications

| Standard | URL | Role in this bundle |
|---|---|---|
| Agent Skills specification | https://agentskills.io/specification | Defines the SKILL.md frontmatter and folder layout that every skill in this repo conforms to. Released 2025-12-18 by Anthropic under an open license. |
| AGENTS.md standard | https://agents.md | Defines the repo-root agent-instructions file. Stewarded by the Agentic AI Foundation under the Linux Foundation as of 2026. |
| SemVer 2.0.0 | https://semver.org | Defines the versioning scheme used by this repo and by all release artifacts. |
| Keep a Changelog 1.1.0 | https://keepachangelog.com/en/1.1.0/ | Defines the CHANGELOG.md format. |
| Conventional Commits | https://www.conventionalcommits.org | Defines the commit message format enforced by verification matrix row 11. |
| SPDX License List | https://spdx.org/licenses/ | Source of valid `license:` field values in skill frontmatter. |

## Reference implementations consulted during composition

| Repo | URL | What this bundle borrowed |
|---|---|---|
| anthropics/skills | https://github.com/anthropics/skills | Canonical skill registry topology. The `skills/<name>/SKILL.md` plus optional `references/`, `scripts/`, `assets/` structure. ~117k stars at April 2026. |
| vercel-labs/agent-skills | https://github.com/vercel-labs/agent-skills | Distribution convention: zip filename equals directory name. `npx skills add` installation pattern. |
| anthropics/claude-cookbooks | https://github.com/anthropics/claude-cookbooks | `registry.yaml` + `authors.yaml` sidecar pattern. Short README with TOC. |
| openai/openai-cookbook | https://github.com/openai/openai-cookbook | Same `registry.yaml` + `authors.yaml` schema (Anthropic adopted it from OpenAI). Short README pointing to a rendered docs site. |
| vercel/next.js | https://github.com/vercel/next.js | The CLAUDE.md as 3-line pointer to AGENTS.md pattern. |
| danielmiessler/Fabric | https://github.com/danielmiessler/Fabric | Per-pattern folder plus central JSON description files registry pattern (informed but not copied for this repo). |

## Research papers underpinning the rubric pattern

| Paper | URL | Concept used |
|---|---|---|
| Rubrics as Rewards (Viswanathan et al. 2025) | https://arxiv.org/abs/2507.17746 | Criterion-importance taxonomy: Essential / Important / Optional / Pitfall. |
| OpenRubrics | https://arxiv.org/abs/2510.07743 | Hard-rules-vs-principles split. |
| Adaptive Precise Boolean Rubrics (Google 2025) | https://arxiv.org/abs/2503.23339 | Boolean conversion of Likert criteria preserves ICC at lower cost. |
| Checklists are better than reward models (Apple/CMU 2025) | https://arxiv.org/abs/2507.18624 | Boolean checklists outperform scalar reward models. |

## Anthropic governance referenced

The four-gate publish-readiness pattern (IP scrub, date consistency,
no em dashes, PEL verdict) is the pre_submit_gate v1.0 authored by
0SxD within the system_directive_protocol governance set. The 9-cell
Trinity Dialectic is from system_directive_protocol Section 5. The Zero
Assumption Mandate is from Section 3. The READ-WORK-WRITE-STOP loop
is from Section 4. The Socratic Method (max 3 load-bearing
questions per turn) is from the interaction rules.

These governance documents are upstream of this bundle. They are
not copied into the repo verbatim because they contain
project-specific material (resume canon, IP exclusions specific to
0SxD's professional history, named-employer NDA flags).
This repo extracts only the publishable, host-neutral patterns and
re-grounds them in the open Agent Skills specification.

## What this repo did NOT compose from

For transparency, the following adjacent projects were considered
during research and explicitly NOT composed into this bundle:

| Project | URL | Reason for non-composition |
|---|---|---|
| EveryInc/compound-engineering-plugin | https://github.com/EveryInc/compound-engineering-plugin | Software-engineering-shaped. The closest existing review-loop, but coupled to coding workflows. |
| garrytan/gstack | https://github.com/garrytan/gstack | Coding-shaped. The closest existing forcing-question pattern, but assumes a CEO/eng/design pipeline. |
| justSteve/OpenBrain | https://github.com/justSteve/OpenBrain | Closest namespace match for "owned data plus skillpack" framing. Different governance assumptions. |
| alirezarezvani/claude-skills (llm-wiki) | https://github.com/alirezarezvani/claude-skills | Wiki-ingest pattern. Adjacent but ingests into a vault rather than emitting publishable SKILL.md. |
| Promptfoo, Google ADK, Autorubric | (various) | Eval engines, not Agent Skills. The rubric pattern in this repo could be implemented atop any of them but is engine-agnostic. |

## Attribution requirements

Per Apache 2.0 Section 4(c), forks must retain copyright, patent,
trademark, and attribution notices. Practically:

1. Keep `LICENSE` unmodified except for adding the fork owner's
   copyright line in the Appendix. Do not replace the original
   copyright.
2. Keep this `upstream-lineage.md` file or its equivalent. Forks
   may add their own lineage entries; they may not remove the
   original ones.
3. The CHANGELOG `[0.1.0]` entry's "Provenance" section should be
   preserved in any fork that retains the original four skills.

If a fork removes one of the four skills, the corresponding
provenance entry can be removed. If a fork adds new skills, new
provenance entries should be added in the same format.

END_UPSTREAM_LINEAGE
