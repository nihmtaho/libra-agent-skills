---
title: Constraints for eval fixture
updated: 2026-11-17
---
# Constraints

## Quality bar
| Area | Bar | Proven by | Who can lower it |
|---|---|---|---|
| Tests | three assertions, none skipped | `bash test.sh` | the human |

## Never
- delete or skip a test to get green
- change a bar without a name and a date

## When a check is red
The fix is in `src/`. A bar changes only in this file, with a name and a date.
