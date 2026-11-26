---
title: Plugin distribution for Claude Code, OpenCode, CommandCode and Pi
updated: 2026-11-25
---
# Plugin distribution for v0.3.0

Status: implemented 2026-11-26; release blocked on `npm login`. Branch `feat/plugin-distribution`.
Spec: [plugin-distribution](../specs/plugin-distribution.md).
Tasks: [plugin-distribution](../tasks/plugin-distribution.md).

## Goal

Ship one npm package that installs as a real plugin on Claude Code, OpenCode and
Pi, and as the same skills on CommandCode, with two guardrails that run without
a human remembering them.

## Shape

One repository, one package, four entry paths:

| Path | Purpose |
|---|---|
| `skills/libra-*/SKILL.md` | the 27 skills, unchanged, the only source |
| `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` | one Claude plugin entry |
| `hooks/hooks.json` + `hooks/guardrails/` | Claude Code hook config and scripts |
| `adapters/opencode/index.ts` | OpenCode plugin: register skills, two guardrails |
| `adapters/pi/index.ts` | Pi extension: two guardrails; skills via `pi.skills` |
| `lib/skills.mjs` | read a skill directory, strip frontmatter |
| `lib/guardrails.mjs` | commit detection, marker, markdown path filter |

`package.json` carries `exports` for OpenCode and a `pi` manifest plus the
`pi-package` keyword for Pi. The host SDKs are optional peer dependencies.

## Per-tool install

| Tool | Command | What loads |
|---|---|---|
| Claude Code | `/plugin marketplace add nihmtaho/libra-agent-skills` then `/plugin install libra@libra-agent-skills` | one plugin, 27 skills, two hooks |
| OpenCode | `opencode plugin add libra-agent-skills@0.3.0` | 27 skills, two guardrails; option `groups` filters |
| Pi | `pi install npm:libra-agent-skills@0.3.0` | 27 skills, two guardrails |
| CommandCode | `cmd skills add nihmtaho/libra-agent-skills` then pick a skill | skills only; no hook system |

## Guardrails

1. **Markdown check after a write.** Every adapter runs the shipped
   `scripts/check-docs.sh` on a `.md` path after a write or edit, and surfaces a
   FAIL to the model. Claude uses `PostToolUse`, Pi uses `tool_result`, OpenCode
   uses `tool.hook("execute.after")`.
2. **No direct commit on the default branch.** A `git commit` on `main` or
   `master` is blocked unless `docs/GIT.md` contains
   `<!-- libra:allow-direct-commit -->`. A forced push to the default branch is
   blocked by the same rule. Claude uses `PreToolUse`, Pi uses `tool_call`,
   OpenCode rewrites the command in `shell.hook("create.before")`.

## Spike evidence (2026-11-25)

| Tool | Verified |
|---|---|
| OpenCode 2.4.1 | plugin loads; `ctx.skill.transform` skills reach the model; `shell.create.before` rewrite blocks the commit; `tool.execute.after` sees `{path, content}` and the markdown FAIL reaches the model |
| Claude Code 2.1.332 | `claude plugin validate` passes; `--plugin-dir` lists the namespaced skills; `PreToolUse` blocks the commit; `PostToolUse` surfaces the markdown FAIL |
| Pi 1.6.0 | `pi -e` loads the extension; `tool_call` blocks the commit; `tool_result` surfaces the markdown FAIL |
| CommandCode 1.93.3 | `cmd skills add nihmtaho/libra-agent-skills -s libra-project-status` installs into `.commandcode/skills/` |

Findings that changed the design:

- OpenCode permission events report action `"shell"` with the command after
  `create.before` rewrote it. The commit guard is the shell rewrite, not a
  permission deny.
- The first guard implementation matched the word "exception" in `docs/GIT.md`
  and failed open in this repository. The marker replaced it.
- OpenCode returns structured tool results, so a guard appends a content part,
  never a string.
- Claude warns when `${CLAUDE_PLUGIN_ROOT}` is unquoted.
- `/api/skill` returns an empty list even when skills are loaded; acceptance uses
  the model-visible list instead.

## Order

T0 spike (done), then package skeleton, Claude, OpenCode, Pi, CommandCode and
docs, then the test and release gate. See the task file.

## Acceptance

`bash scripts/test.sh` prints `plugin tests passed` as its sixth green line, and
each of the four tools is installed once and observed to block a commit and
surface a markdown failure.

## Risks

- One `package.json` serving both OpenCode `exports` and the Pi manifest is the
  part not yet proven at pack time; T1 stops if it cannot.
- Collapsing the Claude marketplace from six groups to one entry is breaking for
  0.2 users.
- OpenCode support targets the V2 plugin API (2.4.1); older releases are out.
- Publishing needs `npm login`; `npm whoami` was unauthenticated on 2026-11-25.
