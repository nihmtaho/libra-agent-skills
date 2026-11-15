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
2. `docs/PROJECT.md` `## Bản đồ module`, to know which paths a task will touch.
3. `docs/tasks/` for a file already open on this feature.

## Steps

1. Check the spec has acceptance criteria. If it does not, send it back to
   `write-spec`; do not invent criteria here.
2. Draw dependencies: which task must finish before another can start. A cycle
   means the split is wrong; split by outcome instead.
3. Cut vertical slices: each task crosses the layers it needs and leaves the
   project runnable. Never "all of the database, then all of the UI".
4. For each task write: name, `Xong nghĩa là:` as one command or one observation,
   `Đụng:` the paths, and `Phụ thuộc:` when it has one.
5. Put a checkpoint after the first task and after the last: the command to run
   and what green looks like.
6. Three to seven tasks. More means the spec is too large: go back and cut scope,
   do not shrink tasks until they fit.
7. Write the file, set the feature row to `in progress`, and link the task file in
   its `Tài liệu` cell. If the repo uses GitHub issues
   (`gh repo view --json hasIssuesEnabled` returns true), open one issue for the
   feature with the checklist as its body; never one issue per task. No `gh`, or
   the command errors: skip the issue and say so in the reply, do not block the plan.

## Write

`docs/tasks/<feature>.md`, the feature row in `docs/PROJECT.md`, and at most one
GitHub issue for the feature.

## Stop

Stop when a task cannot be described without a decision the spec does not make:
that is a spec gap, not a planning problem. Say which sentence is missing.
