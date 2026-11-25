---
title: libra-agent-skills
updated: 2026-11-25
---
# 27 skills for coding agents, built around one state file so a project can be reopened six months later

## Run & verify
- `bash scripts/test.sh` — the skill contract, the markdown fixtures, the routing fixtures, the skill evals, then the install tests.
- `bash scripts/check.sh` — the skill contract: frontmatter, length, headings, forbidden tokens, the `check-docs.sh` line in every `## Write`, byte-identical checker copies, the README uninstall loop, and the empty sections of `PROJECT.md`.
- `bash scripts/check-docs.sh <file>` — one document against the rules in `docs/specs/markdown-check.md`.
- `bash scripts/test-routing.sh` — a request a human would type must match exactly one skill description; two skills answering the same words fail.
- `bash evals/run.sh` — contract evals for the Define and Build skills, one owner per artifact, and every behavior case's grader self-test.
- `bash evals/skills/run.sh --inventory` — build every per-skill eval sandbox; `run.sh <skill> <id> with|without` prepares one.
- `bash evals/behavior/run.sh <case>` — prepares a sandbox and prints the prompt; `--verify <dir>` grades it, `--self-test` proves the grader can fail.
- `bash evals/routing/run.sh` — nineteen requests a model must route to the right skill; `--verify <dir>` grades the answers, `--self-test` proves the grader can fail.
- Sign of success: exit 0, and five lines `all checks passed`, `fixtures passed`, `routing passed`, `evals passed`, `install tests passed`.

## Module map
- `skills/<name>/SKILL.md` — the single source of the skill set; ≤80 lines, five fixed sections; renaming the file means renaming `name`.
- `.claude-plugin/marketplace.json` — groups the 27 skills for `npx skills add`; every skill appears exactly once.
- `skills/bootstrap-project/references/` — the `AGENTS.md` template and the old-repo rebuild steps.
- `skills/using-libra/references/routing.md` — the full routing table behind the classifier.
- `skills/git-workflow-and-versioning/references/branch-protection.md` — checks, reviews, rulesets and auto-merge.
- `install.sh` — symlinks into the destination; the fragile parts are overwriting and paths with spaces.
- `scripts/check.sh` — the skill contract (frontmatter, length, headings, forbidden tokens, empty sections); changing a rule here changes it for all 27 skills.
- `scripts/check-docs.sh` — the document rules; the copy in `scripts/` and the one shipped in `skills/bootstrap-project/scripts/` must stay byte-identical.
- `scripts/test-check-docs.sh` — one broken fixture per rule, plus every shipped template and this repo's own documents must stay clean.
- `scripts/test-install.sh` — symlink, run twice, refuse to overwrite, the Office-reading script must run from the installed destination.
- `docs/` — the backbone of this repo itself; this repo is the first place it is dogfooded.
- `docs/CONSTRAINTS.md` — this repo's own quality bar; `constraint-driven-development` is dogfooded here first.
- `docs/api/` — the document type this set writes into a project, one file per interface; owner `api-and-interface-design`. Not used in this repo.
- `docs/design-system.md` — the document type for tokens, components and where state lives; owner `frontend-ui-engineering`. Not used in this repo.
- `docs/GIT.md` — this repository's branching model, merge policy, version scheme and commit format; owner `git-workflow-and-versioning`.
- `evals/` — contract evals for the Define and Build skills, plus the live rubric a human runs by hand.
- `evals/skills/<name>/evals.json` — Anthropic-style prompts and expectations, two or more per skill; `evals/run.sh` checks every skill has one.
- `evals/skills/fixtures.sh` — builds a runnable sandbox for each case.
- `evals/skills/run.sh` — prepares one case, or `--inventory` to build all 63.
- `evals/skills/verify.sh` — grades a run's `grading.json` against the case expectations.

## Features
| Feature | Status | Stopped at | Docs |
|---|---|---|---|
| the 14-skill set | done | | [plan](plans/2026-11-15-libra-agent-skills-plan.md) |
| the Define pipeline (`interview-me`, `idea-refine`, `spec-driven-development`, `constraint-driven-development`) | done | | [readme](../README.md) |
| v0.1.2 release | done | | [changelog](../CHANGELOG.md) |
| v0.2.0 release | done | | [changelog](../CHANGELOG.md) |
| the release skill | done | | [spec](specs/release-skill.md) |
| the Build phase skills (nine behind one dispatcher) | done | | [spec](specs/build-phase-skills.md) · [task](tasks/build-phase-skills.md) |
| the git workflow skill and the recorded exception | done | | [spec](specs/git-workflow-skill.md) · [adr](adr/0003-direct-commits-need-a-recorded-exception.md) |
| the evals stop passing on an inverted rule | done | | [evals](../evals/README.md) |
| reading Office documents | done | | [spec](specs/office-docs.md) |
| github distribution | done | | [readme](../README.md) |
| markdown check after every write | done | | [spec](specs/markdown-check.md) |
| Phase A: collision renames, installer groups, trust hierarchy, intake gate, `AGENTS.md` bootstrap, branch protection | done | | [spec](specs/phase-a-skill-hardening.md) |
| per-skill evals and a runnable sandbox per case | done | | [spec](specs/phase-a-skill-hardening.md) · [evals](../evals/skills/README.md) |
| the two-week field test on three projects | running | clock started 2026-11-21; waiting for the first log line | [plan](plans/2026-11-21-field-test.md) |

## Decisions
- [ADR-0001](adr/0001-markdown-is-the-only-source.md) — markdown is the only source; Word/Excel are only the way in and the way out.
- [ADR-0002](adr/0002-four-define-skills-and-constraints-md.md) — `spec-driven-development` replaces `write-spec`; the quality bar lives in `docs/CONSTRAINTS.md`.
- [ADR-0003](adr/0003-direct-commits-need-a-recorded-exception.md) — a direct commit to the default branch needs a recorded exception in `docs/GIT.md`; a single commit is judged, and the merge policy follows the commits.
- Renamed `resume`, `review`, `verify`, `simplify` and `debug` to stop replacing built-in slash commands; the new names describe the moment and collide with none.
- A new idea is classified by `using-libra` before any edit; a feature or behavior change gets a spec and a task first, and the branch is created before the first edit.

## Next
1. Update the three field-test projects to the shipped branch and log the first line.
2. Keep the [two-week field test](plans/2026-11-21-field-test.md) until 2026-12-05; `0.3.0` is the prune release.
3. Phase B starts in `0.4.0` with `failure-guardrails`, `documentation-and-adrs`, and the GitHub suite; each addition needs evidence from two projects.
