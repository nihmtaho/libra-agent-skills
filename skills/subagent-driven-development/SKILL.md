---
name: subagent-driven-development
description: Run independent tasks in parallel, each in a fresh context, and keep the commit with the parent. Use when two or more tasks touch disjoint files and can run without waiting for each other.
---

# subagent-driven-development

Parallel work is a bet that the pieces do not touch. Make the bet by path, before
dispatch, not by hope afterwards. A subagent that commits is a branch nobody
reviewed.

## When to use

Use when two or more tasks in `docs/tasks/` touch disjoint paths and can run at
the same time.
Not for a task that needs another's output first, and not when the tasks share a
file. A read-only search is `context-engineering`; a second opinion is
`doubt-driven-development`'s question, and it uses this skill to run the fresh
context.

## Read first

1. The task files, especially each `Touches:` and `Done means:` line.
2. The spec clause each task implements, quoted, so the subagent never guesses it.
3. `docs/PROJECT.md` `## Run & verify` for the command every subagent must run.

## Steps

1. Build the overlap table: which tasks share a path. Any pair sharing one runs in
   series, however small the shared change looks.
2. Give each subagent four things and nothing more: the task file, the spec
   clause, the command that must go green, and the rule that it may not touch
   files outside `Touches:`. The `Touches:` limit is mandatory; a subagent
   without it is not dispatched. For a doubt pass there is no task file: hand
   the claim and the question instead, and ask for the strongest case against it.
3. Ask each for three things back: files changed, the real output of the command,
   and what it could not verify. Not a summary of how it felt.
4. Run the suite yourself after each return, not once at the end. A subagent's
   green is not the project's green: it may have run a subset, or the wrong
   version.
5. Commit from the parent, one slice at a time. A subagent never commits, never
   pushes, and never ticks a box; the parent records the slice through
   `incremental-implementation`.
6. If two returns changed the same file, the split was wrong. Say that in one
   line in your reply, land one, rerun the other, and record its stop point.

## Write

`none` — the parent records the work in the task file. A subagent returns work;
it does not record it.

## Stop

Stop when the overlap table shows a shared path after dispatch, when the
acceptance line cannot be quoted to the subagent, when a subagent reports green
but the parent's run is red, or when the parallel run is slower than doing the
work. Report which one.
