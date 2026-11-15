---
name: bootstrap-project
description: Build docs/PROJECT.md for a brand-new repo or rebuild it from an old one. Use when a project has no state file, or when the state file is stale beyond repair.
---

# bootstrap-project

`docs/PROJECT.md` is the only file that must stay fresh. This skill creates it,
either for a repo that has nothing but an idea, or for a repo that already has
code and history. It writes from evidence and never invents a feature.

## When to use

Use when `docs/PROJECT.md` does not exist, or when `resume` says the file no
longer matches the code.
Not for a small update to an existing file; edit it in the session that changed
the code.

## Read first

New repo (no code, or one commit): nothing. Ask the two questions below.
Old repo: the directory tree, `git log --oneline -20`, the README, and any file
in `docs/imports/`. Skip `node_modules`, `.git`, and vendored or reference
folders.

## Steps

**New repo**

1. Ask exactly two questions: what is this, and who is it for. One sentence each.
2. Write only the title line and `## Tiếp theo` with one item: write a spec.
3. Leave out every other section. An empty section is a false statement about
   the state, and later readers believe it.

**Old repo**

1. List what actually exists: top-level directories, the entry point, the test
   command, the run command. Quote commands you found, not commands you expect.
2. Read the last twenty commits for vocabulary: what the author calls things.
3. Fill `## Bản đồ module`, three to eight lines, each "path → what it does →
   where it breaks".
4. Fill `## Tính năng` from evidence only: a feature is `done` when code and a
   test exist, `in progress` when code exists without a passing test, `planned`
   when only a document mentions it. Mark the `Dừng ở` column with the exact
   place work stops, or leave it empty.
5. Fill `## Chạy & kiểm chứng` by running the commands you found, at least once.
6. Fill `## Tiếp theo` with three items, the first one small enough to finish in
   one session.

**No git history**

Skip the log, and write "chưa có lịch sử git" in `## Tiếp theo`. Do not guess
what was built first.

## Write

`docs/PROJECT.md`. Nothing else: no ADR, no spec, no task file. Those come from
`decide`, `write-spec` and `plan-work`.

## Stop

Stop and ask when the code contradicts itself and no evidence says which side is
current, or when a section would need a decision the human has not made. Say
which section is missing and why; do not fill it with a guess.
