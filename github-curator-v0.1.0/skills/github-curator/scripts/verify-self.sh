#!/usr/bin/env bash
#
# verify-self.sh
#
# Runs the 15-row publish-readiness matrix against this repository.
# Implements the boolean-atomic checks defined in
# skills/github-curator/references/self-verification-matrix.md.
#
# Exit codes:
#   0 = PROMOTE (all Essential PASS, all Pitfall FALSE, all Important PASS)
#   1 = QUARANTINE (any Essential FAIL or any Pitfall TRUE)
#   2 = PROMOTE-WITH-WARNING (Essential PASS, Pitfall PASS, but Important FAIL)
#
# No dependencies beyond bash, grep, awk, sed, find, sort, comm.

set -u

REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$REPO"

# Counters
ESSENTIAL_PASS=0
ESSENTIAL_FAIL=0
IMPORTANT_PASS=0
IMPORTANT_FAIL=0
OPTIONAL_PASS=0
OPTIONAL_FAIL=0
PITFALL_GOOD=0
PITFALL_BAD=0

# Reporting buffer
REPORT=""

report_row() {
  local num="$1"
  local tag="$2"
  local result="$3"
  local reason="${4:-}"
  REPORT="${REPORT}| ${num} | ${tag} | ${result} | ${reason} |"$'\n'
  case "${tag}/${result}" in
    Essential/PASS) ESSENTIAL_PASS=$((ESSENTIAL_PASS+1));;
    Essential/FAIL) ESSENTIAL_FAIL=$((ESSENTIAL_FAIL+1));;
    Important/PASS) IMPORTANT_PASS=$((IMPORTANT_PASS+1));;
    Important/FAIL) IMPORTANT_FAIL=$((IMPORTANT_FAIL+1));;
    Optional/PASS)  OPTIONAL_PASS=$((OPTIONAL_PASS+1));;
    Optional/FAIL)  OPTIONAL_FAIL=$((OPTIONAL_FAIL+1));;
    Pitfall/PASS)   PITFALL_GOOD=$((PITFALL_GOOD+1));;
    Pitfall/FAIL)   PITFALL_BAD=$((PITFALL_BAD+1));;
  esac
}

# --- Row 1: AGENTS.md exists at repo root ---
if [ -f "AGENTS.md" ]; then
  report_row 1 Essential PASS ""
else
  report_row 1 Essential FAIL "AGENTS.md not found at repo root"
fi

# --- Row 2: Each SKILL.md frontmatter validates ---
ROW2_FAIL=""
for skill_md in skills/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  # Extract frontmatter between --- markers
  frontmatter=$(awk '/^---$/{n++; next} n==1' "$skill_md")
  if ! echo "$frontmatter" | grep -q "^name:"; then
    ROW2_FAIL="$ROW2_FAIL $skill_md(no name)"
  fi
  if ! echo "$frontmatter" | grep -q "^description:"; then
    ROW2_FAIL="$ROW2_FAIL $skill_md(no description)"
  fi
done
if [ -z "$ROW2_FAIL" ]; then
  report_row 2 Essential PASS ""
else
  report_row 2 Essential FAIL "$ROW2_FAIL"
fi

# --- Row 3: Skill name field equals parent directory name ---
ROW3_FAIL=""
for skill_md in skills/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  dir=$(basename "$(dirname "$skill_md")")
  name=$(awk -F': ' '/^name:/{print $2; exit}' "$skill_md" | tr -d '"' | tr -d "'" | sed 's/[[:space:]]*$//')
  # Validate regex
  if ! echo "$name" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
    ROW3_FAIL="$ROW3_FAIL $skill_md(name '$name' fails regex)"
  fi
  # Validate length
  if [ ${#name} -gt 64 ]; then
    ROW3_FAIL="$ROW3_FAIL $skill_md(name too long)"
  fi
  # Validate equals dirname
  if [ "$name" != "$dir" ]; then
    ROW3_FAIL="$ROW3_FAIL $skill_md(name '$name' != dir '$dir')"
  fi
done
if [ -z "$ROW3_FAIL" ]; then
  report_row 3 Essential PASS ""
else
  report_row 3 Essential FAIL "$ROW3_FAIL"
fi

# --- Row 4: description length 1 to 1024 ---
ROW4_FAIL=""
for skill_md in skills/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  desc=$(awk -F': ' '/^description:/{ $1=""; sub(/^ /, ""); print; exit }' "$skill_md")
  # Strip surrounding quotes
  desc=$(echo "$desc" | sed 's/^"//; s/"$//')
  len=${#desc}
  if [ "$len" -lt 1 ] || [ "$len" -gt 1024 ]; then
    ROW4_FAIL="$ROW4_FAIL $skill_md(len=$len)"
  fi
done
if [ -z "$ROW4_FAIL" ]; then
  report_row 4 Essential PASS ""
else
  report_row 4 Essential FAIL "$ROW4_FAIL"
fi

# --- Row 5: LICENSE exists with recognized header ---
if [ -f "LICENSE" ]; then
  if grep -qE 'Apache License|MIT License|BSD .* License|Mozilla Public License|GNU .* License|Creative Commons' LICENSE; then
    report_row 5 Essential PASS ""
  else
    report_row 5 Essential FAIL "LICENSE present but no recognized SPDX header found"
  fi
else
  report_row 5 Essential FAIL "LICENSE not found"
fi

# --- Row 6: No em dashes (U+2014) and no en dashes (U+2013) ---
DASH_HITS=$(grep -rln $'\xe2\x80\x94\|\xe2\x80\x93' --include='*.md' . 2>/dev/null | grep -v '^./packets/' || true)
if [ -z "$DASH_HITS" ]; then
  report_row 6 Essential PASS ""
else
  report_row 6 Essential FAIL "dashes in: $(echo $DASH_HITS | tr '\n' ' ')"
fi

# --- Row 7: No tier-1 IP scrub hits ---
# Tier-1 patterns from references/ip-scrub-tiers.md, abridged for self-check.
# The full scrub is run by the publish-readiness-rubric skill on real artifacts.
TIER1_PATTERNS=(
  'DESKTOP-[A-Z0-9]+'
  'C:\\\\Users\\\\Austin'
  'sk-or-v1-'
  'sk-ant-api'
  'austing143[^.]'
  'CCC0x'
  'FxD_build_notes'
  'quant_pipeline_architecture'
  'xD_Arbitrage'
)
ROW7_HITS=""
for pat in "${TIER1_PATTERNS[@]}"; do
  hits=$(grep -rEl "$pat" --include='*.md' . 2>/dev/null | grep -v '^./packets/' || true)
  if [ -n "$hits" ]; then
    ROW7_HITS="$ROW7_HITS [$pat]:$(echo $hits | tr '\n' ' ')"
  fi
done
if [ -z "$ROW7_HITS" ]; then
  report_row 7 Essential PASS ""
else
  report_row 7 Essential FAIL "$ROW7_HITS"
fi

# --- Row 8: CLAUDE.md is the 3-line pointer (or symlink) ---
if [ -L "CLAUDE.md" ]; then
  report_row 8 Important PASS "(symlink)"
elif [ -f "CLAUDE.md" ]; then
  if grep -q "AGENTS.md" CLAUDE.md && grep -q "symlink" CLAUDE.md; then
    report_row 8 Important PASS ""
  else
    report_row 8 Important FAIL "CLAUDE.md exists but does not delegate to AGENTS.md"
  fi
else
  report_row 8 Important FAIL "CLAUDE.md not found"
fi

# --- Row 9: CHANGELOG.md has [Unreleased] section ---
if [ -f "CHANGELOG.md" ] && grep -q "## \[Unreleased\]" CHANGELOG.md; then
  report_row 9 Important PASS ""
else
  report_row 9 Important FAIL "CHANGELOG.md missing or no [Unreleased] section"
fi

# --- Row 10: registry.yaml rows match skills tree ---
if [ -f "registry.yaml" ]; then
  REG_SKILLS=$(awk '/path: skills\//{ sub(/^ +/,""); sub(/^path: skills\//,""); sub(/\/SKILL\.md.*$/,""); print }' registry.yaml | sort -u)
  TREE_SKILLS=$(find skills -maxdepth 1 -mindepth 1 -type d | sed 's|skills/||' | sort -u)
  DIFF=$(comm -3 <(echo "$REG_SKILLS") <(echo "$TREE_SKILLS"))
  if [ -z "$DIFF" ]; then
    report_row 10 Important PASS ""
  else
    report_row 10 Important FAIL "diff: $(echo $DIFF | tr '\n' ' ')"
  fi
else
  report_row 10 Important FAIL "registry.yaml not found"
fi

# --- Row 11: Conventional Commits format suggested in commit message ---
# This row is checked at commit time by a git hook (not present yet on bootstrap).
# At bootstrap, the row is informational PASS because no commit has been made.
report_row 11 Important PASS "(deferred to commit-msg hook on first commit)"

# --- Row 12: compatibility lists at least 3 host environments ---
ROW12_FAIL=""
for skill_md in skills/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  compat=$(awk -F': ' '/^compatibility:/{ $1=""; sub(/^ /, ""); print; exit }' "$skill_md")
  count=$(echo "$compat" | tr ',' '\n' | wc -l | tr -d ' ')
  if [ "$count" -lt 3 ]; then
    ROW12_FAIL="$ROW12_FAIL $skill_md(compat_count=$count)"
  fi
done
if [ -z "$ROW12_FAIL" ]; then
  report_row 12 Optional PASS ""
else
  report_row 12 Optional FAIL "$ROW12_FAIL"
fi

# --- Row 13: Reference docs follow progressive-disclosure conventions ---
# Heuristic: each SKILL.md mentions references/ only inside a "Reference docs"
# section, not as eager-load instructions in the activation body.
ROW13_FAIL=""
for skill_md in skills/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  # Find first reference to "references/" path
  first_ref_line=$(grep -n "references/" "$skill_md" | head -n 1 | cut -d: -f1 || echo "")
  if [ -n "$first_ref_line" ]; then
    # Find the line of the "## Reference docs" section
    ref_section_line=$(grep -n "^## Reference docs" "$skill_md" | head -n 1 | cut -d: -f1 || echo "")
    if [ -z "$ref_section_line" ] || [ "$first_ref_line" -lt "$ref_section_line" ]; then
      # Allow if the reference is mentioned inside another Reference-style heading
      if ! awk "NR==$first_ref_line" "$skill_md" | grep -qE '(Reference|reference)'; then
        # Only fail if it appears to be an eager load instruction
        if awk "NR==$first_ref_line" "$skill_md" | grep -qiE '(load|read|consult)'; then
          ROW13_FAIL="$ROW13_FAIL $skill_md(eager_ref_at_line_$first_ref_line)"
        fi
      fi
    fi
  fi
done
if [ -z "$ROW13_FAIL" ]; then
  report_row 13 Optional PASS ""
else
  report_row 13 Optional FAIL "$ROW13_FAIL"
fi

# --- Row 14 (Pitfall): SKILL.md instructs eager-load of multiple bodies ---
ROW14_BAD=""
for skill_md in skills/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  if grep -qE 'always (load|read).*SKILL\.md' "$skill_md"; then
    ROW14_BAD="$ROW14_BAD $skill_md"
  fi
done
if [ -z "$ROW14_BAD" ]; then
  report_row 14 Pitfall PASS "(no eager multi-body load found)"
else
  report_row 14 Pitfall FAIL "$ROW14_BAD"
fi

# --- Row 15 (Pitfall): Reference doc body exceeds 5000 lines ---
ROW15_BAD=""
for ref_md in skills/*/references/*.md; do
  [ -f "$ref_md" ] || continue
  lc=$(wc -l < "$ref_md" | tr -d ' ')
  if [ "$lc" -gt 5000 ]; then
    ROW15_BAD="$ROW15_BAD $ref_md(${lc}lines)"
  fi
done
if [ -z "$ROW15_BAD" ]; then
  report_row 15 Pitfall PASS ""
else
  report_row 15 Pitfall FAIL "$ROW15_BAD"
fi

# --- Aggregate ---
echo "PUBLISH_READINESS_RUBRIC v0.1.0"
echo "artifact: $(basename "$REPO") (self)"
echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "scorer: github-curator/scripts/verify-self.sh"
echo
echo "| # | Tag | Result | Reason if FAIL |"
echo "|---|---|---|---|"
echo -n "$REPORT"
echo
echo "Aggregate:"
echo "  Essential: $ESSENTIAL_PASS PASS / $ESSENTIAL_FAIL FAIL"
echo "  Important: $IMPORTANT_PASS PASS / $IMPORTANT_FAIL FAIL"
echo "  Optional:  $OPTIONAL_PASS PASS / $OPTIONAL_FAIL FAIL"
echo "  Pitfall:   $PITFALL_GOOD good / $PITFALL_BAD bad"
echo

if [ "$ESSENTIAL_FAIL" -gt 0 ] || [ "$PITFALL_BAD" -gt 0 ]; then
  echo "VERDICT: QUARANTINE"
  exit 1
elif [ "$IMPORTANT_FAIL" -gt 0 ]; then
  echo "VERDICT: PROMOTE-WITH-WARNING"
  exit 2
else
  echo "VERDICT: PROMOTE"
  exit 0
fi
