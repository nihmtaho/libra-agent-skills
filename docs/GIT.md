---
title: How this repository uses git
updated: 2026-11-18
---
# How this repository uses git

One page, so the next contributor does not have to infer the workflow from
`git log`. The rules come from `git-workflow-and-versioning`; this file is where
this repository records its own choices.

## Branching model

Trunk-based. `main` is the only long-lived branch and it is always releasable.

A **documentation or configuration commit may go straight to `main`** when it
changes no behaviour and needs no review: a typo, a README count, a task file.
Anything that changes behaviour — a skill rule, a script, an eval — lands on a
short branch named `<type>/<slug>` and is merged the same day.

The exception above is deliberate and is recorded here rather than assumed. It
was decided in [ADR-0003](adr/0003-direct-commits-need-a-recorded-exception.md),
together with the reason both extremes were rejected.

## Merge policy

The decision follows the branch's commits, not preference:

| The branch's commits | Merge as |
|---|---|
| each one passes `bash scripts/test.sh` | fast-forward, so `main` stays a straight line |
| any of them is a work in progress or does not pass | squash first, then fast-forward |

This repository has no merge commits before 2026-11-18 and keeps it that way.

A review verdict is bound to a sha. Any rebase or squash after a `PASS` voids it,
so clean history **before** asking for review and never after.

## Version scheme

`semver`. The version is the git tag `vX.Y.Z` and the heading in `CHANGELOG.md`;
`release` is the only skill that writes either. Before 1.0, a new skill is a minor
and a fix is a patch.

## Commit format

Conventional Commits: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
`build`, `ci`, `chore`, `revert`; an optional `(scope)`; `!` or a
`BREAKING CHANGE:` footer for a break. The subject is imperative, lower case, and
has no trailing period. A body is allowed only when the why is not obvious.

Never a co-author line or an AI signature. This matches the global `git-commit`
convention, so an agent obeying either one satisfies both.
