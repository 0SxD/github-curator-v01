> **Status: Evaluation window (private under 0SxD).** This repository is staged
> for evaluation review. License terms in LICENSE govern; contents may move,
> change, or be withdrawn. See LICENSE before any use.

# github-curator

A self-evolving GitHub curator. Four composable skills that ingest a
project bundle, score it against a boolean-atomic publish-readiness
rubric, run a 9-cell Trinity Dialectic gate, and publish to GitHub via a
versioned release. The curator was produced by running these skills on
themselves; this repository is the first example of its own output.

For agent instructions, build commands, and conventions, read `AGENTS.md`
first. For the Agent Skills specification this repo conforms to, see
https://agentskills.io/specification.

## Contents

- [`skills/github-curator/`](skills/github-curator/SKILL.md) the meta-skill that operates on this repo
- [`skills/ingest/`](skills/ingest/SKILL.md) absorb a project bundle and route it through the gates
- [`skills/publish-readiness-rubric/`](skills/publish-readiness-rubric/SKILL.md) boolean-atomic, criterion-tagged scoring
- [`skills/session-dispatch/`](skills/session-dispatch/SKILL.md) template for spawning new workstream sessions
- [`packets/`](packets/) versioned release bundles (one zip per release)

## Quick start (3 minutes)

This repo is "Use this template" enabled on GitHub. The fastest path:

1. Click "Use this template" on GitHub. Name your fork.
2. Drop your project files into a working directory next to this repo.
3. In Claude Code, Codex, Cursor, Aider, or any AGENTS.md-aware agent,
   open the working directory. The agent reads `AGENTS.md` automatically.
4. Ask the agent: "Run the ingest skill on the working directory."

The agent will load `skills/ingest/SKILL.md`, walk through the gates,
and produce a publish-ready packet under `packets/`. No further setup.

## Use without a coding agent

The same four skills are portable to NotebookLM, Claude Projects, custom
Gems, and custom GPTs. Each release attaches a zip
(`github-curator-vX.Y.Z.zip`) to a GitHub Release. Drop the zip's
contents into the project context of any of those tools and the skills
behave identically because the SKILL.md format is host-neutral.

## License

Apache License 2.0. See [LICENSE](LICENSE).

## Lineage

This repo composes existing standards rather than inventing new ones:

- Agent Skills spec: https://agentskills.io/specification
- AGENTS.md standard: https://agents.md
- Distribution layout: https://github.com/vercel-labs/agent-skills
- Cookbook layout: https://github.com/anthropics/claude-cookbooks
- Reference skill registry: https://github.com/anthropics/skills

The four-gate publish-readiness pattern is grounded in the system_directive_protocol
governance set authored by 0SxD.
