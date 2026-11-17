---
title: The Build phase becomes eight skills behind one dispatcher
updated: 2026-11-18
---

# The Build phase becomes eight skills behind one dispatcher

## Problem

`build` is one 60-line skill doing six jobs: find context, write the test first,
slice small, commit, branch, stop. Each job is good; together they are cramped,
and a reader cannot point at the rule they broke.

Splitting them is not free. Three mechanical constraints decide the shape:

- `scripts/check.sh` requires ≤80 lines, five exact headings, a `description`
  with "Use when" and no ": ", and a `## Write` naming `docs/` plus
  `check-docs.sh` — or the word `none`.
- `scripts/test-routing.sh` requires a typed request to match **exactly one**
  description, so eight overlapping descriptions turn routing into a coin flip.
- `evals/run.sh` enforces one owner per artifact. Two skills naming
  `docs/tasks/` fails the suite.

And one behavioural constraint decides whether the change is an improvement:
today `build` **is** the discipline. A split into peers would make TDD optional
and leave the set worse than it is now, at 26 skills instead of 18.

## Use cases

1. A task is ready in `docs/tasks/`. The agent runs `build`, and `build` names
   the order: context, then the failing test, then how much lands in one commit.
2. A human types "this task is too big to land safely" and lands on
   `incremental-implementation` without reading `build`.
3. A change touches an endpoint's response shape. `api-and-interface-design`
   writes the contract before any handler exists.
4. An agent is about to say "done" on a decision nobody checked.
   `doubt-driven-development` makes it state the claim, then doubt it in a fresh
   context.
5. Two tasks in the plan touch disjoint files.
   `subagent-driven-development` runs them in parallel, and the parent still
   commits.

## Approaches considered

1. **Eight peers, `build` deleted.** Closest to the literal request, cheapest to
   write, worst to use: every discipline skill competes with every other for the
   same request and nothing orders them.
2. **Four skills, split by work type only.** Add `frontend-ui-engineering`,
   `api-and-interface-design`, `source-driven-development`,
   `context-engineering`; keep TDD, incremental, doubt and subagent inside
   `build`, `verify` and `plan-work`. 22 skills, safe, answers 4 of 8.
3. **Eight skills behind a dispatcher.** Chosen. Each idea gets its own file and
   `build` keeps enforcement by naming the order. Costs ~600 lines of
   instruction and eight more descriptions in every prompt.

## The eight skills

| Skill | Fires when | `## Write` |
|---|---|---|
| `context-engineering` | the agent is missing context, or drowning in it | `docs/PROJECT.md` (`## Module map`, `## Run & verify`), `AGENTS.md` |
| `test-driven-development` | a behaviour has no failing test | `none` |
| `incremental-implementation` | a task is too big or too risky for one commit | `docs/tasks/<feature>.md` |
| `source-driven-development` | a library, framework or API decision needs a source | `none` |
| `doubt-driven-development` | about to claim something significant is right | `docs/PROJECT.md` when a claim fails, else `none` |
| `frontend-ui-engineering` | building or changing a user interface | `docs/design-system.md` |
| `api-and-interface-design` | adding or changing an API, response shape or error format | `docs/api/<name>.md` |
| `subagent-driven-development` | two or more tasks can run without touching the same files | `none` |

`build` keeps its name, drops to a dispatcher, and its `## Write` becomes `none`.

`incremental-implementation` inherits the two rules `build` had for
`docs/tasks/<feature>.md`: tick the box, and write `Stopped at:` when it stops
mid-task. It does not become the file's only writer, because it is not:
`plan-work` creates the file, `context-engineering` fills its `Read first`,
`debug` and `ship` amend it, and `subagent-driven-development` reports the slice
back so `incremental-implementation` can record it. The one-owner rule stays
scoped to `docs/specs/`, `docs/ideas/` and `docs/CONSTRAINTS.md`, which is what
`evals/run.sh` checks today. `docs/PROJECT.md` already has eleven writers; that is
by design, because it is the state file.

## The dispatcher's order

1. `context-engineering` when the task's `Read first` is not enough.
2. `test-driven-development` — always, before the first line of code.
3. `incremental-implementation` — how much lands in one commit.
4. `source-driven-development` when the work rests on a framework or API fact.
5. `frontend-ui-engineering` or `api-and-interface-design` when the work is that
   kind of work.
6. `subagent-driven-development` when two tasks are independent; the parent still
   commits.
7. `doubt-driven-development` before saying the task is done.

Steps 2 and 3 are not optional. The rest are conditional on the task, and
`build` names the condition rather than leaving it to taste.

**Spike mode** survives in `build`, and only there. When the human wants to learn
rather than ship, none of the seven steps apply: build the throwaway, skip the
tests, keep it off the main branch, and write the one thing learned into
`## Decisions` or `## Next`. `build` states the exception, so `build` is the file
a reader is holding when they need it; `test-driven-development` stays absolute.

## Trigger words, so routing stays decidable

- `build` — "a task is ready to implement" (entry point only).
- `test-driven-development` — "no failing test yet", "test written after code".
- `incremental-implementation` — "too big", "too risky", "rollback", "flag".
- `context-engineering` — "missing context", "too much to read", "rules file".
- `source-driven-development` — "which library", "how does this API behave",
  "cite the docs".
- `doubt-driven-development` — "a claim no command can check", "re-derive it".
- `frontend-ui-engineering` — "component", "layout", "responsive", "a11y".
- `api-and-interface-design` — "endpoint", "response shape", "error format".
- `subagent-driven-development` — "in parallel", "independent tasks".

Two of these are chosen to avoid stealing words that already have an owner.
`incremental-implementation` never says "one commit", because `review`'s
description already ends "bound to one commit". `doubt-driven-development` never
says "claim it works", because `verify` already owns "about to claim a pass":
verify means a command produced evidence, doubt means a claim no command can
check and a fresh context has to re-derive it. Both pairs get a routing case;
`docs/CONSTRAINTS.md` treats a description that steals another skill's words
without a test as unfinished.

## What changes around them

- `using-libra` keeps its three Build rows (`build`, `debug`, `office-docs`) and
  gains one sentence: within Build, `build` names the order of the eight skills it
  dispatches. The file is 77 of 80 lines; adding eight rows makes it 85 and fails
  `check.sh`, and deleting rows to fit would be the "delete a heading to make
  `check.sh` pass" that `docs/CONSTRAINTS.md` forbids. Routing is by phase, and
  the Build entry point is `build`.
- The branch and commit rules move with the commit: the
  `git rev-parse --abbrev-ref HEAD` check, Conventional Commits, and "no co-author
  line" go to `incremental-implementation`. The assertion at `evals/run.sh:86` is
  retargeted, not deleted.
- `README.md`: "Eighteen" becomes "Twenty-six", the prose count at the uninstall
  section, and the loop's 26 names.
- `docs/PROJECT.md`: H1 count, `## Module map` entries for `docs/api/` and
  `docs/design-system.md`, `## Features` row, `updated:`.
- `evals/run.sh`: one assertion per new skill on its defining rule, scoped with
  `steps_body` where the rule is a command; the `build` branch assertion moves to
  `incremental-implementation`; and the spike exception is asserted in `build`.
  No new one-owner check for `docs/tasks/`, because it has four writers today and
  a check that is red on day one teaches people to delete checks.
- `scripts/test-routing.sh`: nine new `route` lines, and the existing
  `failing test first` case moves from `build` to `test-driven-development`.
- `docs/CONSTRAINTS.md`: no change. If a rule here weakens one of its lines, the
  change is wrong.

## Acceptance criteria

- [x] `bash scripts/test.sh` exits 0 with five green lines.
- [x] `ls skills | wc -l` prints 26, the README loop lists 26 names, and the
      README prose says twenty-six.
- [x] Deleting the `test-driven-development` step from `build`'s `## Steps` fails
      `evals/run.sh`, and so does removing the sentence that makes steps 2 and 3
      mandatory: a menu must not pass.
- [x] Deleting the tick-the-box and `Stopped at:` rules from
      `incremental-implementation`'s `## Steps` fails `evals/run.sh`.
- [x] Every trigger word in this spec appears in exactly one description, and
      each routing case names one phrase rather than an OR that a live branch can
      carry alone.
- [x] `bash scripts/test-routing.sh` passes with the eight new names and fails
      when two of them are given the same trigger words; `verify`/`doubt` and
      `review`/`incremental` each have a case that separates them.
- [x] Every new skill is ≤80 lines with the five headings, and `## Write` is
      either a `docs/` path with `check-docs.sh` or the word `none`.
- [x] No skill outside the eight, `build` and `using-libra` gains or loses a
      rule. The one fixture retargeted, `scripts/test-check-docs.sh`'s check-line
      case, moved from `build` to `incremental-implementation` because that is
      where the check line now lives.

## Limits

- Contract evals prove a rule is written down, not obeyed. That boundary was
  already known when the Define skills shipped, and this change widens the
  surface it applies to. No live run is budgeted for the eight here.
- `frontend-ui-engineering`, `api-and-interface-design` and
  `context-engineering` are the three whose subject matter does not fit 80 lines
  without dropping something. The builder may cut their coverage and must say
  what was cut, in the skill's own `## Stop`. `context-engineering` points at
  `bootstrap-project` for creating `docs/PROJECT.md`; it refreshes two sections,
  it does not build the file.
- Instruction budget: 26 descriptions is a real cost per session. If routing is
  unreliable in live use, the fix is fewer skills, not longer descriptions.

## Open questions

None. The one real choice — eight with a dispatcher, or four split by work type
— was made in conversation, and option 3 was picked.

Six gaps a fresh builder found on 2026-11-18 are answered in place above: who
writes `docs/tasks/`, where spike mode goes, `using-libra`'s line budget, the
`verify`/`doubt` and `review`/`incremental` word collisions, which skill carries
the branch rule, and which skills may cut coverage.

## Out of scope

- Merging `test-driven-development` into `incremental-implementation`. They are
  separate on purpose: one is about *when* the test is written, the other about
  *how much* lands in one commit. Option 3-b was offered and declined.
- Porting superpowers' skill text. The names overlap; the content is ours, sized
  to this set's five headings and 80-line cap.
- Any change to `debug`, `office-docs`, `verify`, `review`, `simplify`, `ship`,
  `release`, or the four Define skills.
- A live eval run for the eight new skills; `evals/README.md` already carries the
  rubric a human runs by hand.
