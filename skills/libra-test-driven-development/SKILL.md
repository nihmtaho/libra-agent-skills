---
name: libra-test-driven-development
description: Write the failing test first, then the smallest code that passes, then refactor. Use when a behaviour has no failing test yet, or when a test was written after the code.
---

# libra-test-driven-development

A test written after the code proves only that the code does what it does, which
nobody doubted. The order is the point: red, then green, then clean.

## When to use

Use when a behaviour must exist and no test names it yet, when fixing a bug that
has no reproduction, and before the first line of any task that changes what the
code does.
Not for a spike the human asked for, and not for a refactor the suite already
covers: run the suite, see green, then change shape.

## Read first

1. The acceptance line in `docs/tasks/<feature>.md`. That line is the test.
2. The tests nearest the change: their names, and how they build their data.
3. `docs/PROJECT.md` `## Run & verify` — the one command that must go green.

## Steps

1. Write one test for the acceptance line. Name it after the behaviour, not the
   function: "refuses a second transfer in the same minute" beats "testTransfer".
2. Run it and read the failure. Assert it fails for the right reason. A test that
   passes before any change is a test of nothing: fix the test, not the code.
3. Write the smallest code that makes it pass. Not the shape you would like, the
   shape the test needs. Run the whole command from `## Run & verify`, not only
   the new test.
4. With the suite green, refactor in its own commit. Green before, green after,
   behaviour unchanged.
5. Repeat for the next behaviour. One test, one reason to fail: a test that fails
   for three reasons tells you nothing about which one broke.
6. Keep the pyramid 80/15/5: most tests are unit tests over one behaviour, some
   integration tests across one boundary, a few end-to-end paths a human would
   actually take. Say which level a test sits at when it is not obvious.
7. Prefer DAMP to DRY in tests. A test repeats its setup on purpose, because the
   data is what the test says. A helper that hides the data hides the failure.
   Duplication in a test is cheaper than a test nobody can read.
8. A bug fix starts with a test that fails for the reason the bug is real. If you
   cannot make it fail, you have not found the bug. Write it in this session; a
   proposed test is not a test.

## Write

`none` — this skill writes code and tests. The task file belongs to
`libra-incremental-implementation`, and a weakened check belongs to
`libra-constraint-driven-development`.

## Stop

Stop when the acceptance line cannot be observed by a test, when the test needs a
network, a credential or minutes to run (say so and ask for a seam), when making
the test pass would require disabling a check, or when a test you wrote passes
before the change. Report which one, with the command output.
