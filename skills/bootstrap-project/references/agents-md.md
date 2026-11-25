# AGENTS.md

Keep it under 200 lines. It is read at the start of every session, so it holds
only what an agent needs before reading the code: how to run the project, the
conventions that differ from the default, and the boundaries. It points at
`docs/PROJECT.md`; it does not repeat the state file.

## Template

```markdown
# AGENTS.md

Read `docs/PROJECT.md` before any work: it says what this project is, what is
done, and what is next. If it is missing, run bootstrap-project first.
A new idea or a behavior change goes through `using-libra` before any edit: a
feature gets a spec and a task file first, and the branch is created before the
first edit.
A question gets an answer, not an edit: no branch, task or code change unless the
human asks for one.
A hunch or feature name with no shape goes through `idea-refine`; a request with
two readings goes through `interview-me`.

## Run & verify

- Install: <command>
- Test: <command>
- Run: <command>

## Conventions

- <one concrete rule per line, e.g. "Use 2-space indentation">

## Layout

- `<path>` — <what lives here and where it breaks>

## Boundaries

- Never <destructive or sensitive action> without asking.
- Never commit secrets, credentials or private paths.

## Rules that outlive a session

- <a rule learned from a repeated mistake, one checkable line each>
```

## Rules

- One source of truth. Run commands and module map live in `docs/PROJECT.md`;
  link to them instead of copying them.
- Concrete beats general: `npm test`, not "test your changes".
- Delete a line the code can show. Keep pitfalls, rationale and conventions
  that differ from the tool's default.
- A rule nobody can check is a mood. Write a command or a checkable statement.
- No secrets, tokens or private paths.

## Equivalent files

Create only the files the project's tools actually read:

| Tool | File |
|---|---|
| Codex, OpenCode, Command Code, Pi | `AGENTS.md` |
| Claude Code | `CLAUDE.md` containing `@AGENTS.md` (an import, not a copy) |
| Gemini CLI | `GEMINI.md` pointing at the same content |
| Cursor | `.cursor/rules/*.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Windsurf | `.windsurfrules` |

Prefer one canonical `AGENTS.md` plus imports or symlinks. A second copy that
can drift is worse than no second file.
