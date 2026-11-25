---
title: Phase A hardening and per-skill evals
updated: 2026-11-25
spec: ../specs/phase-a-skill-hardening.md
---
# Phase A hardening and per-skill evals
Stopped at: T6 — review and merge pending.
## Checkpoint
`bash scripts/test.sh` prints its five green lines; `bash evals/skills/run.sh
--inventory` prints `inventory passed`; the README uninstall loop lists 27 names.
If a rename is missing from the loop, stop: the install is not closed.
- [x] **T1 — rename and group the set**
      Done means: five skills load under new names and `npx skills add` shows six
      groups with all 27 skills once.
      Touches: `skills/*/SKILL.md`, `.claude-plugin/marketplace.json`, `README.md`,
      `scripts/test-routing.sh`, `evals/run.sh`
      Depends on: none
- [x] **T2 — trust, bootstrap and branch protection**
      Done means: `handling-untrusted-content` has three tiers, `bootstrap-project`
      creates `AGENTS.md` and `CLAUDE.md`, and the git skill names rulesets,
      reviews and auto-merge without an admin bypass.
      Touches: `skills/handling-untrusted-content/SKILL.md`,
      `skills/bootstrap-project/`, `skills/git-workflow-and-versioning/`,
      `skills/ship/SKILL.md`
      Depends on: T1
- [x] **T3 — intake, questions and routing**
      Done means: `using-libra` classifies a hunch, two readings, a question and a
      task; `build` refuses a missing task or spec and does not implement a
      question.
      Touches: `skills/using-libra/SKILL.md`,
      `skills/using-libra/references/routing.md`, `skills/build/SKILL.md`,
      `AGENTS.md`
      Depends on: T2
- [x] **T4 — per-skill evals and sandboxes**
      Done means: 63 cases exist, every skill has a file, and every case builds a
      sandbox with `--inventory`.
      Touches: `evals/skills/*/evals.json`, `evals/skills/fixtures.sh`,
      `evals/skills/run.sh`, `evals/skills/verify.sh`, `evals/run.sh`
      Depends on: T3
- [x] **T5 — pilot, screening and full run**
      Done means: the pilot is 3/3, the screening triages fixture and case
      errors, the full run is recorded with baseline, and the three case gaps
      pass.
      Touches: `evals/README.md`, `evals/skills/README.md`,
      `evals/skills/fixtures.sh`, `evals/skills/*/evals.json`
      Depends on: T4
- [ ] **T6 — docs, changelog and review**
      Done means: `CHANGELOG.md` names the eval layer, `docs/PROJECT.md` is true,
      a fresh `change-review` returns PASS, and `ship` merges.
      Touches: `CHANGELOG.md`, `docs/PROJECT.md`
      Depends on: T5
