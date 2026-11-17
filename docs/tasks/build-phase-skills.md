---
title: The Build phase becomes eight skills behind one dispatcher
updated: 2026-11-18
spec: ../specs/build-phase-skills.md
---
# The Build phase becomes eight skills behind one dispatcher

Stopped at: T2, not started

## Checkpoint — after T1
`bash scripts/test.sh` prints five green lines and `ls skills | wc -l` prints 21.
If `build` still contains a TDD step, or a discipline skill is over 80 lines,
stop: T2 and T3 only add more of the same.

- [x] **T1 — the three discipline skills and `build` as dispatcher**
      Done means: `bash scripts/test.sh && ls skills | wc -l` exits 0 and prints 21
      Touches: `skills/build/SKILL.md`, `skills/test-driven-development/SKILL.md`,
      `skills/incremental-implementation/SKILL.md`,
      `skills/doubt-driven-development/SKILL.md`, `README.md`,
      `scripts/test-routing.sh`, `evals/run.sh`, `CHANGELOG.md`
      Depends on: none

      `build` drops to the dispatcher and its `## Write` becomes `none`. The
      branch check, Conventional Commits and "no co-author" move to
      `incremental-implementation`, and the assertion at `evals/run.sh:86`
      follows them. Spike mode stays in `build` as the one exception.
      `doubt` must not say "claim it works"; `incremental` must not say
      "one commit". Retarget the existing `route 'failing test first'` line from
      `build` to `test-driven-development`, and add one case each for
      `verify`/`doubt` and `review`/`incremental`.

- [ ] **T2 — the three meta skills**
      Done means: `bash scripts/test.sh && ls skills | wc -l` exits 0 and prints 24
      Touches: `skills/context-engineering/SKILL.md`,
      `skills/source-driven-development/SKILL.md`,
      `skills/subagent-driven-development/SKILL.md`, `README.md`,
      `scripts/test-routing.sh`, `evals/run.sh`, `CHANGELOG.md`
      Depends on: T1

      `source-driven-development` and `context-engineering` will name
      documentation and possibly a web page; if so they must name
      `handling-untrusted-content` or `check.sh` fails. `context-engineering`
      points at `bootstrap-project` for creating `docs/PROJECT.md`; it refreshes
      `## Module map` and `## Run & verify` and does not build the file.

- [ ] **T3 — the two domain skills**
      Done means: `bash scripts/test.sh && ls skills | wc -l` exits 0 and prints 26
      Touches: `skills/frontend-ui-engineering/SKILL.md`,
      `skills/api-and-interface-design/SKILL.md`, `README.md`,
      `scripts/test-routing.sh`, `evals/run.sh`, `CHANGELOG.md`
      Depends on: T2

      `docs/api/<name>.md` and `docs/design-system.md` get no new rule in
      `check-docs.sh`: they fall under "anything else", generic rules only, so
      they ship no template either. If a section is genuinely required, that is a
      change to `scripts/check-docs.sh` and `docs/specs/markdown-check.md`
      together, with the two copies kept byte-identical — out of this task.

- [ ] **T4 — the documents tell the truth**
      Done means: `bash scripts/test.sh` is green and `grep -rn 'Eighteen\|18 skill' README.md docs/PROJECT.md` prints nothing
      Touches: `README.md`, `docs/PROJECT.md`, `skills/using-libra/SKILL.md`,
      `CHANGELOG.md`, `docs/specs/build-phase-skills.md`
      Depends on: T3

      `using-libra` gains one sentence and no new row. `## Module map` gains
      `docs/api/` and `docs/design-system.md`. The spec's acceptance boxes are
      ticked only where the evidence exists.
