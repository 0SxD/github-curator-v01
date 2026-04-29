# host-quirks.md

Per-host idiosyncrasies that the session-dispatch skill must
account for when emitting a bootstrap. Loaded on demand by
`skills/session-dispatch/SKILL.md`.

The host-neutrality goal is real but imperfect. The same AGENTS.md
text behaves slightly differently across hosts. This reference
lists the documented quirks per host so the dispatcher emits the
right shape.

## Claude Code (CLI in repo working directory)

- Reads `CLAUDE.md` first, then falls back to `AGENTS.md` if
  `CLAUDE.md` is the 3-line pointer.
- Recursive `@path/to/file` imports work up to depth 5.
- Plugin contexts honor `allowed-tools` in skill frontmatter.
- Working directory is the repo root by default; the agent walks
  upward to find AGENTS.md.

Bootstrap shape: the human paste the AGENTS.md content as the
opening message, OR opens the repo and lets Claude Code discover
it automatically.

## Codex (OpenAI's coding agent)

- Walks `~/.codex/AGENTS.md` (global) then project root.
- `AGENTS.override.md` takes precedence over `AGENTS.md`.
- Closest file to the file being edited wins.
- Nested AGENTS.md files at subdirectory level are honored.

Bootstrap shape: same as Claude Code. The agent discovers the
file from the working directory.

## Cursor

- Primary format is `.cursor/rules/*.mdc` with YAML frontmatter
  fields `description`, `globs`, `alwaysApply`.
- The legacy `.cursorrules` is deprecated.
- `AGENTS.md` works as a "simple alternative" per cursor.com docs.

Bootstrap shape: emit AGENTS.md at the repo root. Cursor reads it.

## Aider

- Primary mechanism: `/read CONVENTIONS.md` slash command.
- Auto-load via `.aider.conf.yml` with `read: AGENTS.md`.

Bootstrap shape: emit `.aider.conf.yml` containing
`read: AGENTS.md`. The user runs Aider in the repo directory.

## Gemini CLI

- Reads `AGENTS.md` at repo root.
- No fallback to other names.

Bootstrap shape: emit AGENTS.md at the repo root. No additional
configuration files needed.

## Antigravity

- Reads `AGENTS.md` and per-skill `SKILL.md` per the open Agent
  Skills spec.
- Works with the same skill format as Claude Code.

Bootstrap shape: emit AGENTS.md and the skill folders. The agent
discovers both.

## Claude.ai project (web)

- The project has an "Instructions" field that maps to AGENTS.md
  semantics.
- Files attached to the project are read on every turn.
- The 3-line CLAUDE.md pointer pattern is unnecessary in this
  host because the project Instructions field is direct.

Bootstrap shape: paste the AGENTS.md content (or HANDOFF.md) into
the Instructions field. Attach the canon files as project files.

## NotebookLM (web, source-bundle ingestion)

- The host has no concept of an "agent" in the AGENTS.md sense.
  It interprets the AGENTS.md text as a source like any other.
- Source bundles are uploaded as files: PDF, txt, md, web pages,
  YouTube transcripts, audio.
- The "Customize" field on a notebook is the closest analogue to
  AGENTS.md, with much smaller character budget (typically 5000
  chars).

Bootstrap shape:
1. Emit a slim `AGENTS.md` (≤5000 chars) for the Customize field.
2. Attach the canon files as sources.
3. Attach the packet zip's contents (unpacked into individual
   files) as additional sources, since NotebookLM does not unpack
   zips automatically.

The slim AGENTS.md is the same content as the full one but stripped
to the project overview, the workstream scope, the canon list, and
the stop conditions. Detail moves into the attached sources.

## Custom Gem (Google's chat customization)

- The host has a "Custom instructions" field analogous to system
  prompts.
- File attachments are limited (token budget, not file count).
- The Gem is invoked by name in the chat UI; one-shot or
  multi-turn.

Bootstrap shape: paste a slim AGENTS.md (≤8000 chars typical) into
the Custom instructions. Attach the canon files. Treat the Gem as
single-purpose: one Gem per workstream is cleaner than one Gem
trying to multitask.

## Custom GPT (OpenAI's chat customization)

- The host has an "Instructions" field analogous to system
  prompts (8000 char budget typical).
- Files attached to the GPT are persistent.
- Actions (the OpenAPI integration) are advanced; default GPTs
  use only chat plus uploaded files.

Bootstrap shape: paste the AGENTS.md (≤8000 chars) into
Instructions. Attach the canon files. Avoid action declarations
unless the workstream specifically requires them.

## Cross-host file attachment patterns

| Host | Attaches as | Persistent | Limit |
|---|---|---|---|
| Claude Code | Working-dir files | Yes | Filesystem |
| Codex | Working-dir files | Yes | Filesystem |
| Cursor | Working-dir files | Yes | Filesystem |
| Aider | Working-dir files | Yes | Filesystem |
| Gemini CLI | Working-dir files | Yes | Filesystem |
| Antigravity | Working-dir files | Yes | Filesystem |
| Claude.ai project | Project files | Yes | Token budget |
| NotebookLM | Sources | Yes | 50+ sources typical |
| Custom Gem | Knowledge | Yes | Smaller token budget |
| Custom GPT | Knowledge | Yes | Smaller token budget |

The session-dispatch skill picks the right shape per host, and the
HANDOFF.md tells the human exactly which files go where.

## Quirks summary table

| Host | Bootstrap form | Format | File limit |
|---|---|---|---|
| Claude Code | AGENTS.md, CLAUDE.md pointer | full | filesystem |
| Codex | AGENTS.md (with optional override) | full | filesystem |
| Cursor | AGENTS.md (or .cursor/rules/*.mdc) | full | filesystem |
| Aider | .aider.conf.yml plus AGENTS.md | full | filesystem |
| Gemini CLI | AGENTS.md only | full | filesystem |
| Antigravity | AGENTS.md plus skill folders | full | filesystem |
| Claude.ai project | Instructions field plus attached files | full | tokens |
| NotebookLM | Customize field plus sources | slim | tokens |
| Custom Gem | Custom instructions plus knowledge | slim | tokens |
| Custom GPT | Instructions plus knowledge | slim | tokens |

"Full" means the entire AGENTS.md fits. "Slim" means a stripped
version under 8000 chars, with detail in attached sources.

END_HOST_QUIRKS
