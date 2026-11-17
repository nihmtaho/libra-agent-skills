---
title: Release is its own skill, after ship
updated: 2026-11-17
---
# Release is its own skill, after ship

## Problem
`ship` defers version work with "that is a separate decision", and no skill owns
it: `CHANGELOG.md` and the tags have no owner. The v0.1.2 release was cut from
whatever branch was checked out, with no gate on the default branch, a clean tree
or a pushed commit, because there was nothing to run. A dangling pointer is how
`write-spec` stayed referenced after it was deleted.

## Use cases
1. A maintainer cuts v0.1.3 three weeks later; the skill refuses until the default
   branch is clean, pushed and free of that tag.
2. A user upgrading reads the changelog section the release wrote, not a rewritten
   summary of it.
3. A reader asks why release is not part of `ship`, and finds the answer in one
   line in both skills.

## Structure
- `skills/release/SKILL.md` — the new skill: four git gates, version rule,
  changelog first, annotated tag, pushed, notes copied, verified by command.
- `skills/ship/SKILL.md` — names `release` instead of "a separate decision", and
  says what to do when a project commits directly on the default branch.
- `skills/using-libra/SKILL.md` — one row, so the phase is reachable.
- `README.md` — the count and the uninstall loop (the checker enforces the loop).
- `evals/run.sh` and `scripts/test-routing.sh` — the gates must be written down,
  and "cut a version" must route here, "verdict passed" to `ship`.
- `CHANGELOG.md` — an `Unreleased` section for this skill.

## Code style
- The set's voice: short declarative sentences, a command where a command exists.
- One line per skill in the changelog, never per file.
- The gates are the commands as typed, not a description of them.

## Test plan
- `bash scripts/test.sh` — five green lines.
- `bash evals/run.sh` — fails when any of the five gate commands is removed from
  the skill; proven by deleting one and re-running.
- `bash scripts/test-routing.sh` — "cut a version" reaches `release`, "verdict
  passed" still reaches `ship`.
- Failure path: a release attempted on a feature branch must be refused by gate
  one, and the skill must say which gate failed.

## Acceptance criteria
- [x] `bash scripts/test.sh` exits 0 with five green lines.
- [x] `bash evals/run.sh` fails after any one of the five gate commands is
      removed from `release`.
- [x] `bash scripts/test-routing.sh` maps "cut a version" to `release` and
      "verdict passed" to `ship`.
- [x] `ls skills | wc -l` prints 18, and the README uninstall loop lists all 18.
- [x] `release`'s `## Write` names `CHANGELOG.md` and `docs/PROJECT.md`, and its
      `## Stop` names the four gates.

## Out of scope
- A version bump command or a release automation workflow: the gates are commands
  a human reads, not a program to debug.
- Publishing to a package registry, or signing artifacts.
- Splitting `verify` from `ship`, or changing what `review` checks.
