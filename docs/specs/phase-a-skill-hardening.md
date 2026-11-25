---
title: Phase A hardening and per-skill evals
updated: 2026-11-25
---
# Phase A hardening and per-skill evals
## Problem
Five skill names shadow built-in slash commands, so a local skill silently
replaces `/resume`, `/review`, `/verify`, `/simplify` or `/debug`. The installer
shows one flat list, trust between project text and outside text is implicit, a
new project gets no agent file, and the eval suite checks rules rather than
whole skills. A reviewer cannot tell whether a skill works from the automated
checks alone.
## Use cases
1. A human installs the set and sees six groups, then invokes a skill by a name
   that collides with no built-in command.
2. A new project runs `bootstrap-project` and gets a short `AGENTS.md` that
   points at `docs/PROJECT.md`; Claude Code gets a `CLAUDE.md` that imports it.
3. An agent receives a hunch and routes it to `idea-refine`, a two-reading
   request to `interview-me`, and a question to an answer rather than an edit.
4. A maintainer runs one sandbox per eval case, grades it, and compares the skill
   against a baseline.
## Structure
- `skills/<name>/SKILL.md` — the 27 skills, with five renamed: `resume` →
  `project-status`, `review` → `change-review`, `verify` → `verify-work`,
  `simplify` → `simplify-change`, `debug` → `root-cause`.
- `.claude-plugin/marketplace.json` — six installer groups, every skill once.
- `skills/bootstrap-project/references/agents-md.md` — the `AGENTS.md` template
  and the equivalent-file table for other tools; `old-repo.md` holds the rebuild
  steps.
- `skills/using-libra/references/routing.md` — the full routing table.
- `skills/git-workflow-and-versioning/references/branch-protection.md` — the
  ruleset/check/review/auto-merge policy.
- `evals/skills/<name>/evals.json` — two or more prompts and expectations per
  skill, 63 cases in total.
- `evals/skills/fixtures.sh` — a runnable sandbox per case.
- `evals/skills/run.sh` — prepare one case or `--inventory` all 63.
- `evals/skills/verify.sh` — grade a written `grading.json`.
## Code style
- Markdown only; each `SKILL.md` keeps the five fixed sections and stays at 80
  lines or fewer.
- Eval files use the Anthropic `evals.json` schema: `skill_name`, `prompt`,
  `expected_output`, `expectations`.
- Shell checks stay bash; the eval runner uses `python3` for JSON, `fixtures.sh`
  uses `perl` and `uv` for the Office fixture, and the sandbox runner calls no
  model.
## Test plan
- `bash scripts/test.sh` — contract, fixtures, routing, evals and install tests.
- `bash evals/skills/run.sh --inventory` — every case builds a sandbox.
- `bash evals/skills/run.sh <skill> <id> with` then `verify.sh` — one graded run.
- failure path: a skill with no eval file, a case whose sandbox cannot build, or a
  rename missing from the README uninstall loop must fail a check.
## Acceptance criteria
- [x] The five renamed skills load under names that collide with no built-in
      command, and the README uninstall loop lists all 27.
- [x] `npx skills add` shows six groups, and the manifest lists every skill once.
- [x] A new project gets `AGENTS.md`, a `CLAUDE.md` that imports it, and the
      trust hierarchy in `handling-untrusted-content`.
- [x] A hunch reaches `idea-refine`, two readings reach `interview-me`, a question
      is answered without an edit, and `build` refuses a missing task or spec.
- [x] Every skill has an eval file; 63 cases build with `--inventory`; the three
      full-run case gaps pass.
- [x] `bash scripts/test.sh` prints its five green lines.
## Out of scope
- Phase B skills (`failure-guardrails`, `documentation-and-adrs`, the GitHub
  suite); they start in `0.4.0` after the field test.
- A version bump or tag; `release` owns both.
## Open questions
- None for this version.
