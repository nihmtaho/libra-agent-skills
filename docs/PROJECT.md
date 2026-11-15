---
title: libra-agent-skills
updated: 2026-11-15
---
# 14 skills for coding agents, built around one state file so a project can be reopened six months later

## Run & verify
- `bash scripts/test.sh` — checks every skill against the contract, then runs the four install tests.
- `bash scripts/check.sh` — only the skill contract and the empty sections of `PROJECT.md`.
- Sign of success: exit 0, and two lines `all checks passed` then `install tests passed`.

## Module map
- `skills/<name>/SKILL.md` — the single source of the skill set; ≤80 lines, five fixed sections; renaming the file means renaming `name`.
- `install.sh` — symlinks into the destination; the fragile parts are overwriting and paths with spaces.
- `scripts/check.sh` — the skill contract (frontmatter, length, headings, forbidden tokens, empty sections); changing a rule here changes it for all 14 skills.
- `scripts/test-install.sh` — symlink, run twice, refuse to overwrite, the Office-reading script must run from the installed destination.
- `docs/` — the backbone of this repo itself; this repo is the first place it is dogfooded.

## Features
| Feature | Status | Stopped at | Docs |
| the 14-skill set | done | | [plan](plans/2026-11-15-libra-agent-skills-plan.md) |
| reading Office documents | done | | [spec](specs/office-docs.md) |

## Decisions
- [ADR-0001](adr/0001-markdown-is-the-only-source.md) — markdown is the only source; Word/Excel are only the way in and the way out.

## Next
1. Push to GitHub, tag v0.1.0, and verify `npx skills add nihmtaho/libra-agent-skills` from a clean directory.
2. Hand the install guide to the user for a third-project test (manual); record the report here.
3. Use this set for a week on real work; write down what snags here.

Deferred until usage data exists: Vietnamese/Japanese README translations, CI workflow, demo video, landing page, case studies, splitting PROJECT.md.
