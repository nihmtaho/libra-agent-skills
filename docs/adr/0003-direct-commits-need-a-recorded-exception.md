---
title: A direct commit needs a recorded exception, and one commit is judged
updated: 2026-11-18
---
# A direct commit needs a recorded exception, and one commit is judged

## Context
The Build phase already commits, and the git decisions around those commits were
owned by nobody: which branching model, which merge policy, which version scheme,
and what a Conventional Commit is. `ship` deferred merging to "the project's own
mechanism" and allowed a project that commits directly on the default branch,
calling that normal. This repository does exactly that, while the global
`git-commit` convention forbids it, so the same action was correct in one place
and forbidden in another.

The rule moved twice while designing `git-workflow-and-versioning`: first a
blanket "nothing is committed to the default branch", then back to an exception.
The second answer is recorded here, and the first is listed as rejected, so a
third move has to argue with this file rather than with a memory.

## Decision
- Trunk-based is the default: short-lived branches, merged at least daily.
- A commit may go straight to the default branch **only when `docs/GIT.md` says
  so**. The exception is written in the project's own file, not assumed from the
  skill.
- A single self-contained commit is judged, not legislated: state branch-or-direct
  in one line before making it. Direct when `docs/GIT.md` allows it and the change
  is one concern that does not change behaviour; a short branch when the change
  changes behaviour, needs review, or a release will be cut from it. When unclear,
  branch: a branch costs one merge, a commit on `main` costs a revert.
- `ship` keeps its sentence that nothing to merge is normal, and names
  `docs/GIT.md` as what makes it true for a project.
- `release` is unchanged: a tag still comes from the default branch, and the
  "ahead of" gate still asks for a push first.

## Rejected options
- **Nothing is ever committed to the default branch.** Cheapest to enforce, but it
  contradicts `ship` as written and this repository's own practice, and it makes
  a one-line documentation fix cost a branch and a merge.
- **Committing on the default branch is always normal**, as `ship` said before.
  A rule with an unconditional exception for the most common case is not a rule:
  the same action is then both correct here and forbidden by the global
  `git-commit` convention, and nothing in either place says which wins.
- **Record the exception in `docs/CONSTRAINTS.md`.** That file is the quality bar
  a check can prove; a branching model is policy, not a check, and putting it
  there would mix two documents with two audiences.
- **Let the merge policy be decided per merge, by taste.** Squash and merge commit
  have different costs, and a team that picks per merge gets both histories.
  The policy is a property of the commits, so it is decided once.

## Consequences
- Every project must write `docs/GIT.md` before its first commit, or say in one
  line that it has none and use its own mechanism. `bootstrap-project` asks the
  question; `git-workflow-and-versioning` writes the file.
- A project with no file is not blocked: `ship` and `release` fall back and say
  what they assumed.
- This repository's own `docs/GIT.md` allows a documentation or configuration
  commit straight to `main`, and requires a branch for anything that changes
  behaviour. Its history before this ADR stays as it is.
- The rule is enforced by the skills, not by git. Nothing stops a human from
  running `git commit` on `main`; a project that wants that writes a hook.
- Squash is only correct when the branch's commits were never save points, so the
  requested property — every commit a revert point — survives on the default
  branch whenever the commits were green.
