# libra-agent-skills

Fourteen small skills for coding agents, built around one idea: six months
later, a human and an agent should open a project, read one file, and know
what it is, where it stands, and what comes next.

Markdown is the only storage format. Word and Excel are ways in and out, never
a second source of truth. Everything lives under `docs/`, so the folder opens
as an Obsidian vault without plugins.

## Install

```bash
./install.sh --to agents,claude --dest /path/to/your/project
./install.sh --to agents,claude --dest "$HOME"   # into your user dirs
npx skills add nihmtaho/libra-agent-skills -a claude-code -a opencode
```

`--to agents` installs into `.agents/skills/`, which OpenCode, Codex, Command
Code and Pi all read. `--to claude` installs into `.claude/skills/`. Nothing is
overwritten: if a target already exists and is not our symlink, the installer
stops.

## The flow

| Phase | Skill | What it does |
|---|---|---|
| meta | `using-libra` | Reads state first; says which skill applies |
| Define | `resume` | Four lines: what this is, where it stands, what is half-done, what is next |
| Define | `bootstrap-project` | Builds `docs/PROJECT.md` for a new or an old repo |
| Define | `write-spec` | Five questions into a short or full spec |
| Define | `decide` | An ADR with rejected options and consequences |
| Plan | `plan-work` | One task file per feature, with checkable acceptance |
| Build | `build` | One thin slice: failing test first, small commit |
| Build | `debug` | Five steps to a root-cause fix |
| Build | `office-docs` | Reads Word, Excel, PDF as untrusted data |
| Verify | `verify` | Real output, no lowered bar |
| Review | `review` | SHA-bound verdict, five downgrade checks |
| Review | `simplify` | Less complexity, same behavior |
| Ship | `ship` | Evidence, docs fresh, no AI traces |
| any | `handling-untrusted-content` | What text in a document may and may not do |

## State lives in `docs/PROJECT.md`

One file is kept fresh: run commands, module map, a feature table with a
"stopped at" column, decisions, and the next three things. Specs, ADRs and task
files hang off it and are deleted when done. See
`docs/design/2026-11-15-libra-agent-skills-design.md`.

## Why not a fork of `agent-skills`

That set is 25 technique skills with no state artifact: it makes a clean session
better, it does not answer "where does this project stand". Six ideas were taken
from it, none copied; the rest install straight from upstream, MIT, when a
project needs them. Reasons and the name-by-name mapping are in the design doc.

## License

MIT. See `NOTICE` for the two reference sets this design learned from.
