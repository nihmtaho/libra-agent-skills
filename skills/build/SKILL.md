---
name: build
description: Write code for one unchecked task, failing test first. Use when a task file has a task ready, or when fixing one item from a review.
---

# build

One task, one slice, one commit. The test comes first because a test written
after the code proves only that the code does what it does.

## When to use

Use when `docs/tasks/` has an unchecked task with acceptance criteria, or when
picking up one finding from `review`.
Not for throwaway exploration; that is the spike mode at the end of this file.

## Read first

1. The task file, especially the unchecked task's `Xong nghĩa là:` and `Đụng:`.
2. `docs/PROJECT.md` `## Chạy & kiểm chứng` for the commands.
3. The spec section this task implements, if the acceptance line is not enough.

## Steps

1. State the task in one line, then write the failing test for its acceptance
   line. Run it and read the failure. A test that passes before any change is a
   test of nothing: fix the test first.
2. Write the smallest code that makes it pass. Run the whole check command, not
   only the new test.
3. Refactor only with the suite green, in its own commit.
4. Tick the box, and if you stop mid-task write the exact position in
   `Dừng ở:`, for example `T2, retry chưa bật`. A position someone can resume
   from, not a mood.
5. Commit small, Conventional Commits, and never include a co-author line or an
   AI signature.
6. New dependency or framework decision? Stop and run `decide`; do not bury it
   in this commit.

**Spike mode**, when the human wants to learn rather than ship: build the
throwaway, skip tests, keep it off the main branch, then write the one thing you
learned into `## Quyết định` or `## Tiếp theo`. No other document comes out of a
spike; if it produced documents, it was not a spike.

## Write

`docs/tasks/<feature>.md` — the checkbox and `Dừng ở` — and `docs/PROJECT.md`
when the feature row changes.

## Stop

Stop when the acceptance line cannot be checked, when the task needs a decision
the spec does not make, or when making the test pass would require disabling a
check. Report which one.
