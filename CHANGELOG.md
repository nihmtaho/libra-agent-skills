# Changelog

All notable changes to this skill set. Earlier releases are in the git tags.

## [Unreleased]

The release phase gets an owner, and `ship` stops pointing at nothing.

### Added
- `release`: four gates before a tag, the changelog before the tag, an annotated
  tag on the default branch, and notes verified by command.
- `test-driven-development`: red, green, refactor, with the 80/15/5 pyramid and
  DAMP over DRY in tests.
- `incremental-implementation`: thin slices, a flag for a risky one, one slice per
  commit, and the branch check the commit needs.
- `doubt-driven-development`: an important claim re-derived in a fresh context
  through CLAIM, EXTRACT, DOUBT, RECONCILE and STOP.

### Changed
- `ship` names `release` instead of deferring to "a separate decision", and says
  that nothing to merge is normal, not permission to tag.
- `build` becomes the Build dispatcher: it names which skill runs, in what order,
  and `test-driven-development` plus `incremental-implementation` are never
  skipped. Spike mode stays, as the one exception.

## [0.1.2] - 2026-11-17

The Define phase lands: four skills, their documents, and the evals that test
them.

### Added
- `interview-me`, `idea-refine`, `spec-driven-development` and
  `constraint-driven-development`: the Define phase, from a vague request to a
  spec and a written quality bar.
- `docs/ideas/` and `docs/CONSTRAINTS.md` as document types the checker enforces.
- `evals/`: contract, behavior and routing evals, each with a self-test proving
  the grader can fail.
- `scripts/test-routing.sh`: two skill descriptions that answer the same words
  now fail the suite.
- `scripts/check.sh` fails when the README uninstall loop misses a skill.

### Changed
- `verify` and `review` read `docs/CONSTRAINTS.md`, so the project's own bar is
  checked where it is enforced.
- `bootstrap-project` hands off to `constraint-driven-development` instead of
  seeding a placeholder bar.

### Removed
- `write-spec`, replaced by `spec-driven-development`. A v0.1.1 install keeps a
  dangling `write-spec` symlink: run the README uninstall loop before
  reinstalling.
- `skills-lock.json`: it recorded this repo's own v0.1.1 install, and its hashes
  come from the skills CLI, so a project gets its own lock when it installs.
