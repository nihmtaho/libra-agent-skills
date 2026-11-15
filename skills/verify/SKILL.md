---
name: verify
description: Prove the work runs before claiming it does. Use when about to say something works, before a review, and before shipping.
---

# verify

"Looks right" is not a result. This skill exists so that every claim about the
software is backed by output you just read.

## When to use

Use before claiming a task is done, before asking for review, and any time you
are about to write "should work" or "probably fine".
Not for exploration; exploring has no claim to prove.

## Read first

1. `docs/PROJECT.md` `## Chạy & kiểm chứng` — the project's own commands.
2. The task's `Xong nghĩa là:` line.
3. The output of the last run, if there is one, to see what changed since.

## Steps

1. Run the command exactly as written in `## Chạy & kiểm chứng`. No flags removed,
   no subset, no "just the relevant test" unless the line says so.
2. Read the whole output, including warnings and skipped tests. A skip is not a
   pass.
3. Paste the real tail of the output in your reply. Never summarise a failure as
   "some tests fail".
4. If the correct command changed, update `## Chạy & kiểm chứng` in the same
   session. A stale command is how the next person loses an hour.
5. When the output is red, stop and report. Do not fix the test here; that is
   `debug`.

The quality floor: do not delete a test, add a skip, loosen a threshold, or drop
a lint rule to get green. If the floor itself is wrong, say so and ask; lowering
it silently is the one failure this set cannot detect from the outside.

## Write

`docs/PROJECT.md` `## Chạy & kiểm chứng`, only when the command or its expected
signal changed.

## Stop

Stop when the command cannot be run at all (missing toolchain, missing permission)
and say what is missing. Do not report a pass you did not see.
