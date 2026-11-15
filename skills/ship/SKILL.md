---
name: ship
description: Close a change by proving it, keeping the docs true, then merging. Use when a review has passed and the work should land, or when asked whether something is ready to merge.
---

# ship

The last gate. Everything before this argued; this checks the argument still
holds at the commit being merged, and leaves the project readable for whoever
arrives next.

## When to use

Use when a review returned `PASS <sha>` for the head commit, or when the human
asks if something is ready to land.
Not for tagging or publishing releases; that is a separate decision.

## Read first

1. The verdict, including the full sha it was given for.
2. `git rev-parse HEAD` and `git status --short`.
3. The feature row in `docs/PROJECT.md` and its task file.

## Steps

1. Compare `git rev-parse HEAD` with the sha in the verdict. Any difference means
   the PASS does not apply: stop and ask for a review of the new sha.
2. Run the check command from `## Chạy & kiểm chứng` one more time on this exact
   commit. A stale green is not green.
3. Make the docs true: the feature row says `done`, `Dừng ở` is empty, the task
   file is deleted (git keeps the history), and `PROJECT.md`'s `updated` date is
   today. If `plan-work` opened a feature issue, close it now; an open issue is a
   second stale copy of the status. A shipped change with a lying state file is
   not shipped.
4. Set `## Tiếp theo` to three items, the first one small.
5. Merge with the project's own mechanism. Commit and PR titles use Conventional
   Commits, English, and never carry a co-author line or an AI signature.
6. Report what landed, the sha, and the one thing most likely to break first.

## Write

`docs/PROJECT.md` — the feature row, `Tiếp theo`, the date — and deletion of
`docs/tasks/<feature>.md`.

## Stop

Stop when the verdict is missing or bound to another sha, the check is red,
the docs still disagree with the code, or the merge would go to a shared branch
nobody approved. Report which condition failed.
