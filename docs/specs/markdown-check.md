---
title: Check a markdown file whenever a skill writes one
updated: 2026-11-18
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
3. Exactly one `# ` heading, and it is the first line of the body. An imported
   document is exempt: its first line names the source file.
4. No heading with empty text (`##` followed by nothing).
5. No empty section: a heading immediately followed by another heading or by EOF.
6. Code fences balance: a line of three or more ` ``` ` or `~~~` opens one, and a
   line of the same marker, at least as long and followed only by spaces or tabs,
   closes it. A fence may be indented up to three spaces, and every rule below
   reads a line with that indent stripped. Text after an opening run is an info
   string; text after a closing run means it is content.
7. Every `](path)` that is not `http(s)`, `mailto` or `#anchor` resolves to a file
   that exists, relative to the document.
8. When two consecutive rows start with `|`, the second must be a separator row
   whose cells are all `:?-+:?`; without one the pipes render as one paragraph of
   text. A line indented four or more spaces is a code block, so its rows are not
   checked.

Per type, by path, in this order of match:

| Path | Required |
|---|---|
| `docs/PROJECT.md` | `## Run & verify`, `## Module map`, `## Features`, `## Decisions`, `## Next` |
| `docs/specs/*.md` | `## Problem`, `## Use cases`, `## Acceptance criteria`, `## Out of scope` |
| `docs/adr/*.md` | `## Context`, `## Decision`, `## Rejected options`, `## Consequences` |
| `docs/tasks/*.md` | `Stopped at:`, `## Checkpoint`, `spec:` in frontmatter, at least one `- [ ]` or `- [x]` |
| `docs/imports/*.md` | `trust: external` in frontmatter; the one-H1 rules do not apply, because the first line names the source file |
| `docs/ideas/*.md` | `## Problem`, `## Options considered`, `## Chosen direction`, `## Riskiest assumption`, `## Cheapest test` |
| `docs/CONSTRAINTS.md` | `## Quality bar`, `## Never`, `## When a check is red` |
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
- [x] The six shipped templates in `skills/*/templates/` pass their type's rules despite `<placeholders>`.
- [x] `bash scripts/check.sh` fails if any doc-writing skill stops naming `check-docs.sh`; `test-check-docs.sh` proves this by dropping the line in a throwaway tree.
- [x] `bash scripts/test.sh` prints `all checks passed`, `fixtures passed`, then `install tests passed`, all exit 0.
- [x] From an installed destination (`./install.sh --dest DIR`), `DIR/.agents/skills/bootstrap-project/scripts/check-docs.sh` runs and exits 0 on a good document.
- [x] Observation: a spec with `## Out of scope` deleted is caught on the next run and comes back fixed in the same turn (this repo, 2026-11-16).
- [x] Dropping `## Never` from a `CONSTRAINTS.md`, or `## Riskiest assumption` from an idea, is caught with the rule named (this repo, 2026-11-16).
- [x] Observation: the `## Features` table in this repo's `docs/PROJECT.md` shipped
      without a separator row and rendered as text; rule 8 caught it on the next
      run (this repo, 2026-11-18).

## Out of scope

- markdownlint, `markdownlint-cli2`, or any npm dependency: the rules are bash and
  awk, next to the ones `scripts/check.sh` already uses.
- CI workflows and git hooks: the check runs inside the agent session.
- Fixing the file: report only; the skill that wrote it does the fixing.
- Sweeping every document in the project: this version checks the file the skill
  just wrote, plus whatever a human points it at.
- Column counts agreeing between the header and the separator row: counting cells
  that may hold escaped or code-span pipes is a rule of its own.
- External links, images, spelling, prose quality.
- Rejecting an `updated:` date that is not today: timezone-dependent, and
  `build` may backfill an older date on purpose.

## Open questions

- `bootstrap-project` is at its 80-line limit: the next change there must replace
  existing words, not add lines. If nothing can be
  trimmed without losing a rule, the copy step moves into the `project`
  template's comments instead and this spec is corrected first.
