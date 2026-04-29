# agents-md-conformance.md

This repo's `AGENTS.md` conforms to the AGENTS.md standard at
https://agents.md, stewarded by the Agentic AI Foundation under the
Linux Foundation as of 2026.

## What the standard defines

AGENTS.md is a Markdown file at the root of a repository (or any
subdirectory) that supplies agent-readable instructions: project
overview, build commands, code style, testing, security, and PR
conventions.

The standard has no required fields. From agents.md verbatim:
"AGENTS.md is just standard Markdown. Use any headings you like; the
agent simply parses the text you provide."

## Discovery rules (from OpenAI Codex spec)

A coding agent that supports AGENTS.md walks the file system in this
order:

1. Global: `~/.codex/AGENTS.md` (or equivalent per-host global).
2. Repo root: `<repo>/AGENTS.md`.
3. Working directory: `<cwd>/AGENTS.md` if different from repo root.

In each directory, the agent prefers in this order:
1. `AGENTS.override.md`
2. `AGENTS.md`
3. Fallback names (`CLAUDE.md`, `CONTRIBUTING.md` for partial coverage).

Closest file to the file being edited wins. Explicit user prompts in
chat override everything.

Nested AGENTS.md files are allowed. The OpenAI repo has 88 of them
across subdirectories per the agents.md homepage.

## Recommended sections (this repo's AGENTS.md follows these)

| Section | This repo's content |
|---|---|
| Project overview | Self-evolving GitHub curator, four-skill composition, dogfood note. |
| Architecture | Folder tree of repo with one-line per file. |
| Build, test, release commands | `make verify`, `make package`, `make release`. |
| Code style | Markdown only, no em dashes or en dashes, ATX headings, lowercase-hyphenated filenames. |
| Testing instructions | `verify-self.sh`, validation matrix, per-new-skill validator. |
| Security considerations | IP scrub, no API keys, EXIF strip, `.claude/` ignored. |
| PR and commit conventions | Conventional Commits, PEL trailer, SemVer. |
| Skill activation pattern | Progressive disclosure rules from agentskills.io. |
| License | Apache-2.0 reference. |
| Provenance | Authorship, upstream lineage. |

## CLAUDE.md handling

CLAUDE.md is Anthropic's parallel format (memory hierarchy at
code.claude.com/docs/en/overview). The cross-vendor practice is to
make CLAUDE.md a symlink (or 3-line pointer) to AGENTS.md. From
https://github.com/vercel/next.js/blob/canary/AGENTS.md verbatim:
"CLAUDE.md is a symlink to AGENTS.md. They are the same file."

This repo uses the 3-line pointer approach (not a real symlink)
because:
1. Real symlinks do not survive GitHub's "Use this template" feature
   reliably across all platforms.
2. Forks on Windows file systems often break symlinks on clone.
3. The 3-line note is portable, explicit, and self-documenting.

The verification matrix (row 8) confirms CLAUDE.md is the 3-line
pointer or a real symlink.

## Adopters of AGENTS.md (April 2026 snapshot)

From agents.md homepage, the adopting projects include: OpenAI Codex,
Google Jules, Factory, Aider, Block goose, opencode, Zed, Warp, VS
Code, Devin (Cognition), UiPath, JetBrains Junie, Sourcegraph Amp,
Cursor, RooCode, Gemini CLI, Kilo Code, Phoenix, Semgrep, GitHub
Copilot coding agent, Ona, Windsurf, Augment Code.

The standard claims usage in over 60,000 open-source projects.

## Cross-host fallbacks

Some hosts honor non-AGENTS.md formats:

| Host | Primary | Fallbacks |
|---|---|---|
| Claude Code | `CLAUDE.md` | `AGENTS.md` |
| Codex | `AGENTS.md` | `~/.codex/AGENTS.md` global |
| Cursor | `.cursor/rules/*.mdc` | `AGENTS.md`, `.cursorrules` (deprecated) |
| Aider | `.aider.conf.yml read: AGENTS.md` | `CONVENTIONS.md` |
| Gemini CLI | `AGENTS.md` | (none) |
| GitHub Copilot | `AGENTS.md` | (none) |

This repo includes:
- `AGENTS.md` at root (primary).
- `CLAUDE.md` 3-line pointer (Claude Code).
- (Forks may add `.cursor/rules/` or `.aider.conf.yml` as needed.)

## What this repo's AGENTS.md does NOT do

1. Does not duplicate the SKILL.md content. AGENTS.md is for
   repo-root governance; SKILL.md is for per-skill activation.
2. Does not contain build instructions for compiled artifacts. There
   are none.
3. Does not include user secrets, API keys, or any IP-restricted
   material. Verification matrix row 7 enforces this.
4. Does not declare AGENTS.override.md. The standard reserves that
   filename for human-authored overrides during incident response;
   regular development uses AGENTS.md only.

## Update procedure

When AGENTS.md changes:

1. The change must trace to a documented need (a workstream, a
   process change, a new contributor onboarding gap).
2. CHANGELOG.md gains an entry under Changed.
3. The verification matrix runs against the new AGENTS.md (rows 1, 9
   are the relevant rows).
4. If any skill SKILL.md references AGENTS.md sections explicitly,
   confirm the section anchors still resolve.

END_AGENTS_MD_CONFORMANCE
