---
name: libra-build
description: Start one ready task and name which build skill runs, in what order. Use when a task in `docs/tasks/` is ready to implement.
---

# libra-build

One task at a time, and the order is not yours to choose. This skill is the
dispatcher for the Build phase: it says which skill runs next, so the discipline
is a rule rather than a preference.

## When to use

Use when `docs/tasks/` has an unchecked task with a `Done means:` line, or when
picking up one finding from `libra-change-review`.
Not when there is no task or acceptance line (`libra-plan-work`), no spec behind the
task (`libra-spec-driven-development`), or something already fails and the cause is
unknown (`libra-root-cause`).
Not for a question about the code or the task: answer it and stop; a question is
not a change request.

## Read first

1. The task file, especially the unchecked task's `Done means:` and `Touches:`.
2. `docs/PROJECT.md` `## Run & verify` for the commands.
3. The spec section this task implements, if the acceptance line is not enough.
4. The task's `Depends on:` line; an unchecked dependency means it is not ready.

## Steps

1. State the task, its lane and its branch in one line. If you cannot, the task
   is not ready. A question is not a task: answer it and stop; do not implement.
   No task file: stop, name `libra-plan-work`, ask for the acceptance line, and write
   nothing. No spec behind the task: stop and name `libra-spec-driven-development`.
   Work only inside the task's `Done means:` and `Touches:`; anything else is a
   new task. No branch: create it before touching a file.
2. `libra-test-driven-development` — always, before the first line of code.
3. `libra-incremental-implementation` — always, for how much lands in one commit.
   Steps 2 and 3 are the reason this skill exists: a task that skips them is not
   done, whatever the suite says. A slice that is not committed and ticked is
   not landed.
4. `libra-git-workflow-and-versioning` when the project has no `docs/GIT.md`, and in
   every case state branch-or-direct before the first commit: which branch, and
   whether this commit belongs on the default one.
5. `libra-context-engineering` when the task's `Read first` does not reach the code you
   must change.
6. `libra-source-driven-development` when the work rests on a framework, library or API
   fact you cannot prove from the repository.
7. `libra-frontend-ui-engineering` when the work changes a user interface, or
   `libra-api-and-interface-design` when it changes an API, a response shape or an
   error format.
8. `libra-subagent-driven-development` when two tasks touch disjoint files. The parent
   still commits.
9. `libra-doubt-driven-development` before saying the task is done, when the decision
   rests on reasoning no command can check.

**Spike mode**, when the human wants to learn rather than ship: none of the
above applies. Build the throwaway, skip the tests, keep it off the main branch,
then write the one thing you learned into `## Decisions` or `## Next`. No other
document comes out of a spike; if it produced documents, it was not a spike.

## Write

`none` — this skill dispatches. `libra-incremental-implementation` ticks the task file
and records the stop, `libra-context-engineering` fills its `Read first`, and
`libra-doubt-driven-development` writes `## Next` when a claim fails.

## Stop

Stop when the acceptance line cannot be checked, when the task needs a decision
the spec does not make, when making a test pass would require disabling a check,
or when a skill named above is not installed. Report which one. Stop also when
the acceptance line already passes, a dependency is unchecked, or the work leaves
`Touches:`. A spike that produced a document has stopped being a spike: say so.
