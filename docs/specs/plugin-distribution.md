---
title: One package that installs as a plugin on four coding agents
updated: 2026-11-25
---
# One package that installs as a plugin on four coding agents

## Problem

The 27 skills are distributed by symlink, copy and `npx skills add`, so there is
no versioned artifact a user can cite or uninstall cleanly, and each tool needs a
different instruction. The repository's rules are prose: a malformed markdown
file and a direct commit on `main` are caught only when a human remembers. A
plugin can carry both the skills and those two checks.

## Use cases

1. A new user installs on Claude Code, OpenCode, Pi or CommandCode with one
   command and sees all 27 `libra-*` skills, without cloning this repository.
2. An agent writes a markdown file with a broken table; the plugin runs the
   shipped checker and the model sees the FAIL in the same turn.
3. An agent tries `git commit` on `main` in a repository that does not record
   `<!-- libra:allow-direct-commit -->`; the commit is refused before it runs.

## Structure

- `package.json` — name `libra-agent-skills`, `exports["."]` for the OpenCode
  server part, `pi.skills` and `pi.extensions` for Pi, `keywords: ["pi-package"]`,
  optional peer dependencies on both host SDKs.
- `skills/libra-*/SKILL.md` — the 27 skills, unchanged and the only source.
- `.claude-plugin/plugin.json` — one Claude plugin named `libra`.
- `.claude-plugin/marketplace.json` — one entry, `libra`, source `"./"`; the six
  group entries are removed.
- `hooks/hooks.json` — `PreToolUse` on `Bash` and `PostToolUse` on `Write|Edit`,
  both pointing at the scripts with a quoted `${CLAUDE_PLUGIN_ROOT}`.
- `hooks/guardrails/md-check.mjs` — read the hook JSON from stdin, run
  `scripts/check-docs.sh` on a `.md` path, exit 2 with the FAIL text.
- `hooks/guardrails/git-guard.mjs` — read the hook JSON, parse the shell command,
  exit 2 when it commits on the default branch and the marker is absent.
- `adapters/opencode/index.ts` — `Plugin.define({ id: "libra", setup })`; register
  every skill through `ctx.skill.transform`, register the two guardrails, and
  read `ctx.options.groups` to filter by group.
- `adapters/pi/index.ts` — a Pi extension; `tool_call` blocks the commit,
  `tool_result` appends the markdown FAIL. Pi loads the skills itself through
  `pi.skills`.
- `lib/skills.mjs` — `loadSkills(dir)` returns `{ id, name, description, body,
  path }` for every `SKILL.md`, with frontmatter stripped.
- `lib/guardrails.mjs` — `MARKER`, `isMarkdownPath`, `defaultBranch`,
  `isDirectCommit({ command, branch, defaultBranch, gitDoc })`.
- `scripts/test-plugins.sh` — the unit and package tests wired into `test.sh`.

The seam is `lib/`: adapters and hook scripts call the same functions, so the
commit rule and the marker are defined once.

The marker is a single HTML comment, `<!-- libra:allow-direct-commit -->`, in
`docs/GIT.md`. Its absence blocks; its presence allows. It is deliberately not a
word such as "exception", which prose already contains.

## Code style

- ESM `.mjs` for shared code and hook scripts; TypeScript only in `adapters/`,
  importing the host SDK.
- No new runtime dependency: `node:fs`, `node:child_process`, `node:path`.
- Match `scripts/test-install.sh`: `set -eu`, one assertion per line, a named
  FAIL line.
- A guardrail never swallows an error: an unreadable file or a missing git
  repository is a refusal with a reason, not a silent pass.
- No change to any `skills/libra-*/SKILL.md` body in this version.

## Test plan

- `bash scripts/test-plugins.sh` — parse all 27 skills, assert unique ids and
  stripped frontmatter; table-drive `isDirectCommit` across `main`, `master`, a
  feature branch, marker present, marker absent, and `git push --force`; assert
  `isMarkdownPath`.
- `npm pack --dry-run --json` — assert 27 `SKILL.md`, `plugin.json`,
  `hooks/hooks.json`, both adapters and `scripts/check-docs.sh` are in the
  tarball.
- `bash scripts/test.sh` — the existing five lines plus `plugin tests passed`.
- Smoke, recorded in the task file: install each of the four tools, ask the model
  to list skills, attempt a commit on `main`, and write a broken table.
- Failure path: a commit on `main` without the marker exits non-zero and the bad
  table produces a FAIL that reaches the model.

## Acceptance criteria

- [ ] `bash scripts/test.sh` exits 0 and prints `plugin tests passed` after the
      existing five lines.
- [ ] `npm pack --dry-run` lists 27 `skills/libra-*/SKILL.md`,
      `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`,
      `hooks/hooks.json`, `adapters/opencode/index.ts`, `adapters/pi/index.ts` and
      `scripts/check-docs.sh`.
- [ ] Claude Code: `claude plugin validate .` passes and a `--plugin-dir` session
      lists all 27 skills; a commit on `main` is refused.
- [ ] OpenCode: an installed plugin makes the model list all 27 ids; a commit on
      `main` is refused.
- [ ] Pi: `pi install` (or `-e`) makes the model list all 27 skills; a commit on
      `main` is refused.
- [ ] CommandCode: `cmd skills add nihmtaho/libra-agent-skills -s
      libra-project-status` installs into `.commandcode/skills/`.
- [ ] `git diff main -- skills/` is empty.
- [ ] `./install.sh --to agents,claude --dest <temp>` and `npx skills add
      nihmtaho/libra-agent-skills` still install 27 skills.

## Out of scope

- The two judgement guardrails: "a spec and a task exist before the first edit"
  and "warn when `docs/PROJECT.md` did not change". They need a measured
  false-positive rate and move to 0.4.0.
- Hooks on CommandCode; it has no plugin runtime.
- Windows, telemetry, auto-update and a GUI.
- Changing the content of any skill. 0.3.0 is packaging and two checks.
- The 0.3.0 prune release; it moves to 0.4.0 by
  [ADR-0005](../adr/0005-plugin-distribution-before-the-prune.md).

## Risks

- The biggest risk is that one `package.json` cannot serve both the OpenCode
  `exports` entry and the Pi manifest cleanly. T1 proves it with
  `npm pack --dry-run` before the adapters are written.
- Collapsing the Claude marketplace from six groups to one is breaking; the
  README and CHANGELOG must say so.
- OpenCode support targets the V2 plugin API. Version 2.4.1 is the tested floor.
