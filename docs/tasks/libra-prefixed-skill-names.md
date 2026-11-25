---
title: Prefix every skill name with libra-
updated: 2026-11-25
spec: ../specs/libra-prefixed-skill-names.md
---
# Prefix every skill name with libra-

Stopped at: spec written; T1 not started

## Checkpoint — after T3
`bash scripts/test.sh` prints its five green lines, `ls skills | grep -c '^libra-'`
prints 20, and no rename has needed a change outside the files a task lists. If
one does, stop: the mapping stopped being mechanical, and the remaining eight
skills should be re-planned before T4.

- [ ] **T1 — the collision that started it: `ship` becomes `libra-ship`**
      Done means: `bash scripts/test.sh` exits 0 and prints its five green lines;
      `ls skills | grep -c '^libra-'` prints 1; and
      `grep -rInE 'skills/ship([^-a-z0-9]|$)' README.md scripts evals skills docs/PROJECT.md .claude-plugin`
      prints nothing.
      Touches: `skills/ship/` (renamed), `evals/skills/ship/` (renamed),
      `evals/run.sh`, `evals/skills/fixtures.sh`, `evals/routing/cases.tsv`,
      `scripts/test-routing.sh`, `README.md`, `.claude-plugin/marketplace.json`
      Depends on: none

      Run the whole recipe on one skill before repeating it 26 times: rename the
      directory with `git mv`, set `name:` and the H1 to `libra-ship`, rename the
      eval directory and its `skill_name`, the `fixtures.sh` case label, the
      `cases.tsv` row, the `route` expectation and every `has ship` argument.
      Update the README table row, the uninstall loop and the marketplace path in
      the same commit, because `scripts/check.sh` compares the loop with
      `ls skills` and the suite would otherwise be red for a reason unrelated to
      the next task. Backticked `ship` in other skills becomes `libra-ship`; the
      verb "ship it" does not.

- [ ] **T2 — the ten project-management skills**
      Done means: `bash scripts/test.sh` exits 0 and prints its five green lines;
      `ls skills | grep -c '^libra-'` prints 11; and the same `grep -rInE` sweep
      for `using-libra`, `project-status`, `bootstrap-project`, `interview-me`,
      `idea-refine`, `spec-driven-development`, `constraint-driven-development`,
      `decide`, `plan-work`, `context-engineering` prints nothing.
      Touches: the ten `skills/<name>/` directories (renamed),
      `evals/skills/<name>/` (renamed), `evals/run.sh`, `evals/self-test.sh`,
      `evals/skills/fixtures.sh`, `evals/routing/cases.tsv`,
      `scripts/test-routing.sh`, `scripts/test-install.sh`, `scripts/check.sh`,
      `README.md`, `.claude-plugin/marketplace.json`
      Depends on: T1

      `using-libra` becomes `libra-start`, the one name the prefix rule does not
      form mechanically. `scripts/check.sh` hardcodes
      `skills/bootstrap-project/scripts/check-docs.sh` for the byte-identical
      copy; that path moves with the rename. `evals/self-test.sh` mutates
      `decide`, `idea-refine`, `interview-me` and `spec-driven-development`, so
      its `cp` and `sed` lines follow.

- [ ] **T3 — the nine build skills**
      Done means: `bash scripts/test.sh` exits 0 and prints its five green lines;
      `ls skills | grep -c '^libra-'` prints 20; and the sweep for `build`,
      `test-driven-development`, `incremental-implementation`,
      `doubt-driven-development`, `source-driven-development`,
      `subagent-driven-development`, `frontend-ui-engineering`,
      `api-and-interface-design`, `root-cause` prints nothing.
      Touches: the nine `skills/<name>/` directories (renamed),
      `evals/skills/<name>/` (renamed), `evals/run.sh`,
      `evals/skills/fixtures.sh`, `evals/routing/cases.tsv`,
      `scripts/test-routing.sh`, `scripts/test-check-docs.sh`, `README.md`,
      `.claude-plugin/marketplace.json`
      Depends on: T2

      `scripts/test-check-docs.sh` copies `skills/` wholesale but names
      `skills/incremental-implementation/SKILL.md` to break the contract rule in a
      throwaway tree; that path and the assertion it expects must move together.
      `build` is the homograph that matters: "build phase", "build the docs" and
      `git commit` type `build(...)` stay prose, only `` `build` `` the skill
      moves.

- [ ] **T4 — review, documentation and safety: five skills**
      Done means: `bash scripts/test.sh` exits 0 and prints its five green lines;
      `ls skills | grep -c '^libra-'` prints 25; and the sweep for `verify-work`,
      `change-review`, `simplify-change`, `office-docs`,
      `handling-untrusted-content` prints nothing.
      Touches: the five `skills/<name>/` directories (renamed),
      `evals/skills/<name>/` (renamed), `evals/run.sh`,
      `evals/skills/fixtures.sh`, `evals/routing/cases.tsv`,
      `scripts/test-routing.sh`, `scripts/test-install.sh`, `README.md`,
      `.claude-plugin/marketplace.json`
      Depends on: T3

      `office-docs` and `using-libra` are the two skills
      `scripts/test-install.sh` runs from an installed destination; T2 moved
      `using-libra`, this task moves `office-docs` and its assertion.

- [ ] **T5 — the last two: `git-workflow-and-versioning` and `release`**
      Done means: `bash scripts/test.sh` exits 0 and prints its five green lines;
      `ls skills | wc -l` prints 27 and `ls skills | grep -vc '^libra-'` prints 0;
      and the sweep for the two names prints nothing.
      Touches: the two `skills/<name>/` directories (renamed),
      `evals/skills/<name>/` (renamed), `evals/run.sh`,
      `evals/skills/fixtures.sh`, `evals/routing/cases.tsv`,
      `scripts/test-routing.sh`, `README.md`, `.claude-plugin/marketplace.json`
      Depends on: T4

      `release` is the other homograph: changelog prose and "release notes" stay;
      only the skill identifier moves.

- [ ] **T6 — the guard: an unprefixed name cannot merge**
      Done means: `bash scripts/check.sh` prints `all checks passed`;
      `bash scripts/test-check-docs.sh` prints `fixtures passed`; and that file
      contains one mutation that renames a skill directory to an unprefixed name
      and one that drops a marketplace entry, each asserting the FAIL line.
      Touches: `scripts/check.sh`, `scripts/test-check-docs.sh`
      Depends on: T5

      `check.sh` gains `case "$name" in libra-*) ;; *) FAIL ... ;; esac`, and a
      pass over `marketplace.json` that every `./skills/<name>` path exists and
      every skill appears exactly once — the rename is the moment a manifest path
      silently rots. Prove both on the throwaway tree the existing test already
      builds: the unmutated tree must be green before each mutation, so a tree
      that was already red cannot pass for the wrong reason.

- [ ] **T7 — the record: README upgrade path, changelog, state file**
      Done means: `bash scripts/test.sh` exits 0 and prints its five green lines;
      `bash scripts/check-docs.sh docs/PROJECT.md docs/specs/libra-prefixed-skill-names.md docs/tasks/libra-prefixed-skill-names.md docs/adr/0004-prefix-every-skill-name.md`
      prints nothing; `grep -nE 'skills/(using-libra|bootstrap-project|incremental-implementation)' README.md AGENTS.md docs/PROJECT.md docs/specs/markdown-check.md`
      prints nothing; and the `Next` list names this task first.
      Touches: `README.md`, `AGENTS.md`, `CHANGELOG.md`, `docs/PROJECT.md`,
      `docs/specs/markdown-check.md`,
      `docs/specs/libra-prefixed-skill-names.md` (acceptance boxes),
      `docs/adr/0004-prefix-every-skill-name.md`
      Depends on: T6

      The upgrade paragraph is the only part a 0.2 user cannot infer: the old 27
      links are not in the new uninstall loop, so name them once and say to
      remove them before reinstalling. `CHANGELOG.md` gets the rename under
      `Unreleased` as a breaking change; the version bump stays with `release`.
      The state file's feature row moves to `done`, and its module map and
      decisions list stop pointing at old paths. Refreshing this repo's ignored
      `.agents/skills/` copy is a manual step after the merge; no check reads it.

## Notes
- Each task is a commit of its own, named `refactor(skills)!: prefix ...`, so a
  bad group is revertible without touching the other four.
- Historical files keep their old names on purpose: `docs/plans/`,
  `docs/tasks/build-phase-skills.md`, `docs/adr/0001`-`0003`,
  `docs/design/` and the earlier `docs/specs/`.
- The field test's installs on three projects are not migrated here; the README
  note is what those projects follow.
