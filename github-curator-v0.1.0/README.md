# github-curator

A self-evolving GitHub curator skill bundle with Trinity Dialectic gate.

## Status

R&D / Experimental. Maintained by Sage / 0SxD as part of an ongoing prompt-engineering and agent-skills research portfolio.

## What this is

Four composable skills that ingest a project bundle, score it against a boolean-atomic publish-readiness rubric, run a 9-cell Trinity Dialectic gate, and publish to GitHub via a versioned release. The curator was produced by running these skills on themselves; this repository is the first example of its own output. The data curation pattern is host-neutral: the same SKILL.md files work in Claude Code, NotebookLM, Claude Projects, custom Gems, and custom GPTs.

For agent instructions, build commands, and conventions, read `AGENTS.md` first. For the Agent Skills specification this repo conforms to, see https://agentskills.io/specification.

## Layout

- `skills/github-curator/` - meta-skill that operates on this repo
- `skills/ingest/` - absorb a project bundle and route it through the gates
- `skills/publish-readiness-rubric/` - boolean-atomic, criterion-tagged scoring
- `skills/session-dispatch/` - template for spawning new workstream sessions
- `AGENTS.md` - agent instructions and build commands
- `CLAUDE.md` - Claude-specific session directives
- `CHANGELOG.md` - version history
- `registry.yaml` - skill registry manifest
- `authors.yaml` - authorship record

## License

Apache License 2.0. See LICENSE.
Author: Sage / 0SxD

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
