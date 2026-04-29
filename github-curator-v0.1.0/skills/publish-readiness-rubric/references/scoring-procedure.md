# scoring-procedure.md

The mechanical per-row scoring procedure for the
publish-readiness-rubric. Loaded on demand by
`skills/publish-readiness-rubric/SKILL.md`.

The implementation reference is `skills/github-curator/scripts/verify-self.sh`,
which is the working script that this document describes. When
scoring an external artifact (rather than this repo itself), the
agent runs the same procedure with the artifact path as input
instead of the repo root.

## Inputs

- `ARTIFACT_PATH`: the directory or zip to score. If a zip, unpack
  to a working directory first.
- `MODE`: one of `self` (run on this repo), `external` (run on a
  packet under review).

## Per-row mechanical check

The 15 rows are defined in
`skills/github-curator/references/self-verification-matrix.md`. The
mechanical check per row is:

### Row 1: AGENTS.md exists at repo root
```
test -f "$ARTIFACT_PATH/AGENTS.md"
```

### Row 2: Each SKILL.md frontmatter validates
```
for skill_md in "$ARTIFACT_PATH"/skills/*/SKILL.md; do
  frontmatter=$(awk '/^---$/{n++; next} n==1' "$skill_md")
  echo "$frontmatter" | grep -q "^name:"
  echo "$frontmatter" | grep -q "^description:"
done
```

### Row 3: Skill name equals parent directory name
```
for skill_md in "$ARTIFACT_PATH"/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$skill_md")")
  name=$(awk -F': ' '/^name:/{print $2; exit}' "$skill_md" | trim)
  test "$name" = "$dir"
  echo "$name" | grep -qE '^[a-z0-9][a-z0-9-]*$'
  test ${#name} -le 64
done
```

### Row 4: description length 1 to 1024
```
for skill_md in "$ARTIFACT_PATH"/skills/*/SKILL.md; do
  desc=$(extract_yaml_field description "$skill_md")
  len=${#desc}
  test "$len" -ge 1 && test "$len" -le 1024
done
```

### Row 5: LICENSE exists with recognized header
```
test -f "$ARTIFACT_PATH/LICENSE"
grep -qE 'Apache License|MIT License|BSD .* License|Mozilla Public License|GNU .* License|Creative Commons' "$ARTIFACT_PATH/LICENSE"
```

### Row 6: No em dashes (U+2014) and no en dashes (U+2013)
```
grep -rln $'\xe2\x80\x94\|\xe2\x80\x93' --include='*.md' "$ARTIFACT_PATH" | grep -v '^.*/packets/'
# Empty output = PASS.
```

### Row 7: No tier-1 IP scrub hits
```
for pattern in $(load_tier1_patterns "ip-scrub-tiers.md"); do
  grep -rEl "$pattern" --include='*.md' "$ARTIFACT_PATH" | grep -v '^.*/packets/'
done
# All patterns return empty = PASS.
```

### Row 8: CLAUDE.md is the 3-line pointer (or symlink)
```
if [ -L "$ARTIFACT_PATH/CLAUDE.md" ]; then
  PASS  # real symlink is acceptable
elif [ -f "$ARTIFACT_PATH/CLAUDE.md" ]; then
  grep -q "AGENTS.md" "$ARTIFACT_PATH/CLAUDE.md" && \
  grep -q "symlink" "$ARTIFACT_PATH/CLAUDE.md"
fi
```

### Row 9: CHANGELOG.md has [Unreleased] section
```
test -f "$ARTIFACT_PATH/CHANGELOG.md"
grep -q "## \[Unreleased\]" "$ARTIFACT_PATH/CHANGELOG.md"
```

### Row 10: registry.yaml rows match skills tree
```
REG_SKILLS=$(awk '/path: skills\//{ sub(/^ +/,""); sub(/^path: skills\//,""); sub(/\/SKILL\.md.*$/,""); print }' "$ARTIFACT_PATH/registry.yaml" | sort -u)
TREE_SKILLS=$(find "$ARTIFACT_PATH/skills" -maxdepth 1 -mindepth 1 -type d | xargs -n1 basename | sort -u)
diff <(echo "$REG_SKILLS") <(echo "$TREE_SKILLS")
# Empty diff = PASS.
```

### Row 11: Conventional Commits format
For self-verification, this row defers to the commit-msg hook (PASS
on bootstrap because no commit has been made yet).

For external artifact verification, this row checks the proposed
commit message in the agent's working state:
```
echo "$COMMIT_MSG" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|release)(\(.+\))?!?: .+'
```

### Row 12: compatibility lists at least 3 host environments
```
for skill_md in "$ARTIFACT_PATH"/skills/*/SKILL.md; do
  compat=$(extract_yaml_field compatibility "$skill_md")
  count=$(echo "$compat" | tr ',' '\n' | wc -l)
  test "$count" -ge 3
done
```

### Row 13: Reference docs follow progressive disclosure
Heuristic check: each `references/` mention in a SKILL.md body must
appear inside a "Reference docs" section, not as an eager-load
instruction in the activation body.

```
for skill_md in "$ARTIFACT_PATH"/skills/*/SKILL.md; do
  first_ref_line=$(grep -n "references/" "$skill_md" | head -n 1 | cut -d: -f1)
  ref_section_line=$(grep -n "^## Reference docs" "$skill_md" | head -n 1 | cut -d: -f1)
  test "$first_ref_line" -ge "$ref_section_line" || verify_not_eager_load
done
```

### Row 14 (Pitfall): SKILL.md instructs eager-load of multiple bodies
```
grep -E 'always (load|read).*SKILL\.md' "$ARTIFACT_PATH"/skills/*/SKILL.md
# Match = FAIL (Pitfall TRUE means bad).
```

### Row 15 (Pitfall): Reference doc body exceeds 5000 lines
```
for ref in "$ARTIFACT_PATH"/skills/*/references/*.md; do
  test "$(wc -l < "$ref")" -le 5000
done
```

## Aggregation

The aggregation rule is in `SKILL.md`:

```
ESSENTIAL_PASS = all rows 1-7 are TRUE
PITFALL_PASS = rows 14-15 are FALSE (i.e., Pitfall conditions did not occur)
IMPORTANT_PASS = all rows 8-11 are TRUE
OPTIONAL_PASS = all rows 12-13 are TRUE

if not (ESSENTIAL_PASS and PITFALL_PASS):
  VERDICT = QUARANTINE
elif IMPORTANT_PASS:
  VERDICT = PROMOTE
else:
  VERDICT = PROMOTE-WITH-WARNING
```

## Determinism

Same artifact in, same verdict out. The procedure is purely
mechanical with no model-graded steps. This is the design
principle that keeps the rubric stable across raters and
across time.

If a check requires subjective judgment, it does not belong in
the rubric. It belongs in the human's PEL verdict, which is
issued separately and is explicitly NOT something the agent
can self-issue (per pre_submit_gate v1.0 rule 4).

END_SCORING_PROCEDURE
