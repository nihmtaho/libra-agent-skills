---
title: Four Define skills replace write-spec, and the bar lives in CONSTRAINTS.md
updated: 2026-11-16
---
# Four Define skills replace write-spec, and the bar lives in CONSTRAINTS.md

## Context
A PM asked for four skills that remove the dependency on a general brainstorming
and verification set: interview one question at a time, widen then narrow an idea,
write the spec before the code, and hold a quality bar an agent cannot lower to
get green. `write-spec` already owned `docs/specs/`, so a second spec skill would
give one artifact two owners, which `using-libra` forbids. `verify` and `review`
already detect a lowered bar, but only after the fact and only for the diff in
hand; nothing recorded the bar before work started.

## Decision
- `spec-driven-development` replaces `write-spec` and is the only owner of
  `docs/specs/`.
- `interview-me` writes nothing; it ends with a four-line summary.
- `idea-refine` writes `docs/ideas/<slug>.md`, frozen once the spec exists.
- `constraint-driven-development` writes `docs/CONSTRAINTS.md` and is the
  definition half of the bar; `verify` and `review` point at that file.
- The checker gains two document types: `docs/ideas/*.md` and
  `docs/CONSTRAINTS.md`.

## Rejected options
- Keep `write-spec` and add the PRD as a "full mode": two skills writing one
  folder, and the routing ambiguity this set already paid for once.
- Leave `write-spec` as a redirect stub: a file that exists only to say it does
  not.
- Put `CONSTRAINTS.md` at the repo root: outside `docs/`, outside the checker's
  path table, and the one place a project's rules would go unchecked.
- Let `idea-refine` write the spec skeleton: a placeholder spec fails the checker
  until a second skill runs, and the next reader trusts it in between.

## Consequences
- A v0.1.1 install keeps a `write-spec` symlink that dangles until reinstall; the
  README uninstall loop now names the new set.
- `skills-lock.json` was a record of this repo's own v0.1.1 install. It is
  removed rather than hand-edited: the hashes come from the skills CLI, and a
  stale lock is a claim nobody checked. A project gets its own lock when it
  installs.
- Four more descriptions compete for triggering. Each names its own artifact or
  its own question, and `scripts/test-routing.sh` fails when two descriptions
  answer the same words.
- The four skills are tested by `evals/run.sh` (each rule present, one owner per
  artifact) plus a live rubric in `evals/README.md`. No model call: the repo has
  no npm dependency, and a non-deterministic check in a terminal is unreadable.
