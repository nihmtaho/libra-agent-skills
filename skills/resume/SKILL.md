---
name: resume
description: Read the project state and say where work stands. Use when returning to a project after a break, when a session starts, or when asked what is done and what is next.
---

# resume

The four lines this skill prints are the whole point of this set: what this is,
where it stands, what is half-done, what is next. It reads and reports; it
changes nothing.

## When to use

Use at the start of a session in a project that has `docs/PROJECT.md`, after a
long break, or when the human asks "where were we".
Not for continuing work you are already inside; that is `build`.

## Read first

1. `docs/PROJECT.md` — the feature table and `Tiếp theo`.
2. The task file in `docs/tasks/` linked from any `in progress` row.
3. `git log --oneline -10` for what changed most recently.

## Steps

1. No `docs/PROJECT.md`? Stop and say to run `bootstrap-project`. Do not create
   the file here, and do not fall back to reading the whole repo.
2. Read the feature table. A row marked `in progress` is the work in progress;
   read its `Dừng ở` cell and the unchecked boxes in the task file.
3. Check drift per `in progress` row. Take the paths from the task file's
   `Đụng:` lines and compare the last commit that touched the document with the
   last commit that touched those paths:

   ```bash
   git log -1 --format=%H -- docs/tasks/<feature>.md
   git log -1 --format=%H -- <path từ dòng Đụng:>
   ```

   If the two SHAs are equal, the document and the code changed together: the
   document is current, say nothing. If the document's commit is an ancestor of
   the code's commit (`git merge-base --is-ancestor <doc> <code>`), the document
   is behind the code: say `lệch: <file> cũ hơn code`. With no git, or a shallow
   clone, print `không biết` and never claim it is current.
4. Print exactly four lines, no paragraphs:
   `Là gì:`, `Đang ở:`, `Dở:`, `Tiếp:`. `Dở:` names the file and the unchecked
   box; `Tiếp:` copies the first item of `Tiếp theo`.

## Write

none — read-only skill.

## Stop

Stop after the four lines. Do not start the work they name, and do not fix a
document you found stale; that belongs to the session that changed the code.
