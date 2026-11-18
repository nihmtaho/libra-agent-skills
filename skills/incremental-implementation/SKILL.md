---
name: incremental-implementation
description: Land work in thin slices that each leave the project working, behind a flag when a slice is risky. Use when a task is too big or too risky to land safely, or when a change needs a rollback path.
---

# incremental-implementation

A change that can only land whole cannot be reviewed, cannot be rolled back, and
teaches nothing until it is done. This skill cuts it so every slice is a working
project.

## When to use

Use when a task will not fit in one sitting, when a slice would be user-visible
before it is finished, when a migration must run beside the old path, or when a
change is expensive to undo.
Not for a change that is already one file and one commit: write it, test it, land
it.

## Read first

1. `docs/tasks/<feature>.md` — the task's `Done means:` and what is already
   ticked.
2. `docs/specs/` — the shape the finished thing must have, so the slices add up
   to it.
3. Existing flags in the code. Reuse the mechanism the project already has; a
   second flag system is a second thing to delete.

## Steps

1. Cut the task into slices that each leave the suite green and the app running.
   A slice that needs two days before anything is green is not a slice: cut again.
2. Order by value and by risk, smallest reversible piece first. The slice that
   proves the idea works comes before the slice that polishes it.
3. Put a slice behind a flag when it is user-visible and incomplete. Default off,
   named for the feature, read in one place. The flag is part of the slice, not a
   follow-up.
4. One slice, one commit, in the format `docs/GIT.md` names: Conventional
   Commits, English, and never a co-author line or an AI signature unless the
   project or the platform requires one — format, not concealment.
5. Before the first commit, say which branch you are on and which one the task
   expects: `git rev-parse --abbrev-ref HEAD`. A commit on a branch you did not
   choose is a merge nobody planned, and the mistake is invisible until release
   time. On the default branch, `docs/GIT.md` must allow the commit and the reply
   must say so; without that file, do not guess.
6. Tick the box in `docs/tasks/<feature>.md` as each slice lands. When you stop
   mid-task write the exact position in `Stopped at:`, for example
   `T2, retry not on yet`. A position someone can resume from, not a mood.
7. Delete the flag when the feature is complete, in the same change that makes it
   complete. A flag nobody removes is a branch that lives forever.

## Write

`docs/tasks/<feature>.md` — the checkbox and `Stopped at:` — and
`docs/PROJECT.md` when the feature row changes.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when a slice cannot be green on its own, when the acceptance line cannot be
checked, when two slices would touch the same lines (land one, then the other),
or when the branch you are on is not the one you said. Report which one.
