---
name: build
description: Start one ready task and name which build skill runs, in what order. Use when a task in `docs/tasks/` is ready to implement.
---

# build

One task at a time, and the order is not yours to choose. This skill is the
dispatcher for the Build phase: it says which skill runs next, so the discipline
is a rule rather than a preference.

## When to use

Use when `docs/tasks/` has an unchecked task with a `Done means:` line, or when
picking up one finding from `review`.
Not when there is no acceptance line (that is `plan-work`), and not when
something already fails and the cause is unknown (that is `debug`).

## Read first

1. The task file, especially the unchecked task's `Done means:` and `Touches:`.
2. `docs/PROJECT.md` `## Run & verify` for the commands.
3. The spec section this task implements, if the acceptance line is not enough.

## Steps

1. State the task in one line. If you cannot, the task is not ready.
2. `test-driven-development` — always, before the first line of code.
3. `incremental-implementation` — always, for how much lands in one commit.
   Steps 2 and 3 are the reason this skill exists: a task that skips them is not
   done, whatever the suite says.
4. `git-workflow-and-versioning` when the project has no `docs/GIT.md`, and in
   every case state branch-or-direct before the first commit: which branch, and
   whether this commit belongs on the default one.
5. `context-engineering` when the task's `Read first` does not reach the code you
   must change.
6. `source-driven-development` when the work rests on a framework, library or API
   fact you cannot prove from the repository.
7. `frontend-ui-engineering` when the work changes a user interface, or
   `api-and-interface-design` when it changes an API, a response shape or an
   error format.
8. `subagent-driven-development` when two tasks touch disjoint files. The parent
   still commits.
9. `doubt-driven-development` before saying the task is done, when the decision
   rests on reasoning no command can check.

**Spike mode**, when the human wants to learn rather than ship: none of the
above applies. Build the throwaway, skip the tests, keep it off the main branch,
then write the one thing you learned into `## Decisions` or `## Next`. No other
document comes out of a spike; if it produced documents, it was not a spike.

## Write

`none` — this skill dispatches. `incremental-implementation` ticks the task file
and records the stop, `context-engineering` fills its `Read first`, and
`doubt-driven-development` writes `## Next` when a claim fails.

## Stop

Stop when the acceptance line cannot be checked, when the task needs a decision
the spec does not make, when making a test pass would require disabling a check,
or when a skill named above is not installed. Report which one. A spike that
produced a document has stopped being a spike: say so.
