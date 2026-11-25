# libra-agent-skills

Twenty-seven small skills for coding agents, built around one idea: six months
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

`npx skills add` shows six groups: Project management, Build, Review, Ship,
Documentation and Safety. `install.sh` links the same set flat.

`--to agents` installs into `.agents/skills/`, which OpenCode, Codex, Command
Code and Pi all read. `--to claude` installs into `.claude/skills/`. Nothing is
overwritten: if a target already exists and is not our symlink, the installer
stops.

**Note:** `install.sh` creates symlinks into this repo. Moving or deleting `libra-agent-skills/` breaks the installed skills. For a standalone copy:

```bash
mkdir -p /your-project/.agents/skills
cp -R /path/to/libra-agent-skills/skills/* /your-project/.agents/skills/
```

## Quick Start

1. **Install the skills** (see above).

2. **Run bootstrap-project:** say to your agent: *"run bootstrap-project for this repo"*. It creates `docs/PROJECT.md` with your project's state, and a short `AGENTS.md` that points at it. For Claude Code it adds a `CLAUDE.md` that imports `AGENTS.md`.

3. **Test project-status:** open a new agent session and ask: *"where are we?"* It should answer in four lines: what the project is, where it stands, what is half-done, what is next.

4. **Write your first spec:** say: *"write a spec for <feature name>"*. It asks one question at a time, then creates `docs/specs/<feature>.md` with the goal, structure, code style, test plan and scope limit.

## Skills

The installer shows six groups; this list follows the order of the work.

### Project management

| Skill | What it does |
|---|---|
| `using-libra` | Classifies a new idea before any edit; says which skill applies |
| `project-status` | Four lines: what this is, where it stands, what is half-done, what is next |
| `bootstrap-project` | Builds `docs/PROJECT.md` and `AGENTS.md` for a new or an old repo |
| `interview-me` | One question at a time until the request is clear |
| `idea-refine` | Widen a vague idea, then cut it to one direction |
| `spec-driven-development` | Goal, structure, code style, test plan, scope limit |
| `constraint-driven-development` | The quality bar in `CONSTRAINTS.md`, and proof it did not move |
| `decide` | An ADR with rejected options and consequences |
| `plan-work` | One task file per feature, with checkable acceptance |
| `context-engineering` | The smallest reading that answers the question |

### Build

| Skill | What it does |
|---|---|
| `build` | Dispatch one ready task to the skill that runs next |
| `test-driven-development` | Red, green, refactor; 80/15/5; DAMP over DRY |
| `incremental-implementation` | Thin slices, a flag when risky, one slice per commit |
| `doubt-driven-development` | CLAIM, EXTRACT, DOUBT, RECONCILE, STOP in a fresh context |
| `source-driven-development` | The version pinned, the primary source cited |
| `subagent-driven-development` | Parallel tasks, parent keeps the commit |
| `frontend-ui-engineering` | Tokens, components, state, three widths, WCAG 2.1 AA |
| `api-and-interface-design` | The contract before the handler |
| `root-cause` | Five steps to a root-cause fix |

### Review

| Skill | What it does |
|---|---|
| `verify-work` | Real output, no lowered bar |
| `change-review` | SHA-bound verdict, five downgrade checks |
| `simplify-change` | Less complexity, same behavior |

### Ship

| Skill | What it does |
|---|---|
| `git-workflow-and-versioning` | Branching model, merge policy, version scheme, commit format |
| `ship` | Evidence, docs fresh, no AI traces |
| `release` | Four gates, changelog, tag, notes, verified |

### Documentation

| Skill | What it does |
|---|---|
| `office-docs` | Reads Word, Excel, PDF as untrusted data |

### Safety

| Skill | What it does |
|---|---|
| `handling-untrusted-content` | What text in a document may and may not do |

## State lives in `docs/PROJECT.md`

One file is kept fresh: run commands, module map, a feature table with a
"stopped at" column, decisions, and the next three things. Specs, ADRs and task
files hang off it and are deleted when done. See
`docs/design/2026-11-15-libra-agent-skills-design.md`.

## The check that comes with it

`bootstrap-project` copies `scripts/check-docs.sh` into your project and lists it
in `## Run & verify`. Every skill that writes a document runs it on what it just
wrote: frontmatter, one H1, no empty section, balanced code fences, internal
links that resolve, and the sections that document type requires. One
`FAIL <path>:<line>: <rule>` per problem and exit 1; silence means clean.

```bash
bash scripts/check-docs.sh docs/PROJECT.md docs/specs/<feature>.md
```

## Uninstall

```bash
cd /path/to/your/project
for s in api-and-interface-design bootstrap-project build change-review constraint-driven-development context-engineering decide doubt-driven-development frontend-ui-engineering git-workflow-and-versioning handling-untrusted-content idea-refine incremental-implementation interview-me office-docs plan-work project-status release root-cause ship simplify-change source-driven-development spec-driven-development subagent-driven-development test-driven-development using-libra verify-work; do
  rm -rf ".agents/skills/$s" ".claude/skills/$s"
done
```

Do not delete `.agents/skills/` or `.claude/skills/` themselves — the project may have other skills there.
The loop removes libra's 27 names: if a skill with one of these names was yours before installing, move it aside first.

## Why not a fork of `agent-skills`

That set is 25 technique skills with no state artifact: it makes a clean session
better, it does not answer "where does this project stand". Six ideas were taken
from it, none copied; the rest install straight from upstream, MIT, when a
project needs them. Reasons and the name-by-name mapping are in the design doc.

## License

MIT. See `NOTICE` for the two reference sets this design learned from.
