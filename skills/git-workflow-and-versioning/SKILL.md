---
name: git-workflow-and-versioning
description: Decide the branching model, the merge policy, the version scheme and the commit format before they are needed. Use when a project has no git policy written down, or when asking whether to squash or keep the commits.
---

# git-workflow-and-versioning

Four decisions every project makes anyway, and most make by accident. Written
down once, they stop being a discussion at every merge.

## When to use

Use when a project has no `docs/GIT.md`, when a branch is about to be merged and
nobody knows whether to squash it, when a version is about to be cut and the
scheme was never named, or when the human asks which workflow this project uses.
Not for making a commit: that is `incremental-implementation`. Not for merging a
change that passed review: that is `libra-ship`.

## Read first

1. `git rev-parse --abbrev-ref HEAD` and `git log --oneline -10` — what this
   project actually does, which beats what its README claims.
2. `docs/PROJECT.md` `## Module map` and `## Decisions`.
3. `docs/adr/`, for a decision that already covers part of this.

## Steps

1. Branching model. Trunk-based by default: short-lived branches, merged at least
   daily. A commit may go straight to the default branch only when this file says
   so. A long-lived `develop` is legitimate with a reason: a release train, a
   supported older version, an environment that cannot deploy every commit.
2. The single commit. State branch-or-direct before the first edit; create the branch then. Direct
   only when this file allows it and the change is one concern that does not alter
   behaviour; a short branch when it alters behaviour, needs review, or a release
   will come from it. Unclear means branch: a branch costs a merge, a commit on
   the default branch costs a revert.
3. Merge policy, decided by the commits and not by taste:

   | The branch's commits | Merge as |
   |---|---|
   | each one builds and passes the suite | keep them: `--no-ff`, or fast-forward for a linear history |
   | any is wip, a fixup, or does not build | squash |

   Squash destroys "every commit is a save point", so use it only when the commits
   were never save points. A rebase or fast-forward rewrites shas: in a project
   that reviews a commit, that voids the review. Clean the history before review,
   never after a verdict.
4. Too many commits is two diseases. A dirty history is `git rebase -i` into three
   or four coherent commits before review — only on your own unpushed branch, never
   on one someone else has. A branch that lived too long is a slice
   problem: hand back to `incremental-implementation`. Count days since the branch
   last landed anything, and commits that are not green — never the commit count,
   which would punish one-slice-per-commit work.
5. Version scheme. `semver` or `none`, and where the version lives. SemVer is the
   default; `none` is honest for a project that ships continuously and never tags.
   `release` reads this and never infers it.
6. Commit format. Conventional Commits: `feat`, `fix`, `docs`, `style`, `refactor`,
   `perf`, `test`, `build`, `ci`, `chore`, `revert`; an optional `(scope)`; `!` or
   a `BREAKING CHANGE:` footer for a break; an imperative, lower-case subject with
   no trailing period; a body only when the why is not obvious. Never a co-author
   line or an AI signature unless the project or the platform requires one —
   format, not concealment.
7. Write `docs/GIT.md`, one page. `libra-bootstrap-project` records the one-line
   decision in `## Decisions`; a project past bootstrap lets `libra-decide` do it.
   For the GitHub side — required checks, reviews, rulesets, auto-merge — follow
   `references/branch-protection.md`. Apply a policy only after the human approves
   it, and never bypass it with `--admin`.

## Write

`docs/GIT.md` — the four decisions, one page. This skill writes nothing else.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when the human has not chosen the branching model and no practice is visible
in the history, or when two documents disagree about the version scheme. A policy
nobody chose is worse than none, because the next reader will follow it.
