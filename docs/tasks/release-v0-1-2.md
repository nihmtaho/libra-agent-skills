---
title: Release v0.1.2 with the four Define skills
updated: 2026-11-17
spec: ../specs/release-v0-1-2.md
---
# Release v0.1.2 with the four Define skills

Stopped at: not started

## Checkpoint — after T1
`bash scripts/test.sh` prints the five green lines, `git status --porcelain`
prints nothing, and a fresh `./install.sh --to agents --dest "$tmp"` prints
`17 installed` with no `write-spec` in `$tmp/.agents/skills`. A tag on a dirty
tree, or on a set nobody has installed, is not a release.

- [ ] **T1 — Commit the Define pipeline**
      Done means: `git status --porcelain` prints nothing, `bash scripts/test.sh`
      exits 0 with five green lines, and no commit carries a co-author line.
      Touches: `skills/`, `scripts/`, `docs/`, `README.md`
- [ ] **T2 — Write CHANGELOG.md for 0.1.2**
      Done means: `grep -q '^## \[0.1.2\]' CHANGELOG.md` exits 0,
      `bash scripts/check-docs.sh CHANGELOG.md` exits 0, and the section names
      the four added skills, the removed `write-spec`, and the removed lock file.
      Touches: `CHANGELOG.md`
      Depends on: T1
- [ ] **T3 — Tag v0.1.2 and publish the release**
      Done means: `git tag -l v0.1.2` prints it, `git show v0.1.2 --stat` lists
      the four new skill directories, and `gh release view v0.1.2` exits 0.
      Touches: git refs and the release body; no files
      Depends on: T2
- [ ] **T4 — Make the state file true**
      Done means: the Features row reads `done`, `## Next` item 1 names v0.1.2,
      and `bash scripts/check.sh` exits 0.
      Touches: `docs/PROJECT.md`
      Depends on: T3
