---
title: Every skill name carries the libra- prefix
updated: 2026-11-25
---
# Every skill name carries the libra- prefix
## Problem
The set installs flat: `.agents/skills/<name>` and `.claude/skills/<name>`. The
directory name, the frontmatter `name` and the word a human invokes are the same
string, so that string is a global identifier in every tool that loads it. A name
a tool already uses as a command or a bundled skill either shadows it or is
shadowed, and the failure is silent: the skill loads, and the command a human
expected is gone.

Phase A answered this one name at a time: `resume`, `review`, `verify`,
`simplify` and `debug` were renamed, and a check was never added. `ship` has now
collided with a command that Claude ships. The method failed within days, because
a tool adds commands on its own schedule and this repo does not watch that
schedule. A reserved-name list is the same race with more bookkeeping: it is
wrong the day a tool releases.

No check can know every tool's command list at author time. One prefix can.
## Use cases
1. A human installs the set next to a tool's own commands and invokes
   `libra-ship`; `/ship` stays the tool's command, and neither shadows the other.
2. A maintainer adds a skill and `bash scripts/check.sh` refuses a name without
   the prefix, so the guarantee does not depend on anyone remembering Phase A.
3. A 0.2 user upgrades: the README names the old links to remove, the uninstall
   loop removes the 27 new names, and the reinstall leaves no stale entry.
4. An agent routes by `description`, as before; the prefix changes what a human
   types and what files are called, not how a request finds its skill.
## Structure
- `skills/libra-<name>/SKILL.md` — the 27 skills. The rule is one line: the
  directory, the frontmatter `name` and the H1 all start with `libra-`.
- `using-libra` becomes `libra-start`. It is the only name not formed by adding
  the prefix: `libra-using-libra` is a stutter on the line every generated
  `AGENTS.md` carries, and `start` is what the skill already tells a reader to
  do. It still satisfies the one rule.
- Every place a name is an identifier follows the same rename: frontmatter
  `name`, directory, `evals/skills/<name>/`, `"skill_name"`, the `fixtures.sh`
  case label, the third column of `evals/routing/cases.tsv`, the expectation in
  `scripts/test-routing.sh`, the skill argument in `evals/run.sh`, README rows
  and the uninstall loop, `.claude-plugin/marketplace.json`, and a backticked
  name in another skill.
- A bare English word that happens to equal a name is not renamed unless it
  means the skill: "build phase", "release notes" and "ship it" stay prose.
- `scripts/check.sh` gains the prefix rule, and `scripts/test-check-docs.sh`
  mutates a throwaway tree to prove the rule fires.
## Code style
- Bash and awk, next to the checks already in `scripts/`; no new dependency.
- One mechanical pass per group, each ending green, so a mistake is found in 27
  lines rather than in 27 directories at once.
- Markdown stays inside the rules in `docs/specs/markdown-check.md`; every file
  written runs `bash scripts/check-docs.sh`.
## Test plan
- `bash scripts/test.sh` — the five green lines after every task.
- `bash scripts/test-check-docs.sh` — the new mutations: one unprefixed skill
  directory and one marketplace path that does not exist must fail `check.sh`,
  and the unmutated tree must pass first.
- `bash evals/skills/run.sh --inventory` — every case still builds under its new
  directory name.
- Stale-identifier sweep: `grep -rInE 'skills/<old-name>\b'` over the
  current-truth files (`README.md`, `AGENTS.md`, `docs/PROJECT.md`,
  `docs/specs/markdown-check.md`, `scripts/`, `evals/`, `skills/`,
  `.claude-plugin/`) must print nothing. Historical files are not rewritten.
## Acceptance criteria
- [ ] All 27 directories and all 27 `name` fields start with `libra-`, and
      `ls skills | wc -l` still prints 27.
- [ ] `bash scripts/check.sh` fails an unprefixed directory name, and
      `test-check-docs.sh` proves it on a tree that was green first.
- [ ] A rename that misses `marketplace.json` fails the suite: `test-install.sh`
      already compares the manifest with `skills/`, so no second check is added.
- [ ] `bash scripts/test.sh` prints its five green lines, and
      `evals/skills/run.sh --inventory` prints `inventory passed`.
- [ ] No current-truth file names a retired identifier as a skill; the sweep in
      the test plan is empty.
- [ ] The README uninstall loop lists exactly the 27 new names, and an upgrade
      note tells a 0.2 user to remove the 27 old links first.
- [ ] `CHANGELOG.md` records the rename as a breaking change under `Unreleased`.
- [ ] A fresh install into a temp destination contains no unprefixed libra skill
      and `libra-ship` runs as a skill while the tool's own command is untouched.
## Out of scope
- The six `marketplace.json` group names (`build`, `ship`, `review`, ...). They
  are plugin groups, not skill names, and they do not shadow a command.
- A version bump or tag; `release` owns both.
- Rewriting history: `docs/plans/`, `docs/tasks/`, `docs/adr/`, `docs/design/`
  and earlier `docs/specs/` keep the names they recorded.
- Tool-specific namespacing (plugin prefixes, per-harness install layouts) and a
  reserved-name list; the prefix makes both unnecessary.
- Renaming anything inside a project that already installed the 0.2 set; that is
  the upgrade note's job, not a migration script.
## Open questions
- None. The prefix is fixed at `libra-`, and `libra-start` is the one exception.
