---
name: debug
description: Diagnose a failure whose cause is unknown, then fix the cause once. Use when a test fails, a build breaks, or behavior contradicts expectation.
---

# debug

Five steps, in order. The point is that the fix follows the cause, not the
symptom, and that the same defect cannot come back quietly.

## When to use

Use when something that should work does not: a failing test, a broken build, an
error in a log, a wrong result.
Not when the behavior is merely undesigned; that is `write-spec`.

## Read first

1. The failing command and its full output, not the summary.
2. `docs/PROJECT.md` `## Run & verify`, to make sure you are running the
   project's own command and not a guess.
3. The task file box that was being worked on when it broke.

## Steps

1. Reproduce with the smallest command that shows the defect, and paste the exact
   output. If it does not reproduce, say so and stop; a fix without a
   reproduction is a guess.
2. Narrow with evidence: bisect by input, by path, by commit. State what the
   evidence rules out after each step.
3. Shrink to the smallest case that still fails. A one-line reproduction is worth
   ten paragraphs of theory.
4. Fix the cause once, in the code path all callers share. Patching each caller
   is how one bug becomes three.
5. Add the regression test that fails before the fix and passes after. Run it
   before and after; if you did not watch it fail, you do not know it tests the
   defect.

## Write

The regression test, and the one line in `docs/tasks/<feature>.md` that records
what was actually wrong when it is not obvious from the test name.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop and report when the cause is a design decision rather than a defect, when
the only way to green is to weaken a test or disable a check, or when the fix
would change behavior outside the task's scope.
