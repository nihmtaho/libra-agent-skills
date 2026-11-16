---
title: Check a markdown file whenever a skill writes one
updated: 2026-11-16
---
# markdown check after every write

## Problem

The documents the skills produce drift from their templates and nothing catches
it: a spec lands without `## Use cases`, an ADR without `## Rejected options`, a
`PROJECT.md` section is left empty. The next session trusts the file, so a broken
document is worse than a missing one. Today only `docs/PROJECT.md` is checked for
empty sections, by `scripts/check.sh` in this repo, and only when a human runs it.

## Use cases

1. A skill writes `docs/specs/x.md` and, before it returns, runs the project's
   checker on that file; a FAIL is fixed in the same turn, not tomorrow.
2. A human runs the same command by hand on any document and gets the same
   verdict, with the rule name and line number.
3. A project that has no checker yet gets one from `bootstrap-project`, so the
   check travels with the project instead of living in each skill.

## Rules

Generic, every file under `docs/`:

1. Opens with `---`, closed by `---` within the first 10 lines.
2. `title:` non-empty; `updated:` matches `YYYY-MM-DD`.
3. Exactly one `# ` heading, and it is the first line of the body.
4. No heading with empty text (`##` followed by nothing).
5. No empty section: a heading immediately followed by another heading or by EOF.
6. An even number of lines starting with ` ``` ` — fences open and close.
7. Every `](path)` that is not `http(s)`, `mailto` or `#anchor` resolves to a file
   that exists, relative to the document.

Per type, by path, in this order of match:

| Path | Required |
|---|---|
| `docs/PROJECT.md` | `## Run & verify`, `## Module map`, `## Features`, `## Decisions`, `## Next` |
| `docs/specs/*.md` | `## Problem`, `## Use cases`, `## Acceptance criteria`, `## Out of scope` |
| `docs/adr/*.md` | `## Context`, `## Decision`, `## Rejected options`, `## Consequences` |
| `docs/tasks/*.md` | `Stopped at:`, `## Checkpoint`, `spec:` in frontmatter, at least one `- [ ]` or `- [x]` |
| `docs/imports/*.md` | `trust: external` in frontmatter; the one-H1 rules do not apply, because the first line names the source file |
| anything else | generic rules only |

Output: silence and exit 0 when clean; one `FAIL <path>:<line>: <rule>` per
problem and exit 1 otherwise.

## Where the checker lives

One file, `scripts/check-docs.sh`, bundled in `bootstrap-project` next to
`SKILL.md` and **copied** into `<project>/scripts/` by that skill. Other skills run
`bash scripts/check-docs.sh <file>`; they never carry their own copy, so there is
one rule set per project and nothing to drift between skills. Never overwrite an
existing `scripts/check-docs.sh`: keep the project's file and say so in one line.

## Acceptance criteria

- [x] `bash scripts/check-docs.sh docs/specs/markdown-check.md` exits 0 and prints nothing.
- [x] `bash scripts/test-check-docs.sh` exits 0 and prints `fixtures passed`; it holds one broken fixture per rule above and asserts the FAIL line names that rule.
- [x] The four shipped templates in `skills/*/templates/` pass their type's rules despite `<placeholders>`.
- [x] `bash scripts/check.sh` fails if any doc-writing skill stops naming `check-docs.sh`; `test-check-docs.sh` proves this by dropping the line in a throwaway tree.
- [x] `bash scripts/test.sh` prints `all checks passed`, `fixtures passed`, then `install tests passed`, all exit 0.
- [x] From an installed destination (`./install.sh --dest DIR`), `DIR/.agents/skills/bootstrap-project/scripts/check-docs.sh` runs and exits 0 on a good document.
- [x] Observation: a spec with `## Out of scope` deleted is caught on the next run and comes back fixed in the same turn (this repo, 2026-11-16).

## Out of scope

- markdownlint, `markdownlint-cli2`, or any npm dependency: the rules are bash and
  awk, next to the ones `scripts/check.sh` already uses.
- CI workflows and git hooks: the check runs inside the agent session.
- Fixing the file: report only; the skill that wrote it does the fixing.
- Sweeping every document in the project: this version checks the file the skill
  just wrote, plus whatever a human points it at.
- External links, images, spelling, prose quality.
- Rejecting an `updated:` date that is not today: timezone-dependent, and
  `build` may backfill an older date on purpose.

## Open questions

- `bootstrap-project` is at its 80-line limit: the next change there must replace
  existing words, not add lines. If nothing can be
  trimmed without losing a rule, the copy step moves into the `project`
  template's comments instead and this spec is corrected first.
