---
name: constraint-driven-development
description: Set the quality bar in `CONSTRAINTS.md` before work starts, and catch a check weakened to make the build pass. Use when a project has no bar written down, or when a test, lint rule or threshold changed to get green.
---

# constraint-driven-development

A green build proves the checks passed, not that they were the right checks. This
skill writes the bar down before the work, and reads the diff for the ways it can
be lowered afterwards.

## When to use

Use when work starts on a project with no `docs/CONSTRAINTS.md`, when a bar must
be agreed before a deadline, and whenever a change touches a test, a lint config,
a coverage threshold, a check script or a CI file.
Not for deciding what to build (`idea-refine`, `spec-driven-development`); a bar
nobody will be held to is ceremony.

## Read first

1. `docs/PROJECT.md` `## Run & verify` — what is checked today, and how.
2. `docs/CONSTRAINTS.md` if it exists. Extend it; never rewrite a bar the human
   set.
3. The diff, when a bar moved. The old value is the truth, not the new one.

## Steps

1. Interview, one question at a time, for each area that applies: correctness
   (what must never be wrong), tests (what must be covered, what a skip means),
   performance (a number, not "fast"), security (what is never logged or stored),
   compatibility (what must not break for existing users), accessibility, and
   sign-off (who may lower a bar). An area that does not apply is written as
   "n/a" with a reason, not left out.
2. For each answer record three things: the bar, the command or observation that
   proves it, and who can lower it. A bar with no check is a wish.
3. Write `docs/CONSTRAINTS.md` from the template. One page.
4. Before claiming anything passes, run the check and compare the numbers to the
   file: coverage, threshold, count of tests, count of skipped tests. A suite that
   went from 40 tests to 39 is a failure until someone says why.
5. When a check is red, the fix is in the code. These are not fixes: deleting or
   commenting a test, a new skip, a looser threshold, a new ignore comment, a
   disabled rule, a check dropped from the script, an empty catch, a stub that
   throws "not implemented".
6. If a bar is genuinely wrong, say which and why, and change it in
   `docs/CONSTRAINTS.md` in the same change, with the human's name and today's
   date next to it. A bar that moved while the file did not is the finding:
   report the before and after value.

## Write

`docs/CONSTRAINTS.md` from the template, and a row in `docs/PROJECT.md`
`## Features` only when writing the bar was the work itself.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when a bar needs a number only the human can give (a latency budget, a
support window). When the human asks to lower a bar, write it down with their name
and continue; that is their call, not a silent one. Never report green without
the numbers next to the file.
