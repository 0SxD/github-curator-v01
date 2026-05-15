# github-curator-v01

A monorepo for versioned releases of a GitHub curation skill bundle. The bundle implements a pipeline that ingests a project bundle, scores it with a boolean-atomic publish-readiness rubric, runs a 9-cell Trinity Dialectic gate, and publishes to GitHub via a versioned release. Skills are written as host-neutral SKILL.md files that work across multiple agent platforms: Claude Code, NotebookLM, Claude Projects, custom Gems, and custom GPTs. Skills conform to the Agent Skills specification (https://agentskills.io/specification).

## Repository structure

Each release lives in a subdirectory named `github-curator-v<major>.<minor>.<patch>/`. The root level contains only:

- `README.md` : this file  
- `.gitignore`  
- `LICENSE-PENDING.md` : placeholder for a future root-level license  
- `github-curator-v0.1.0/` : the current release (and the only release as of this writing)

## Latest release

**[github-curator-v0.1.0](./github-curator-v0.1.0/)** is the latest and only release.  
It contains a full agent-skills bundle, including four composable skills, agent instructions, a changelog, and supporting reference documents.

## What is in v0.1.0

- Four SKILL.md files, each an independent agent skill:
  - `github-curator` : meta-skill that operates on this repository itself  
  - `ingest` : absorbs a project bundle and routes it through the gates  
  - `publish-readiness-rubric` : scores bundles using a boolean-atomic, criterion-tagged rubric  
  - `session-dispatch` : templates for spawning new workstream sessions  
- `AGENTS.md` : agent instructions and build commands  
- `CLAUDE.md` : Claude-specific session directives  
- `CHANGELOG.md` : version history  
- `registry.yaml` : skill registry manifest  
- `authors.yaml` : authorship record  
- `LICENSE` : Apache 2.0 (see below)  
- Reference docs and verification scripts under each skill's `references/` and `scripts/` directories

## Status

R&D / Experimental. Maintained by Sage / 0SxD as part of an ongoing prompt-engineering and agent-skills research portfolio.

## License

The v0.1.0 release is licensed under Apache License 2.0 (see [github-curator-v0.1.0/LICENSE](./github-curator-v0.1.0/LICENSE)).  
The root of this repository (`github-curator-v01`) is unlicensed pending a licensing decision; see [LICENSE-PENDING.md](./LICENSE-PENDING.md).

## Lineage

This repo composes existing standards rather than inventing new ones:

- Agent Skills spec: https://agentskills.io/specification
- AGENTS.md standard: https://agents.md
- Distribution layout: https://github.com/vercel-labs/agent-skills
- Cookbook layout: https://github.com/anthropics/claude-cookbooks
- Reference skill registry: https://github.com/anthropics/skills

The four-gate publish-readiness pattern is grounded in the system_directive_protocol governance set authored by 0SxD.

## Notes

This repo is part of an active R&D portfolio. Content may move, change, or be withdrawn.
