---
title: One skill owns the git decisions nothing owns today
updated: 2026-11-18
---

# One skill owns the git decisions nothing owns today

## Problem

Four decisions every project makes, and no skill in this set states:

1. **Which branching model.** Trunk-based, git-flow, or long-lived feature
   branches. Nothing names one, so each project invents one and a new contributor
   guesses.
2. **Which merge policy.** Squash, merge commit, or rebase. `ship` says only "the
   project's own mechanism", which is a shrug in a place that needs a rule.
3. **Which version scheme.** `release` knows patch/minor/major but never says
   whether the project uses SemVer, CalVer, or no versions at all.
4. **What a Conventional Commit is.** The phrase appears in
   `incremental-implementation` and `ship`; the types, the scope and the breaking
   marker are never defined, so "Conventional Commits" means whatever the agent
   remembers.

Three rules are already owned and must not move: one slice one commit belongs to
`incremental-implementation` (it is slice policy), merging and closing belong to
`ship`, and cutting a version belongs to `release`. This skill fills the four gaps
and the other three point at it.

## Use cases

1. A project has no `docs/GIT.md`. The agent runs this skill once, asks four
   questions, and writes one page.
2. A feature branch has fourteen commits, six of them `wip`. The agent learns to
   clean them **before** review, not after, and to keep them if each is green.
3. A maintainer asks "squash or keep the commits?". The answer is a rule about the
   commits, not a preference.
4. A branch has forty commits. The skill says the split is wrong and points at
   `incremental-implementation`, instead of hiding the problem in a squash.

## The four decisions

Each one is written into `docs/GIT.md` once, because a project that leaves it
implicit makes every contributor guess.

### Branching model
Trunk-based is the default: short-lived branches, merged at least daily.

**A commit may go straight to the default branch when `docs/GIT.md` says so.**
The exception is real, and it is written down rather than assumed. `ship` already
says a project that commits directly on the default branch has nothing to merge,
"that is normal"; that sentence stays, and `docs/GIT.md` is what makes it true for
a given project.

A long-lived `develop` branch is still a legitimate choice, and it is named with
its reason: a release train, a supported older version, an environment that cannot
deploy every commit. It is not the default.

### When one commit decides for itself

A single, self-contained commit — a documentation fix, a config change, a
follow-up to something already merged — is judged, not legislated. Before it is
made, state the choice in one line:

- **Direct to the default branch** when `docs/GIT.md` allows it, the change is one
  concern and does not change behaviour a reviewer must check.
- **A short branch, then merge** when the change alters behaviour, needs review,
  or a release will be cut from it. `review` returns a verdict for a commit on a
  branch; nothing to merge means nothing to review.

When the choice is unclear, branch. A branch costs one merge; a commit on `main`
costs a revert.

### What the exception changes

- `build`'s branch step becomes a decision it states, not a reminder: which branch,
  why, and whether this commit belongs on the default one.
- `incremental-implementation`'s branch check gains one clause: on the default
  branch, `docs/GIT.md` must allow it and the reply must say so.
- `ship` keeps its direct-commit sentence, with one clause added naming the file
  that allows it. Landing still means merging a
  branch, or, when the project allows it, committing on the default branch — and
  `ship` says which case it is in.
- `release` is unchanged. A tag still comes from the default branch, and the
  "ahead of" gate still asks for a push first.
- This repository writes its own `docs/GIT.md` and follows it. Its earlier history
  stays as it is.

### Merge policy

The decision is a property of the commits, not of taste:

| The branch's commits | Merge as | Why |
|---|---|---|
| each one builds and passes the suite | keep them: `--no-ff` for topology, fast-forward for a linear history | every commit stays a revert point on the default branch |
| any of them is wip, fix, or does not build | squash | a broken commit on the trunk is worse than a lost save point |

Squash destroys the property the requester asked for — "each commit is a save
point" — so it is only correct when the commits were never save points.

A fast-forward or a rebase rewrites shas. In any project that reviews a specific
commit, that invalidates the review: **clean the history before review, never
after a verdict.** This repository learned it the expensive way; the rule belongs
here, not in one project's memory.

### When a branch has too many commits

Two different diseases, and squash cures neither permanently:

- **A dirty history** — `wip`, `fix`, `fix again`. `git rebase -i` into three or
  four coherent commits, then review the new sha.
- **A branch that lived too long** — the feature is too big. Squashing forty
  commits hides two weeks of divergence. Cut it and land slices; that is
  `incremental-implementation`'s job.

The threshold, stated so it can be argued with: **days since the branch last
landed anything, and commits that are not individually green** — not branch age
and not commit count. A clean branch that lands a green slice every day is
short-lived work, however many slices it takes; that is exactly the pattern
`incremental-implementation` prescribes. A branch that has not landed anything
for two days, or that carries more than ten commits that are not green, gets cut.
Counting commits alone would punish the slice-per-commit discipline this set
requires.

### Version scheme and the commit standard

One scheme per project, written down: `semver` or `none`, and where the version
lives. SemVer is the default; `none` is honest for a project that ships
continuously and never tags. CalVer is out of scope: a project that needs it says
so in `docs/GIT.md` and `release` stops rather than guessing.

`release` reads the scheme and never infers it:

- `semver` (or no `docs/GIT.md` at all): the patch/minor/major rule it already
  has applies, and it says in one line that it assumed SemVer.
- `none`: stop before the changelog. A project that does not version does not
  want a tag it will never use.
- anything else: stop and report the scheme it found.

Conventional Commits, defined once: `feat`, `fix`, `docs`, `style`, `refactor`,
`perf`, `test`, `build`, `ci`, `chore`, `revert`; an optional `(scope)`; `!` or a
`BREAKING CHANGE:` footer for a break; the subject in the imperative, lower case,
no trailing period; a body only when the why is not obvious. Never a co-author
line or an AI signature unless the project or the platform requires one: format,
not concealment.

## What changes around them

- New skill `git-workflow-and-versioning`, 27 skills in total. `## Write`:
  `docs/GIT.md` — branching model, merge policy, version scheme, commit types.
- `incremental-implementation` step 4 points at it for the commit format instead
  of restating Conventional Commits; the slice policy stays, and the literal
  words "Conventional Commits" stay because an eval asserts them. Its branch
  check gains one clause: on the default branch, `docs/GIT.md` must allow it and
  the reply must say so.
- `ship` step 6 keeps its direct-commit sentence and points at `docs/GIT.md` for
  whether this project allows it. It gains one fallback: no `docs/GIT.md`, say so
  in one line and use the project's own mechanism. A project installed before this
  skill must still land work, so this is a fallback, not a new `## Stop`.
- `release` step 2 reads the scheme and becomes conditional: `semver` or missing
  file keeps the patch/minor/major rule and says it assumed SemVer; `none` stops
  before the changelog; any other scheme stops and reports it. Its `## Stop` gains
  those two conditions.
- `build` gains one step: run this skill when the project has no `docs/GIT.md`,
  and state branch-or-direct before the first commit.
- `using-libra` gains **no row** — `build` dispatches the ninth skill the same way
  it dispatches the eight, and the table routes a phase. Its one sentence "the
  eight skills it dispatches" becomes "nine". The file stays 79 lines.
- `bootstrap-project` asks a third question — does this project use git, and with
  which workflow — records the answer as one line under `## Decisions`, and hands
  off to `git-workflow-and-versioning` for `docs/GIT.md`. Both places that say
  "exactly two questions" change to three. A project with no repository is told
  how to start one; a project with one is asked which branch is the default.
- This repository gets its own `docs/GIT.md`, so the format is dogfooded rather
  than shipped untested: trunk-based, short branches, fast-forward merges,
  SemVer, Conventional Commits, and one line saying whether a single commit may
  go straight to `main`. This repository says yes for a documentation or
  configuration commit with no review needed, and no for anything that changes
  behaviour.
- ADR-0003 exists **now**, written when the decision was made rather than left as
  a task. It records the exception as it stands, rejects "always branch" and
  "never branch" with a reason each, and folds in the other three decisions.
- `decide` and `spec-driven-development` gain the timing rule that would have
  produced that ADR without being asked: `decide` writes the ADR when the decision
  is made, and a spec recording a choice with a rejected alternative hands to
  `decide` before the spec is called done. Both are asserted in `evals/run.sh`.
  This was a real gap: a decision moved twice in one conversation and existed only
  inside a spec until the human asked where the ADR was.
- `README.md`: 26 becomes 27, and the uninstall loop gains the name.
- `docs/PROJECT.md`: H1, `## Module map` (the new `docs/GIT.md`), `## Features`.
- `scripts/test-routing.sh`: one case, worded so it does not steal from
  `incremental-implementation`, `ship` or `release`.
- `evals/run.sh`: one assertion on the merge rule and one on the "before review"
  rule, the Write path, and `docs/GIT.md` added to the one-owner loop.
- `CHANGELOG.md`: one bullet under Unreleased.

## Acceptance criteria

- [x] `bash scripts/test.sh` exits 0 with five green lines, and
      `ls skills | wc -l` prints 27.
- [x] The README loop lists 27 names and the prose says twenty-seven.
- [x] `docs/GIT.md` is the only artifact this skill writes, it is in the
      one-owner loop, and this repository has one.
- [x] Deleting the merge table's "each one builds" row fails `evals/run.sh`.
- [x] Deleting "clean the history before review, never after a verdict" fails
      `evals/run.sh`.
- [x] A routing case sends "squash or keep the commits" to this skill and
      "too big for one change" to `incremental-implementation`.
- [x] `incremental-implementation`, `ship` and `release` each lose no rule; each
      gains a pointer that still reads as its own rule, and `ship` still lands
      work in a project with no `docs/GIT.md`.
- [x] `release` with `scheme: none` stops before the changelog, and with no
      `docs/GIT.md` says it assumed SemVer.
- [x] `using-libra` is still at most 80 lines and its sentence says nine.
- [x] `ship` still says a project that commits directly on the default branch has
      nothing to merge, and names `docs/GIT.md` as what allows it.
- [x] `build` and `incremental-implementation` each state branch-or-direct before
      a commit, and name `docs/GIT.md` as the record that decides it.
- [x] `bootstrap-project` asks three questions, not two, and hands off to
      `git-workflow-and-versioning`.
- [x] `docs/adr/0003-*.md` exists before any task is cut, is linked from
      `docs/PROJECT.md` `## Decisions`, and names both rejected extremes.
- [x] `decide` says it writes the ADR when the decision is made, and
      `spec-driven-development` hands to it before the spec is called done; both
      assertions fail when the sentence is removed.

## Limits

- The merge policy chooses a default, not a universal. A project with a release
  train may legitimately require merge commits; the skill says how to record that
  deviation in `docs/GIT.md`, not that it is wrong.
- `docs/GIT.md` gets no required sections in `check-docs.sh`: it falls under
  "anything else", generic rules only, so it ships no template.
- CalVer is out of scope. A project that needs it records the scheme and
  `release` stops; supporting it is a change to `release`, not a line here.
- A live routing run costs three passes. Budget one after the change, not during.

## Open questions

None. B was chosen: this skill owns what nothing owns, and the other three point
at it.

Five gaps a fresh builder found on 2026-11-18 are answered in place above: what
`release` does when the scheme is not SemVer, whether the branch threshold fights
`incremental-implementation`, what `ship` does with no `docs/GIT.md`, whether
`using-libra` gains a row, and whether this repository dogfoods the file.

The direct-commit rule moved twice on 2026-11-18: first to forbid it outright,
then back to an exception that must be written in `docs/GIT.md`. The second
answer is the one above, and the ADR records it so a third flip has to argue with
a written decision rather than a memory.

## Out of scope

- Taking the commit rule from `incremental-implementation`, the merge from
  `ship`, or the version rule from `release`. Each keeps its own rule and gains a
  pointer to this skill.
- A git host integration: no `gh` commands beyond what `ship` and `release`
  already run, no CI configuration, no hooks.
- Enforcing any of it mechanically. This skill states the policy; the checker
  lives in `scripts/check.sh` and the project's own CI. Nothing here stops a human
  from running `git commit` on `main`; the skills stop the agent, and a project
  that wants more writes a hook.
