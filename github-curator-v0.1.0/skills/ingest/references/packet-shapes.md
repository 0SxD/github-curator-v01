# packet-shapes.md

The three packet shapes the `ingest` skill detects. Loaded on demand
by `skills/ingest/SKILL.md` at the DETECT step, never at activation.

The detection produces one of three verdicts. The verdict determines
the NORMALIZE strategy.

## Shape A: spec-conformant

The packet is a folder containing `SKILL.md` whose YAML frontmatter
validates against https://agentskills.io/specification.

Detection rule:

```
test -f "$PACKET/SKILL.md"
extract_yaml_frontmatter "$PACKET/SKILL.md" | validate_against_agentskills_spec
```

If both pass, the shape is conformant. NORMALIZE is a no-op. Proceed
directly to SCORE unless the human has flagged a known issue.

Examples of conformant packets:

- A skill copied from `https://github.com/anthropics/skills/tree/main/skills/<n>`.
- A skill exported from a downstream fork that conforms to the same spec.
- The four skills in this repo (each is conformant to itself).

## Shape B: spec-adjacent

The packet is a folder containing markdown files plus optional
subdirectories, but the top-level markdown is missing valid
frontmatter. The structural intent matches the spec; the metadata is
absent or malformed.

Detection rule:

```
test -f "$PACKET/SKILL.md" || test -f "$PACKET/README.md"
extract_yaml_frontmatter $TOP_MD | validate_against_agentskills_spec
# Returns FAIL.
```

NORMALIZE strategy:

1. Identify which file is the activation document. Prefer
   `SKILL.md`. If absent, the largest top-level `.md` file becomes
   the candidate.
2. Propose missing frontmatter fields:
   - `name` from the parent directory name (validated against the
     regex; if the directory name fails the regex, propose a
     normalized form).
   - `description` from the candidate file's first paragraph,
     truncated to 1024 chars, with the agent flagging that the
     "when to load" clause is missing.
   - `license` proposed as `Apache-2.0` (this repo's default; the
     human can override).
   - `compatibility` proposed as the conservative default
     "Claude.ai projects" (single host) until the human supplies
     more.
3. The proposed values are NOT written silently. They become the
   first round of INTERROGATE questions.

Examples of adjacent packets:

- A prompt collection from `danielmiessler/Fabric` patterns
  (`data/patterns/<n>/system.md`). The pattern shape is consistent
  but the SKILL.md frontmatter must be added.
- A skill from a downstream fork that predates the agentskills.io
  spec release (December 2025).
- A skill the human authored without using the spec.

## Shape C: spec-foreign

The packet is a directory of mixed content (PDFs, plain-text prompts,
JSON files, scattered markdown). There is no clear single skill file.
The packet contains potential material for one or more skills but no
declared skill structure.

Detection rule:

```
ls "$PACKET" | grep -E '\.(pdf|json|txt|csv|html|epub)$' | wc -l
test -f "$PACKET/SKILL.md" || test -f "$PACKET/README.md"
# Foreign if mixed-content count > 0 and no top-level SKILL.md/README.md.
```

NORMALIZE strategy:

1. Catalogue every file with its sha256 and inferred role:
   - `.md` files: candidate for `SKILL.md` or `references/`.
   - `.pdf`, `.png`, `.jpg`, `.svg`: candidate for `assets/`.
   - `.json`, `.yaml`: candidate for structured data; promote to
     `references/` if human-readable, otherwise `assets/`.
   - `.sh`, `.py`, `.js`: candidate for `scripts/`.
   - Plain-text prompts: candidates for either `SKILL.md` body or
     individual entries in a prompt-pack.
2. Propose a candidate skill structure:
   - One or more `SKILL.md` files (a prompt pack with 12 prompts
     might become 12 skills, or 1 skill with 12 references).
   - For each candidate, the same frontmatter proposal as Shape B.
3. The proposal is a write-list. INTERROGATE asks the human to
   confirm or modify the partition.

Examples of foreign packets:

- A NotebookLM source bundle (manifest.json plus a folder of
  uploaded sources). See `references/notebooklm-migration.md`
  (this skill's sibling reference doc).
- A folder dragged out of a Claude project.
- A zip from a colleague containing "all my prompts".

## Confidence threshold

The DETECT step reports a confidence level per shape:

- `confident`: structural signals are unambiguous.
- `probable`: structural signals point one way but a borderline
  signal could shift the verdict.
- `ambiguous`: the human must choose.

Ambiguous detection halts the loop. INTERROGATE asks: "The packet
has signals of both Shape B and Shape C. Treat as adjacent (one
candidate skill, propose missing frontmatter) or foreign (identify
multiple candidate skills)?"

## Why not auto-classify

The agent could pick a shape with high statistical confidence and
move on. The Zero Assumption Mandate (system_directive_protocol Section 3)
forbids it. A wrong shape produces a wrong NORMALIZE strategy,
which produces a wrong SCORE, which the human will not catch
because the rubric is mechanical and runs against whatever shape
the agent chose. The only safe rule is: when ambiguous, ask.

END_PACKET_SHAPES
