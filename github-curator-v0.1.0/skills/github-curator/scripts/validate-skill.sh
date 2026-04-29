#!/usr/bin/env bash
#
# validate-skill.sh
#
# Validates a single skill folder against the Agent Skills
# specification at https://agentskills.io/specification.
#
# Usage:
#   validate-skill.sh skills/<skill-name>
#   validate-skill.sh /absolute/path/to/skill-folder
#
# Exit codes:
#   0 = PASS (skill conforms to spec)
#   1 = FAIL (skill has spec violations)
#   2 = USAGE error
#
# Checks performed:
#   1. SKILL.md exists at the skill root.
#   2. SKILL.md has YAML frontmatter delimited by --- markers.
#   3. Frontmatter contains required `name` field.
#   4. Frontmatter contains required `description` field.
#   5. `name` matches regex ^[a-z0-9][a-z0-9-]*$, length 1-64.
#   6. `name` equals parent directory name.
#   7. `description` length is 1-1024 chars.
#   8. If `compatibility` present, it is a non-empty string.
#   9. If `license` present, it is a non-empty string.
#  10. Skill body (after frontmatter) is non-empty.

set -u

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <skill-folder-path>" >&2
  exit 2
fi

SKILL_DIR="$1"
if [ ! -d "$SKILL_DIR" ]; then
  echo "ERROR: $SKILL_DIR is not a directory" >&2
  exit 2
fi

SKILL_MD="$SKILL_DIR/SKILL.md"
DIR_NAME=$(basename "$SKILL_DIR")
FAILS=0

check() {
  local label="$1"
  local result="$2"
  local detail="${3:-}"
  if [ "$result" = "PASS" ]; then
    echo "  [PASS] $label"
  else
    echo "  [FAIL] $label${detail:+ ($detail)}"
    FAILS=$((FAILS+1))
  fi
}

echo "Validating skill: $SKILL_DIR"
echo "  directory name: $DIR_NAME"
echo

# Check 1: SKILL.md exists
if [ -f "$SKILL_MD" ]; then
  check "SKILL.md exists" PASS
else
  check "SKILL.md exists" FAIL "expected at $SKILL_MD"
  echo
  echo "VERDICT: FAIL ($FAILS issues)"
  exit 1
fi

# Check 2: frontmatter delimiters present
DELIM_COUNT=$(grep -c "^---$" "$SKILL_MD" || true)
if [ "$DELIM_COUNT" -ge 2 ]; then
  check "frontmatter delimiters (---) present" PASS
else
  check "frontmatter delimiters (---) present" FAIL "found $DELIM_COUNT, need >= 2"
  echo
  echo "VERDICT: FAIL ($FAILS issues)"
  exit 1
fi

# Extract frontmatter
FRONTMATTER=$(awk '/^---$/{n++; next} n==1' "$SKILL_MD")

# Check 3: name field present
NAME=$(echo "$FRONTMATTER" | awk -F': ' '/^name:/{print $2; exit}' | sed 's/^"//;s/"$//;s/^'\''//;s/'\''$//' | sed 's/[[:space:]]*$//')
if [ -n "$NAME" ]; then
  check "name field present" PASS
else
  check "name field present" FAIL
fi

# Check 4: description field present
DESC=$(echo "$FRONTMATTER" | awk -F': ' '/^description:/{ $1=""; sub(/^ /, ""); print; exit }' | sed 's/^"//;s/"$//')
if [ -n "$DESC" ]; then
  check "description field present" PASS
else
  check "description field present" FAIL
fi

# Check 5: name regex and length
if [ -n "$NAME" ]; then
  if echo "$NAME" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
    check "name matches regex ^[a-z0-9][a-z0-9-]*$" PASS
  else
    check "name matches regex" FAIL "got: '$NAME'"
  fi
  if [ ${#NAME} -ge 1 ] && [ ${#NAME} -le 64 ]; then
    check "name length 1-64" PASS
  else
    check "name length 1-64" FAIL "got: ${#NAME}"
  fi
fi

# Check 6: name equals dir name
if [ "$NAME" = "$DIR_NAME" ]; then
  check "name equals parent directory name" PASS
else
  check "name equals parent directory name" FAIL "name='$NAME' dir='$DIR_NAME'"
fi

# Check 7: description length
if [ -n "$DESC" ]; then
  DLEN=${#DESC}
  if [ "$DLEN" -ge 1 ] && [ "$DLEN" -le 1024 ]; then
    check "description length 1-1024" PASS
  else
    check "description length 1-1024" FAIL "got: $DLEN"
  fi
fi

# Check 8: compatibility (optional, but if present, non-empty)
COMPAT=$(echo "$FRONTMATTER" | awk -F': ' '/^compatibility:/{ $1=""; sub(/^ /, ""); print; exit }' | sed 's/^"//;s/"$//')
if echo "$FRONTMATTER" | grep -q "^compatibility:"; then
  if [ -n "$COMPAT" ]; then
    check "compatibility (optional, present and non-empty)" PASS
  else
    check "compatibility present but empty" FAIL
  fi
fi

# Check 9: license (optional, but if present, non-empty)
LICENSE=$(echo "$FRONTMATTER" | awk -F': ' '/^license:/{ $1=""; sub(/^ /, ""); print; exit }' | sed 's/^"//;s/"$//')
if echo "$FRONTMATTER" | grep -q "^license:"; then
  if [ -n "$LICENSE" ]; then
    check "license (optional, present and non-empty)" PASS
  else
    check "license present but empty" FAIL
  fi
fi

# Check 10: body non-empty (after second --- delimiter)
BODY_LINES=$(awk '/^---$/{n++; next} n==2' "$SKILL_MD" | grep -c '[^[:space:]]' || true)
if [ "$BODY_LINES" -gt 0 ]; then
  check "skill body has content" PASS
else
  check "skill body has content" FAIL "no non-whitespace lines after frontmatter"
fi

echo
if [ "$FAILS" -eq 0 ]; then
  echo "VERDICT: PASS (skill conforms to Agent Skills spec)"
  exit 0
else
  echo "VERDICT: FAIL ($FAILS issues)"
  exit 1
fi
