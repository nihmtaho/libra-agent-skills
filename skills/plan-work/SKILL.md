---
name: plan-work
description: Cut an approved spec into three to seven ordered tasks, before any code exists. Use when the spec is accepted and implementation has not started.
---

# plan-work

A plan is not a list of chores. It is the smallest set of pieces that each leave
the project working, in an order where nothing is blocked. One file per feature,
deleted when the feature ships.

## When to use

Use when a spec exists and someone is about to write code, or when a task feels
too large to start.
Not when there is no spec: run `write-spec` first. A plan without acceptance
criteria is a wish list.

## Read first

1. The spec in `docs/specs/`.
2. `docs/PROJECT.md` `## Module map`, to know which paths a task will touch.
3. `docs/tasks/` for a file already open on this feature.

## Steps

1. Check the spec has acceptance criteria. If it does not, send it back to
   `write-spec`; do not invent criteria here.
2. Draw dependencies: which task must finish before another can start. A cycle
   means the split is wrong; split by outcome instead.
3. Cut vertical slices: each task crosses the layers it needs and leaves the
   project runnable. Never "all of the database, then all of the UI".
4. For each task write: name, `Done means:` as one command or one observation,
   `Touches:` the paths, and `Depends on:` when it has one.
5. Put a checkpoint after the first task and after the last: the command to run
   and what green looks like.
6. Three to seven tasks. More means the spec is too large: go back and cut scope,
   do not shrink tasks until they fit.
7. Write the file, set the feature row to `in progress`, and link the task file in
   its `Docs` cell.
8. GitHub issues, only when `docs/PROJECT.md` frontmatter says `issues: on` and
   `gh` works: open one issue per feature (never one per task). Title is the
   feature name; body is the goal, a link to the spec, the acceptance summary, and
   the path `docs/tasks/<feature>.md`. Never copy the checklist into the issue: the
   file is the list, and a copy starts lying the first time a box is ticked.
   Record the number as `issue:` in the task frontmatter. No `gh`, or the command
   errors: skip the issue, say so, and do not block the plan. With more than one
   remote or more than one signed-in GitHub host, pass `--repo <owner/name>`
   explicitly; `gh` otherwise picks a host you did not mean.

## Write

`docs/tasks/<feature>.md`, the feature row in `docs/PROJECT.md`, and at most one
GitHub issue for the feature.

## Stop

Stop when a task cannot be described without a decision the spec does not make:
that is a spec gap, not a planning problem. Say which sentence is missing.
