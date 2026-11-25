---
title: Two-week field test of the 27-skill set
updated: 2026-11-25
---
# Two-week field test

Status: running. Started 2026-11-21, review 2026-12-05.

The changelog records no use outside this repository. The set has 27 skills and
one promise: a fresh session reads `docs/PROJECT.md` and knows where the project
stands. This test measures that promise on three real projects and decides what
`0.3.0` prunes. Nothing new is added during the test.

## Baseline (2026-11-21)

| Project | Libra skills | State file | `AGENTS.md` points at it | Install |
|---|---|---|---|---|
| `libra-pomodoro` | 17 of 27 | yes, updated 2026-11-19 | no file | tracked copies, half-upgraded, `write-spec` deletion uncommitted |
| `goxviet` | 27 of 27 | yes, updated 2026-11-19 | no: 198-line Copilot file never mentions it | `.agents/` and `docs/` untracked; 11 other skills in `.claude/` |
| `libra-agent-skills` (this repo) | 27 of 27 | yes | yes | source of the set |

Three blockers found before day 1:

1. `libra-pomodoro` is half-upgraded: the ten skills added in 0.2.0 are missing,
   and `write-spec` is deleted only in the working tree. Its `.agents/skills/` is
   a tracked copy, so updating the set shows up as project changes.
2. Neither project sends a fresh session to `docs/PROJECT.md`; the core loop runs
   on the human remembering to ask, not on `AGENTS.md`.
3. `goxviet` has not committed `docs/` or `.agents/`: the state file and the
   skills exist on one disk only.

## Fix before day 1

- [x] `libra-pomodoro`: one install mechanism. The 0.2.0 copy was committed in
      `68fe850`; all 27 are present. Copies, not symlinks, so an update is a
      project commit.
- [x] Both projects: the four-line `AGENTS.md` block is at the top;
      `goxviet` keeps it in `.rules`, which `AGENTS.md` symlinks to.
      `libra-pomodoro/AGENTS.md` is still uncommitted.
- [x] `goxviet`: committed in `d9973bd` (`docs/PROJECT.md`, `.agents/`,
      `skills-lock.json`, `scripts/check-docs.sh`, `.rules`).
- [x] This repository: clock started 2026-11-21.

Day 1 is done. The first log line is in: two of the three `project-status` runs
were wrong even though the state files held content. That is the finding the
next session must explain, not another setup change.

## Scope change 2026-11-22
Phase A is a non-additive hardening pass and stays inside the baseline:
- five skills are renamed to stop overriding built-in commands: `resume` →
  `project-status`, `review` → `change-review`, `verify` → `verify-work`,
  `simplify` → `simplify-change`, `debug` → `root-cause`;
- the installer groups the same 27 skills;
- the trust hierarchy, the intake gate, the `AGENTS.md` bootstrap and the
  branch-protection guidance change existing skills, not the count.
Phase B adds skills — `failure-guardrails`, `documentation-and-adrs`, and the
GitHub suite. It starts after Phase A and after the 2026-12-05 review, so `0.3.0`
stays a prune release. The additions land in `0.4.0`; each needs evidence from two
of the three projects, as this plan already requires. They are outside this
field test's measurements.

## Protocol

One line per use, in the table below. `helped` means it changed the next action;
`wasted` means it cost reading and changed nothing; `wrong` means the output was
incorrect. For `wrong`, quote the exact words that were said.

| Date | Project | Skill | Verdict | Note |
|---|---|---|---|---|
| 2026-11-25 | `libra-pomodoro` | `project-status` | `wrong` | Said “`docs/PROJECT.md` has no content”; the file has 77 lines. It inferred the project from file names and reported `Next: Unknown`. |
| 2026-11-25 | `goxviet` | `project-status` | `wrong` | Said “`docs/PROJECT.md` is malformed … its line 5 is a tool-call string”; line 5 is `## Run & verify`. Standing and next came back unverified/unknown. |
| 2026-11-25 | `libra-agent-skills` | `project-status` | `helped` | Four lines correct. The first Read was truncated; it used `sed`, then reported the right next step and the stale build task. |

The first `Read` in these sessions can be truncated by the tool. The
`libra-agent-skills` run used `sed` and was right; the other two trusted the
truncated read and reported the state file as empty or malformed.

The only question that must be answered at the end: after five or more days away,
does a fresh session answer "what is this, where does it stand, what is next" in
four lines without reading the code?

## Review on 2026-12-05

- `project-status` accuracy at the first session after a gap of five or more days.
- Skills never invoked: merge or delete them in `0.3.0`, do not improve them.
- Skills that were invoked but had to be corrected by hand: fix the loop before
  any new skill.
- Checker rules that caught no real document: delete the rule.
- Did each project's own git stay clean of skill-install noise?

`0.3.0` is a prune release: removals and merges only. A new skill needs evidence
from at least two of these projects, and it replaces one that is already there.
