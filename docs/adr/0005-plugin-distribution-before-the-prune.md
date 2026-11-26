---
title: Ship plugin distribution in 0.3.0, and move the prune release to 0.4.0
updated: 2026-11-25
---
# Ship plugin distribution in 0.3.0, and move the prune release to 0.4.0

## Context

`docs/PROJECT.md` planned 0.3.0 as the prune release after the two-week field
test ends on 2026-12-05, with no new skill. The human asked for one installable
plugin per coding agent and chose real plugin code with guardrails, not a
zero-code manifest. A spike on 2026-11-25 proved the OpenCode, Claude Code and Pi
plugin APIs can register the skills and block a commit; CommandCode has only
Agent Skills.

Two guardrails are deterministic and cheap to test: the markdown check after a
write, and a block on direct commits to the default branch. Two others — require
a spec and task before the first edit, and warn when `docs/PROJECT.md` did not
change — depend on judging intent and need a false-positive measurement.

## Decision

0.3.0 is the plugin release: one npm package `libra-agent-skills` that installs as
a Claude Code plugin, an OpenCode plugin, a Pi package and a CommandCode skill
source. It ships the two deterministic guardrails. The prune release, the two
judgement guardrails and Phase B move to 0.4.0, after the 2026-12-05 field-test
review.

The Claude marketplace collapses from six group entries to one `libra` entry,
because a plugin manifest with hooks and an entry that declares `skills` under
`strict: false` conflict. CommandCode remains skills-only.

The direct-commit guard reads a machine marker,
`<!-- libra:allow-direct-commit -->`, in `docs/GIT.md`. It does not read the word
"exception": this repository contains that word in prose, and the first spike
implementation failed open because of it.

## Rejected options

- **Keep 0.3.0 as the prune release and ship plugins in 0.4.0.** Honest to the
  old roadmap, but the human asked to ship now, and the field test can finish
  while plugin work runs on a branch.
- **Zero-code manifests only.** Cheaper and enough to distribute the skills, but
  it cannot enforce the two guardrails, which the human required.
- **Six packages, one per group.** Keeps the current Claude group UX, but six
  versions and six publishes for no behaviour gain.
- **Ship all four guardrails in 0.3.0.** The two judgement guards would ship
  without a false-positive measurement and would block legitimate work.
- **Keep the six Claude entries and drop hooks.** Loses the guardrail on the
  tool where hooks are most mature.

## Consequences

- 0.3.0 is a breaking release for Claude marketplace users: six groups become
  one plugin, and `npx skills add` shows one group instead of six.
- Publishing needs an authenticated npm account; `npm whoami` was unauthenticated
  on 2026-11-25.
- OpenCode support targets the V2 plugin API; 2.4.1 is the tested floor.
- One `package.json` must serve both the OpenCode `exports` entry and the Pi
  manifest. If it cannot, the fallback is a thin wrapper package for one host,
  decided in T1.
- The 0.4.0 scope now holds the prune, the two judgement guardrails and Phase B;
  it is larger than the old 0.3.0 and needs its own spec.
