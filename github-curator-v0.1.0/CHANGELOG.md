# Changelog

All notable changes to this repo are documented here. Format follows
Keep a Changelog (https://keepachangelog.com/en/1.1.0/) and SemVer
2.0.0 (https://semver.org).

## [Unreleased]

## [0.1.0] - 2026-04-26

### Added
- Initial bundle. Four skills, each conformant to the Agent Skills
  specification at https://agentskills.io/specification:
  - `skills/github-curator/` the meta-skill that operates on this repo
  - `skills/ingest/` absorb a project bundle and route through the gates
  - `skills/publish-readiness-rubric/` boolean-atomic, criterion-tagged
  - `skills/session-dispatch/` template for spawning workstream sessions
- `AGENTS.md` at root following the AGENTS.md standard.
- `CLAUDE.md` as a 3-line note pointing to AGENTS.md (Vercel pattern).
- `registry.yaml` and `authors.yaml` mirroring the
  `anthropics/claude-cookbooks` and `openai/openai-cookbook` schema.
- Apache-2.0 LICENSE.
- This changelog.

### Provenance
- 143 Protocol governance set authored by Austin B. Green is the
  upstream source for the four-gate pattern (zero assumption mandate,
  strict source fidelity, quarantine, Trinity Dialectic).
- Reference implementations consulted during composition:
  - https://github.com/anthropics/skills
  - https://github.com/vercel-labs/agent-skills
  - https://github.com/anthropics/claude-cookbooks
  - https://github.com/openai/openai-cookbook
  - https://agents.md
  - https://agentskills.io/specification

[Unreleased]: https://github.com/austinbgreen/github-curator/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/austinbgreen/github-curator/releases/tag/v0.1.0
