---
title: One plugin package for four coding agents
updated: 2026-11-25
---
# One plugin package for four coding agents

## Problem

The 27 skills work, but they are distributed four ways: `install.sh` symlinks,
`npx skills add`, a copy into `.agents/skills/`, and a clone. Nothing is a
citable, installable artifact, and every improvement to the set asks the user to
run a different command per tool. The rules in this repository are prose inside
skills; no tool enforces them, so a markdown file and a commit on `main` are
caught only when a human remembers.

## Options considered

1. Keep the status quo, `install.sh` only. Cheapest, but no artifact and no
   guardrail; this is the pain being solved.
2. Add zero-code manifests for all four tools. Cheap and portable, but no
   runtime behaviour, which the human explicitly rejected.
3. One npm package with real adapters and two deterministic guardrails. Highest
   cost; assumes the OpenCode and Pi plugin APIs are stable enough.
4. A monorepo with six packages, one per skill group. Clean dependencies, but
   six versions and six publishes for no user-visible gain.
5. An `npx libra init` CLI that writes each tool's config. No plugin API needed,
   but still no runtime guardrail.
6. One MCP server exposing the skills. Cross-tool, but loses progressive
   disclosure and the `/skill:name` invocation.
7. Ship only the repository and drop packaging. The opposite of the obvious
   move; solves nothing.

## Chosen direction

Option 3. One npm package, `libra-agent-skills`, holds the 27 skills as the only
source: a Claude Code plugin with hooks, an OpenCode plugin that registers the
skills, a Pi extension plus `pi.skills`, and a CommandCode install through
`cmd skills add`. Two guardrails ship in 0.3.0: the markdown check after a write,
and a block on direct commits to the default branch.

Options 2 and 4 stay dead because they are cheaper but do not meet the guardrail
requirement. Option 3 beats option 2 only because of that requirement; if the
spike had failed, option 2 was the runner-up.

## Riskiest assumption

That OpenCode and Pi can register the 27 skills and block a shell command
deterministically, without forking the skill bodies.

## Cheapest test

A spike in a temporary directory, before any repository edit: load two skills in
each tool, block one `git commit`, and surface one markdown failure. Done on
2026-11-25; all three behaviours passed on OpenCode 2.4.1, Claude Code 2.1.332,
Pi 1.6.0 and CommandCode 1.93.3. See the
[plan](../plans/2026-11-25-plugin-distribution.md).
