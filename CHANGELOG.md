# Changelog

All notable changes to this skill set. Earlier releases are in the git tags.

## [0.3.0] - 2026-11-27

One npm package installs as a plugin on Claude Code, OpenCode and Pi, and as the
same skills on Command Code. Two rules run without a human remembering them.

### Added
- `libra-agent-skills` on npm: one package, 27 skills, Claude Code plugin
  manifest and marketplace, OpenCode plugin, Pi package, and a Command Code
  install through `cmd skills add`.
- a markdown guard: after a write or edit of a `.md` file, the shipped
  `scripts/check-docs.sh` runs and its FAIL goes back to the model on Claude
  Code, OpenCode and Pi.
- a commit guard: a `git commit` on the default branch, or a forced push to it,
  is blocked unless `docs/GIT.md` carries `<!-- libra:allow-direct-commit -->`.
- per-skill evals: 63 cases across the 27 skills, a sandbox runner and fixtures,
  and a verifier. The full run scored 44/63 with-skill against 6/63 baseline.
- an intake gate and a question guard: a hunch goes through `libra-idea-refine`,
  two readings through `libra-interview-me`, and a question is answered, not
  implemented.

### Changed
- **Breaking:** the Claude Code marketplace has one `libra` entry instead of six
  groups. A plugin manifest with hooks and a group entry that declares skills
  conflict, so `/plugin install libra@libra-agent-skills` replaces the six.
  `npx skills add` shows one group.
- **Breaking:** every skill name starts with `libra-`, and `using-libra` is now
  `libra-start`. A tool's own `/ship` or `/release` no longer collides with the
  set. Remove the 27 unprefixed links before reinstalling; the README carries the
  loop. `scripts/check.sh` refuses a name without the prefix.
- "never a co-author line or an AI signature" now says what it is: a format
  convention, with a way out when the project or the platform requires a
  disclosure trailer. This is what Snyk's `build` E004 called hidden authorship.

### Fixed
- the `## Features` table in `docs/PROJECT.md` renders as a table again: the
  separator row was missing, and `check-docs.sh` now fails a table whose separator
  row is missing or invalid.

## [0.2.0] - 2026-11-18

The Build phase splits into eight skills behind one dispatcher, git decisions get
an owner, and a release note gets a template that checks itself.

### Added
- `release`: four gates before a tag, the changelog before the tag, an annotated
  tag on the default branch, and notes verified by command.
- `test-driven-development`: red, green, refactor, with the 80/15/5 pyramid and
  DAMP over DRY in tests.
- `incremental-implementation`: thin slices, a flag for a risky one, one slice per
  commit, and the branch check the commit needs.
- `doubt-driven-development`: an important claim re-derived in a fresh context
  through CLAIM, EXTRACT, DOUBT, RECONCILE and STOP.
- `context-engineering`: the smallest set of reading that answers the question,
  rules that survive a session in `AGENTS.md`, and a refreshed module map.
- `source-driven-development`: the installed version pinned, the primary source
  quoted, the citation in the ADR.
- `subagent-driven-development`: an overlap table by path, the parent keeps the
  commit, and a subagent's green is not the project's green.
- `frontend-ui-engineering`: tokens over literals, one responsibility per
  component, an explicit state model, three widths, and WCAG 2.1 AA.
- `api-and-interface-design`: the contract in `docs/api/` before the handler, one
  error format, validation at the boundary, and Hyrum's Law.
- `git-workflow-and-versioning`: the branching model, the merge policy, the version
  scheme and the commit format, in `docs/GIT.md`.

### Changed
- `ship` names `release` instead of deferring to "a separate decision", and says
  that nothing to merge is normal, not permission to tag.
- `release`: the note is filled from a shipped template — its frontmatter and
  comment dropped, a summary, every changelog entry, an upgrade line only when an install
  breaks, and a verify step that refuses a note still carrying a placeholder.
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
