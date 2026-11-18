---
title: The git workflow skill and the recorded exception
updated: 2026-11-18
spec: ../specs/git-workflow-skill.md
---
# The git workflow skill and the recorded exception

Stopped at: T4, not started

## Checkpoint — after T1
`bash scripts/test.sh` prints five green lines and `ls skills | wc -l` prints 27.
`bash scripts/check-docs.sh docs/GIT.md` prints nothing. If the new skill is over
80 lines, or `docs/GIT.md` is not the only artifact it claims, stop: T2 and T3
only point at it.

- [x] **T1 — the skill, its artifact and the counts**
      Done means: `bash scripts/test.sh && ls skills | wc -l` exits 0 and prints 27
      Touches: `skills/git-workflow-and-versioning/SKILL.md`, `docs/GIT.md`,
      `README.md`, `docs/PROJECT.md`, `skills/using-libra/SKILL.md`,
      `scripts/test-routing.sh`, `evals/run.sh`, `CHANGELOG.md`
      Depends on: none

      Four decisions as prose under `## Steps`, not `###` blocks: the builder
      check says the 80-line cap only holds that way. The merge table and the
      eleven commit types are the expensive parts, so keep the prose around them
      tight. `docs/GIT.md` is written for this repository and says yes to a
      documentation or configuration commit on `main` and no to anything that
      changes behaviour. Add `docs/GIT.md` to the one-owner loop in
      `evals/run.sh`. `using-libra` gains no row; only "eight" becomes "nine".

- [x] **T2 — the three pointers and the two stops**
      Done means: `bash scripts/test.sh` exits 0, and `grep -c 'docs/GIT.md' skills/ship/SKILL.md skills/release/SKILL.md` prints a number above zero for each
      Touches: `skills/incremental-implementation/SKILL.md`, `skills/ship/SKILL.md`,
      `skills/release/SKILL.md`, `skills/build/SKILL.md`, `evals/run.sh`
      Depends on: T1

      Each skill keeps its own rule and gains a pointer. `ship` keeps its
      direct-commit sentence word for word and names `docs/GIT.md` as what makes
      it true. `release` reads the scheme: `semver` or no file keeps
      patch/minor/major and says it assumed SemVer; `none` stops before the
      changelog; anything else stops and reports it. `incremental` keeps the
      literal words "Conventional Commits" — an eval asserts them — and adds the
      default-branch clause. `build` gains one step: state branch-or-direct before
      the first commit.

- [x] **T3 — bootstrap asks about git**
      Done means: `grep -c 'three questions' skills/bootstrap-project/SKILL.md` prints 2
      Touches: `skills/bootstrap-project/SKILL.md`, `evals/run.sh`
      Depends on: T2

      Both places that say "two questions" become three. The new question is
      whether this project uses git, and with which workflow. The answer is one
      line under `## Decisions`; the handoff to `git-workflow-and-versioning`
      writes `docs/GIT.md`, because one artifact has one owner. A project with no
      repository is told how to start one.

- [ ] **T4 — three live routing passes**
      Done means: the `Runs` table in `evals/README.md` has a row dated today with `3 of 3`
      Touches: `evals/README.md`, `docs/tasks/git-workflow-skill.md`
      Depends on: T3

      One request for the new skill, plus the existing eighteen. Three fresh
      sandboxes, three fresh agents, each seeing only the generated descriptions.
      A pass is recorded only with the number of requests that matched. If a run
      misses, fix the description, not the case, and start the three again.

## Evidence

- 2026-11-18 — ADR-0003 written at decision time, before the plan, in `8d88b97`.
  It records both rejected extremes and that the rule moved twice.
