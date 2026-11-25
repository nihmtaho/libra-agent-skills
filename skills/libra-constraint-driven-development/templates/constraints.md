---
title: Constraints for <project>
updated: YYYY-MM-DD
---
# Constraints

## Quality bar
| Area | Bar | Proven by | Who can lower it |
|---|---|---|---|
| Correctness | <what must never be wrong> | `<command>` | <role> |
| Tests | <what must be covered; a skip means what> | `<command>` | <role> |
| Performance | <a number and its unit> | `<command>` | <role> |
| Security | <what is never logged or stored> | <observation> | <role> |

## Never
- <what the agent must not do to get green: delete a test, loosen a threshold,
  add an ignore comment, drop a check from the script>

## When a check is red
<the fix is in the code. A bar changes only in this file, with a name and a date.>
