---
title: Ship one plugin package for four coding agents in 0.3.0
updated: 2026-11-27
spec: ../specs/plugin-distribution.md
---
# Ship one plugin package for four coding agents in 0.3.0

Stopped at: done, released 2026-11-27.

## Checkpoint — after T1

`npm pack --dry-run --json` lists 27 `skills/libra-*/SKILL.md`, `package.json`,
`lib/`, both adapter stubs and `scripts/check-docs.sh`, and
`bash scripts/test-plugins.sh` exits 0. If one
`package.json` cannot expose the OpenCode entry and the Pi manifest at once, stop:
the fallback is a thin wrapper package for one host, and T2–T4 would be built on
the wrong shape.

- [x] **T0 — the spike that decides the design**
      Done means: OpenCode, Claude Code and Pi each load two skills and block one
      `git commit`; CommandCode installs one skill with `cmd skills add`;
      evidence is in the plan file.
      Touches: nothing in this repository; spike lives in a temporary directory.
      Depends on: none

      Findings recorded in [the plan](../plans/2026-11-25-plugin-distribution.md):
      OpenCode blocks through `shell.create.before`, not a permission deny;
      OpenCode returns structured tool results; the word "exception" fails open,
      so the marker is required; Claude needs a quoted `${CLAUDE_PLUGIN_ROOT}`;
      `/api/skill` is not an acceptance signal.

- [x] **T1 — the package skeleton and the shared rules**
      Done means: `npm pack --dry-run --json` lists the tarball contents named in
      the spec, and `bash scripts/test-plugins.sh` exits 0.
      Touches: `package.json`, `lib/skills.mjs`, `lib/guardrails.mjs`,
      `scripts/test-plugins.sh`
      Depends on: T0

      `package.json` carries `exports["."]` for OpenCode, `pi.skills` and
      `pi.extensions` for Pi, `keywords: ["pi-package"]`, `files`, and optional
      peer dependencies on `@opencode/plugin` and
      `@earendil-works/pi-coding-agent`. `lib/skills.mjs` reads
      `skills/libra-*/SKILL.md` and strips frontmatter. `lib/guardrails.mjs`
      exports `MARKER`, `isMarkdownPath`, `defaultBranch` and `isDirectCommit`.
      The test table covers `main`, `master`, a feature branch, marker present,
      marker absent, and `git push --force`. Both adapters are stubs; T3 and T4
      fill them.

- [x] **T2 — the Claude Code plugin**
      Done means: `claude plugin validate .` passes, and
      `claude --plugin-dir . -p "list skills"` lists 27 `libra-*` names.
      Touches: `.claude-plugin/plugin.json`,
      `.claude-plugin/marketplace.json`, `hooks/hooks.json`,
      `hooks/guardrails/md-check.mjs`, `hooks/guardrails/git-guard.mjs`
      Depends on: T1

      One marketplace entry named `libra` with source `"./"`; the six group
      entries go. Quote every `${CLAUDE_PLUGIN_ROOT}`. The manifest gets an
      `author`; the repository README and LICENSE cover the directory checks.
      `PreToolUse` exits 2 on a direct commit without the marker;
      `PostToolUse` exits 2 on a markdown FAIL. Both scripts read stdin JSON and
      call `lib/guardrails.mjs`.

- [x] **T3 — the OpenCode plugin**
      Done means: an installed local plugin makes the model list 27 ids and
      refuses a commit on `main`.
      Touches: `adapters/opencode/index.ts`, `lib/skills.mjs`
      Depends on: T1

      `Plugin.define({ id: "libra", setup })`; register every skill through
      `ctx.skill.transform` with `Skill.ID.make(id)` and the stripped body.
      Read `ctx.options.groups` to filter by group; no option means all 27.
      `shell.hook("create.before")` rewrites a direct commit to a failing
      command; `tool.hook("execute.after")` appends the markdown FAIL as a
      content part, not a string. Do not use the permission hook for the commit
      rule.

- [x] **T4 — the Pi extension**
      Done means: `pi -e adapters/pi/index.ts -p "list skills"` lists 27 skills,
      and a commit on `main` is refused.
      Touches: `adapters/pi/index.ts`, `package.json` (`pi` manifest)
      Depends on: T1

      `tool_call` returns `{ block: true, reason }` for a direct commit;
      `tool_result` appends the markdown FAIL to the content array and sets
      `isError`. Skills come from `pi.skills`, so the extension registers no
      skills.

- [x] **T5 — CommandCode and the documents**
      Done means: `cmd skills add nihmtaho/libra-agent-skills -s
      libra-project-status` installs, and `grep -rn "six groups"
      README.md docs/PROJECT.md` prints nothing.
      Touches: `README.md`, `CHANGELOG.md`, `docs/PROJECT.md`,
      `scripts/test-install.sh`, `docs/GIT.md`
      Depends on: T1

      README gets one install line per tool and an uninstall line per tool; the
      six-group sentence becomes one plugin. `CHANGELOG.md` records the breaking
      Claude change and the guardrails. `docs/PROJECT.md` gains the module-map
      rows and the sixth `test.sh` line only when the code exists. This
      repository's `docs/GIT.md` gets no marker: direct commits stay blocked
      here. `scripts/test-install.sh` follows the marketplace shape.

- [x] **T6 — the gate and the smoke run**
      Done means: `bash scripts/test.sh` exits 0 and prints `plugin tests passed`
      as its sixth line; the four smoke observations are written in this file.
      Touches: `scripts/test-plugins.sh`, `scripts/test.sh`, `CHANGELOG.md`
      Depends on: T2, T3, T4, T5

      Wire `test-plugins.sh` into `test.sh`. Smoke each tool once: install, list
      27, block a commit on `main`, surface a broken table. Publish with
      `npm publish` and tag `v0.3.0` only after every box above is ticked;
      `npm whoami` must answer first.

## Evidence

| Check | Result |
|---|---|
| `bash scripts/test.sh` | six green lines, `plugin tests passed` included |
| Claude Code from the packed tarball | 27 skills; commit on `main` refused; broken table FAIL surfaced |
| OpenCode from the packed tarball | 27 skills; commit refused; broken table FAIL surfaced with an absolute path |
| Pi from the packed tarball | 27 skills; commit refused; broken table FAIL surfaced |
| Command Code | `cmd skills list` sees all 27 from `.commandcode/skills` |
| `claude plugin validate .` | passed; only icon and `.DS_Store` warnings |
| `npm whoami` | authenticated as `nihmtaho` |
| `npm view libra-agent-skills version` | `0.3.0`, dist-tag `latest` |
| `git tag v0.3.0` | annotated tag on `main` |

The Command Code install was verified against the pushed `main`:
`cmd skills add nihmtaho/libra-agent-skills -s libra-project-status` installed
the prefixed skill into `.commandcode/skills/`.

## Checkpoint — after T6

Released 2026-11-27: the registry serves `0.3.0`, `main` is pushed, and the
`v0.3.0` tag points at the release commit. If a later smoke fails, cut `0.3.1`;
do not move the tag.
