# release-procedure.md

The procedure for cutting a versioned release. Loaded on demand by
`skills/github-curator/SKILL.md`.

## Versioning

This repo uses SemVer 2.0.0 (https://semver.org). A version is
`MAJOR.MINOR.PATCH`, optionally with a pre-release tag
(`-alpha`, `-beta`, `-rc.1`).

Bump rules:

| Change | Bump |
|---|---|
| Typo fix in a skill body | PATCH |
| Link fix in a reference doc | PATCH |
| Reference doc clarification (no semantic change) | PATCH |
| New skill added | MINOR |
| New reference doc added | MINOR |
| New `compatibility` host listed | MINOR |
| New verification row added | MINOR |
| Removed skill | MAJOR |
| Moved file path that downstream packets reference | MAJOR |
| Renamed `name` field in any SKILL.md | MAJOR |
| Removed required field from SKILL.md frontmatter | MAJOR |
| Changed four-gate semantics that downstream consumers depend on | MAJOR |

Pre-release versions are used for unstable changes that need community
feedback. Once stable, drop the pre-release tag.

## Pre-release verification

Before any release:

1. Run `make verify`. The verification matrix must report 15 PASS / 0 FAIL.
2. Run the IP scrub against the entire repo. Any tier-1 hit blocks.
3. Confirm CHANGELOG.md `[Unreleased]` matches the actual diff since
   the last tag (verification matrix row 9).
4. Confirm the version bump matches the diff scope (use the table above).
5. Confirm `registry.yaml` is up to date with the `skills/` tree.

If any step fails, halt. Do not proceed.

## Cut the release

Manual procedure (no automation required):

```sh
# 1. Move [Unreleased] to [vX.Y.Z] in CHANGELOG.md, add date.
# 2. Add a new [Unreleased] section at the top.
# 3. Commit:
git add CHANGELOG.md
git commit -m "release: vX.Y.Z"

# 4. Tag (annotated):
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# 5. Push commit and tag:
git push origin main
git push origin vX.Y.Z

# 6. Build the packet zip (vercel-labs/agent-skills convention):
cd packets/
mkdir github-curator-vX.Y.Z/
cp -r ../skills github-curator-vX.Y.Z/
cp -r ../AGENTS.md ../CLAUDE.md ../README.md ../LICENSE ../CHANGELOG.md \
      ../registry.yaml ../authors.yaml github-curator-vX.Y.Z/
zip -r github-curator-vX.Y.Z.zip github-curator-vX.Y.Z/
sha256sum github-curator-vX.Y.Z.zip > github-curator-vX.Y.Z.zip.sha256
cd ..

# 7. Create a GitHub Release attached to the tag, attach the zip and
#    sha256 file as release assets. Use the CHANGELOG entry as the
#    release notes body.
gh release create vX.Y.Z \
  packets/github-curator-vX.Y.Z.zip \
  packets/github-curator-vX.Y.Z.zip.sha256 \
  --title "vX.Y.Z" \
  --notes-file <(awk "/^## \[$VERSION\]/,/^## \[/" CHANGELOG.md | head -n -1)
```

## Naming convention for release assets

Per https://github.com/vercel-labs/agent-skills convention: the zip
filename matches the directory name exactly. Inside the zip, the
top-level folder is `github-curator-vX.Y.Z/` (versioned), so a user
who unpacks multiple versions side-by-side does not collide.

Assets attached to a release:
- `github-curator-vX.Y.Z.zip` (the bundle).
- `github-curator-vX.Y.Z.zip.sha256` (single-line sha256 hash).

## Post-release

1. Update README.md "Quick start" section if the install path
   changed.
2. If a public announcement is planned (LinkedIn, Substack, X), the
   announcement is composed under the `session-dispatch` skill in a
   separate session (the publishing-cadence workstream).
3. Verify the GitHub Release page renders correctly: the changelog
   entry is in the body, both assets are downloadable, the sha256
   matches.

## Yanking a release

If a release contains a tier-1 IP scrub hit that escaped pre-release
verification:

1. Delete the GitHub Release immediately.
2. Delete the git tag locally and remotely:
   ```sh
   git tag -d vX.Y.Z
   git push origin :refs/tags/vX.Y.Z
   ```
3. Cut a new patch release with the fix.
4. Document the incident in CHANGELOG.md under Security. Do not
   describe the leaked content; describe the remediation only.
5. Update the verification matrix to add a row that catches the
   pattern that escaped, per the evolution rule in
   `references/evolution-rule.md` (in publish-readiness-rubric).

## "Use this template" for downstream forks

When a downstream user clicks "Use this template" on GitHub:

1. They get a clean-history clone of the repo at the latest commit
   on `main`.
2. The fork inherits LICENSE (Apache-2.0). The copyright line in
   LICENSE Appendix should be updated to the fork owner; the rest of
   the LICENSE text is preserved unmodified per Apache 2.0 Section 4.
3. The fork should bump the version reset to `0.1.0` for its own
   release lineage; the CHANGELOG should add an entry noting the
   fork's upstream (this repo at the specific commit SHA).
4. The fork retains the four skills as the foundation; new skills go
   under `skills/` following the same structure.

END_RELEASE_PROCEDURE
