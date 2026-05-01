# AGENTS.md

Conforms to the AGENTS.md standard at https://agents.md (stewarded by the
Agentic AI Foundation under the Linux Foundation). Adopted by OpenAI Codex,
Cursor, Aider, Google Jules, Factory, Sourcegraph Amp, Block goose, Zed,
Warp, VS Code, Devin, JetBrains Junie, Gemini CLI, GitHub Copilot coding
agent, and others. Read this file before any other.

`CLAUDE.md` in this repo is a 3-line note pointing here. The two files are
the same instructions.

## Project overview

This repo is a self-evolving GitHub curator. Four skills compose into one
loop: ingest a packet, score it against a boolean-atomic publish-readiness
rubric, run a 9-cell Trinity Dialectic gate, and publish to GitHub via a
versioned release. The curator is its own first example: this repository
was produced by running the same skills on themselves, and it must continue
to pass its own gates on every change.

## Architecture

```
github-curator/
  AGENTS.md                    # this file (governance, root)
  CLAUDE.md                    # symlink-equivalent note pointing here
  README.md                    # short TOC, claude-cookbooks pattern
  LICENSE                      # Apache-2.0
  CHANGELOG.md                 # SemVer 2.0.0
  registry.yaml                # openai-cookbook + claude-cookbooks schema
  authors.yaml                 # openai-cookbook + claude-cookbooks schema
  skills/
    github-curator/            # the meta-skill (operates on this repo)
    ingest/                    # absorb packet, route through gates
    publish-readiness-rubric/  # boolean-atomic, criterion-tagged
    session-dispatch/          # template for spawning workstream sessions
  packets/                     # versioned bundles for distribution
```

Each skill folder is independently valid against the open Agent Skills
specification at https://agentskills.io/specification (released
2025-12-18). A skill is a folder containing `SKILL.md` with YAML
frontmatter (`name` lowercase-hyphenated and equal to the directory name,
`description` 1 to 1024 chars covering both what and when), plus optional
`references/`, `scripts/`, `assets/`. Only `name` plus `description` load
at startup, the body loads on activation, resources load on demand.

## Build, test, and release commands

This repo has no compiled artifacts. The "build" is a verification pass.

| Command | Purpose |
|---|---|
| `make verify` | Run all four gates against the repo itself. PASS required before any commit lands on `main`. |
| `make package VERSION=vX.Y.Z` | Produce `packets/github-curator-vX.Y.Z.zip` per vercel-labs convention (zip filename matches directory name). |
| `make release VERSION=vX.Y.Z` | Tag `vX.Y.Z` (annotated), push, attach the zip plus `checksums.txt` to a GitHub Release. |

If `make` is unavailable, the equivalent shell scripts live in
`skills/github-curator/scripts/`. They are POSIX sh, no dependencies
beyond `bash`, `git`, `zip`, `sha256sum`.

## Code style

- Markdown only in this repo. No source code, no tests. The "code" is the
  governance.
- No em dashes (U+2014) and no en dashes (U+2013). Pre-submit gate rule 3
  blocks them. Use commas, semicolons, colons, parentheses, or line
  breaks.
- Headings use ATX style (`#`, `##`, `###`). No setext.
- One blank line between paragraphs and headings. No trailing whitespace.
- Filenames are lowercase-hyphenated, matching the skill `name` field
  exactly. The Agent Skills spec requires this.

## Testing instructions

Before any commit:

1. Run `skills/github-curator/scripts/verify-self.sh`. The script invokes
   the four gates against this repo's own files. Any FAIL blocks.
2. The verification matrix is in `skills/github-curator/references/self-verification-matrix.md`.
3. If a new skill is added, its `SKILL.md` must validate against the spec
   (frontmatter present, `name` matches directory, `description` between 1
   and 1024 chars). Run `skills/github-curator/scripts/validate-skill.sh
   skills/<new-skill-name>`.

## Security considerations

- Run the IP scrub gate (`skills/publish-readiness-rubric/references/ip-scrub-tiers.md`)
  before every push. Tier-1 hits are unconditional blocks.
- Never commit API keys, tokens, or any string matching common
  vendor-prefix patterns (OpenRouter, Anthropic, OpenAI, etc.) or
  40+ hex chars adjacent to the word "key". The exact regex set
  is in `skills/publish-readiness-rubric/references/ip-scrub-tiers.md`
  and is loaded only when the rubric runs, so the patterns do not
  appear in this file.
- Strip EXIF data from any image before commit (`exiftool -all= file.png`).
- The `.claude/` directory is in `.gitignore` and must never be checked in.

## Pull request and commit conventions

- Commit messages follow Conventional Commits
  (https://www.conventionalcommits.org). Types in use: `feat`, `fix`,
  `docs`, `refactor`, `chore`, `release`. Breaking changes append `!` and
  add a `BREAKING CHANGE:` footer.
- Every PR must include the verification matrix output as a comment.
  Pre-submit gate rule 4 (PEL verdict) is recorded in the merge commit
  trailer: `PEL: 1` to merge.
- Versioning is SemVer 2.0.0 (https://semver.org). Bump rules:
  - PATCH: typos, link fixes, reference doc clarifications.
  - MINOR: new skill added, new reference document, new packet.
  - MAJOR: breaking change to a `SKILL.md` frontmatter, removed skill,
    or moved file path that downstream packets reference.

## Skill activation pattern

The Agent Skills spec is progressive disclosure. When this repo is
mounted as the working directory of a coding agent (Claude Code, Codex,
Cursor, Aider, Gemini CLI, Antigravity), the agent reads:

1. This file (`AGENTS.md`) at session start.
2. `skills/<skill-name>/SKILL.md` only when that skill's description
   matches the current task.
3. `skills/<skill-name>/references/<doc>.md` only when SKILL.md
   instructs the agent to load it for the specific subtask.

Loading more than one skill body at once is allowed but should be rare.
Loading reference docs eagerly defeats the disclosure pattern and will
fill context with material the agent does not need.

## License

Apache License 2.0. See `LICENSE`. The license applies to all skill
content, scripts, and reference documents in this repository. Forks must
preserve attribution per Apache 2.0 Section 4.

## Provenance

Bootstrapped 2026-04-26 by 0SxD as the publishable composition
of the system_directive_protocol governance set. Upstream lineage:

- Agent Skills specification: https://agentskills.io/specification
- AGENTS.md standard: https://agents.md
- Reference distribution layout: https://github.com/vercel-labs/agent-skills
- Reference cookbook layout: https://github.com/anthropics/claude-cookbooks
- Reference skill registry: https://github.com/anthropics/skills

END_AGENTS_MD
