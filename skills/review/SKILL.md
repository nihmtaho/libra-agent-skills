---
name: review
description: Review a change against its task, tests and docs, and return a verdict bound to one commit. Use when a branch or PR is ready to merge, or when someone asks whether a change is safe.
---

# review

A verdict is bound to a commit, otherwise it means nothing. This skill reads the
diff, runs the checks, and answers with `PASS <sha>` or `FAIL` plus findings.
It changes no code.

## When to use

Use when a branch, PR or uncommitted change is claimed ready, or when the human
asks whether something is safe to merge.
Not for reviewing the session's own fresh work: use a new session, or a subagent
when the harness has one.

## Read first

1. The task file and the spec the change belongs to.
2. `docs/PROJECT.md` for the project's commands and current state.
3. The diff against the branch base, not against the last commit.

## Steps

1. Confirm this session did not write the code under review. If it did, stop and
   say so: ask for a fresh session, and when the harness can spawn one, hand it
   this file and the diff range.
2. Run the project's check command exactly as `## Chạy & kiểm chứng` says; read
   the output yourself.
3. Read the diff in full, plus the callers of what it changes.
4. Judge five axes, and for each finding say which axis:
   does it do what the task's acceptance line says; is it safe with bad input;
   can the next reader follow it; is the behavior tested, including one failure
   path; do `PROJECT.md`, the spec and the task file still tell the truth.
5. Check the five ways a bar gets lowered, because a green suite proves nothing
   if the bar moved: a threshold or budget lowered, a test made easier (`skip`,
   deleted file, assertions removed), a checker silenced (new `@ts-ignore`,
   `eslint-disable`, coverage ignore), unfinished work (a stub that throws, an
   empty catch, a TODO where the code should be), or a new exception nobody
   discussed.
6. Label every finding `Nit`, `Optional` or `FYI`. Anything that must be fixed is
   not labelled; it is a FAIL.
7. Verdict: `PASS <full sha>` only when the check is green, no finding is
   blocking, and the docs above are true. Otherwise `FAIL` with the blocking list.

## Write

none — read-only. The verdict goes in the reply or the PR comment, carrying the
full commit sha.

## Stop

Stop when the head commit changes during review: re-run against the new sha. Never
carry a PASS from one commit to another, and never review a diff you did not read.
