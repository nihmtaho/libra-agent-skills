---
title: Constraints for libra-agent-skills
updated: 2026-11-16
---
# Constraints

## Quality bar
| Area | Bar | Proven by | Who can lower it |
|---|---|---|---|
| Correctness | every skill satisfies the contract in `scripts/check.sh`, and the two copies of `check-docs.sh` are byte-identical | `bash scripts/test.sh` | the human |
| Tests | one broken fixture per checker rule, each asserting the rule is named; one routing case per Define skill; one eval per load-bearing rule; every behavior and routing case's grader self-test must pass; a new rule or a description edit that steals another skill's words without a test is unfinished | `bash scripts/test-check-docs.sh`, `bash scripts/test-routing.sh`, `bash evals/run.sh` | the human |
| Performance | n/a — no service, no latency budget; the whole suite is seconds | — | — |
| Security | no secrets in a document; never overwrite an existing `scripts/check-docs.sh` or a skill the project already had | `install.sh` refusing, the `## Stop` of each skill | the human |
| Compatibility | a skill may be renamed only with the README uninstall line and a note in `docs/PROJECT.md`; installed symlinks must not dangle silently | `bash scripts/test-install.sh` | the human |

## Never
- delete a fixture, a skill section or a heading to make `check.sh` pass
- raise the 80-line limit, drop a forbidden token, or remove a rule without a line
  here saying why
- add a co-author line or an AI signature to a commit, unless the project or the
  platform requires a disclosure trailer. That exception is why the rule is a
  format convention and not forced concealment; `docs/GIT.md` records it.
- copy `check-docs.sh` into a second place instead of keeping one rule set

## When a check is red
The fix is in the skill or the document, not in the checker. A rule changes only
in `scripts/check.sh` and `docs/specs/markdown-check.md` together, with the reason
written down and the human's agreement.
