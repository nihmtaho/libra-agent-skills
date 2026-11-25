---
name: libra-simplify-change
description: Remove complexity while keeping behavior identical. Use when code works but is harder to read, change or extend than it should be, or when asked to clean up a change.
---

# libra-simplify-change

Less code, same behavior, proven by the same tests. Understanding why something
exists comes before deciding it should not.

## When to use

Use when the code is correct and the problem is comprehension: a function doing
three jobs, a wrapper that only forwards, an option nobody sets.
Not for changing behavior, and not while a test is red.

## Read first

1. The tests that cover the code. They are the contract; if they are missing,
   write them first and treat that as `libra-build`.
2. `git log -3 -- <file>` and `git blame` on the lines you intend to delete, to
   see what problem each one solved.
3. Any ADR that names this module.

## Steps

1. Name the complexity: duplication, indirection, an unused option, a special
   case that no longer happens. One reason per change.
2. Apply Chesterton's fence: if you cannot say why the line exists, find out
   before removing it. Ask the human when the history is silent.
3. Make one change at a time and run the full suite after each. A refactor that
   also changes behavior is two changes in one commit, and the failing one hides
   the other. One removal, one suite run; do not batch.
4. Delete before adding. A helper that removes two lines is a net loss.
5. Stop when the next removal would change what the code does, or would require
   a new test to keep it safe.

## Write

none — the change is the code and its commit message. If a decision disappears
with the code, add one line to its ADR saying it was removed and why.

## Stop

Stop when the behavior is not provably identical, when the test suite does not
cover the path you are about to touch, or when the only simplification changes
a public contract.
