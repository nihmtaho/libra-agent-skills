---
title: libra-agent-skills
updated: 2026-11-16
---
# 14 skills for coding agents, built around one state file so a project can be reopened six months later

## Run & verify
- `bash scripts/test.sh` — the skill contract, the markdown fixtures, then the install tests.
- `bash scripts/check.sh` — the skill contract: frontmatter, length, headings, forbidden tokens, the `check-docs.sh` line in every `## Write`, byte-identical checker copies, and the empty sections of `PROJECT.md`.
- `bash scripts/check-docs.sh <file>` — one document against the rules in `docs/specs/markdown-check.md`.
- Sign of success: exit 0, and three lines `all checks passed`, `fixtures passed`, `install tests passed`.

## Module map
- `skills/<name>/SKILL.md` — the single source of the skill set; ≤80 lines, five fixed sections; renaming the file means renaming `name`.
- `install.sh` — symlinks into the destination; the fragile parts are overwriting and paths with spaces.
- `scripts/check.sh` — the skill contract (frontmatter, length, headings, forbidden tokens, empty sections); changing a rule here changes it for all 14 skills.
- `scripts/check-docs.sh` — the document rules; the copy in `scripts/` and the one shipped in `skills/bootstrap-project/scripts/` must stay byte-identical.
- `scripts/test-check-docs.sh` — one broken fixture per rule, plus every shipped template and this repo's own documents must stay clean.
- `scripts/test-install.sh` — symlink, run twice, refuse to overwrite, the Office-reading script must run from the installed destination.
- `docs/` — the backbone of this repo itself; this repo is the first place it is dogfooded.

## Features
| Feature | Status | Stopped at | Docs |
| the 14-skill set | done | | [plan](plans/2026-11-15-libra-agent-skills-plan.md) |
| reading Office documents | done | | [spec](specs/office-docs.md) |
| github distribution | done | | [readme](../README.md) |
| markdown check after every write | done | | [spec](specs/markdown-check.md) |

## Decisions
- [ADR-0001](adr/0001-markdown-is-the-only-source.md) — markdown is the only source; Word/Excel are only the way in and the way out.

## Next
1. Install `v0.1.1` into a third project and watch the checker on the first document it writes; record the report here.
2. Use the set for a week on real work; write down what snags, with the exact words that were said.
3. Then pick up [the deferred list](plans/2026-11-15-next-phases-plan.md).
