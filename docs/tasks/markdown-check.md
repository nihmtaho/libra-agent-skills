---
title: markdown check after every write
updated: 2026-11-16
spec: ../specs/markdown-check.md
---
# markdown check after every write

Stopped at: T4 done, T5 not started

## Checkpoint — after T1
`bash scripts/check-docs.sh docs/PROJECT.md docs/specs/markdown-check.md` exits 0
and prints nothing; the same command on a copy with `## Use cases` deleted exits 1
with one `FAIL <path>:<line>: <rule>` line naming `Use cases`.

- [x] **T1 — write the checker**
      Done means: `bash scripts/check-docs.sh docs/PROJECT.md docs/specs/markdown-check.md` exits 0; a broken copy exits 1 with the rule name.
      Touches: `scripts/check-docs.sh`
- [x] **T2 — fixtures, one per rule**
      Done means: `bash scripts/test-check-docs.sh` exits 0 and prints `fixtures passed`.
      Touches: `scripts/test-check-docs.sh`
      Depends on: T1
- [x] **T3 — bootstrap-project carries the script**
      Done means: `skills/bootstrap-project/scripts/check-docs.sh` is identical to `scripts/check-docs.sh`, the skill copies it into the project and stays ≤80 lines, and the installed destination has it runnable.
      Touches: `skills/bootstrap-project/SKILL.md`, `skills/bootstrap-project/scripts/check-docs.sh`, `scripts/check.sh`
      Depends on: T1
- [x] **T4 — the nine other writers name the check**
      Done means: `bash scripts/test.sh` ends with `all checks passed` then `install tests passed`, and deleting the check line from any one skill makes `scripts/check.sh` fail.
      Touches: `skills/{build,debug,decide,office-docs,plan-work,ship,using-libra,verify,write-spec}/SKILL.md`, `scripts/check.sh`, `scripts/test.sh`
      Depends on: T3
- [ ] **T5 — this repo dogfoods it**
      Done means: `bash scripts/check-docs.sh docs/PROJECT.md docs/tasks/markdown-check.md` exits 0, and the reply on a broken document shows the check ran and the fix landed in the same turn.
      Touches: `docs/PROJECT.md`, `README.md`
      Depends on: T4

## Checkpoint — after T5
`bash scripts/test.sh` ends with `all checks passed` then `install tests passed`,
and deleting `## Out of scope` from any spec makes `bash scripts/check-docs.sh
<that spec>` exit 1 naming the missing heading.
