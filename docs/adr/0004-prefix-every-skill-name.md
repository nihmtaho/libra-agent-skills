---
title: A skill name carries the libra- prefix, so no tool's command can collide
updated: 2026-11-25
---
# A skill name carries the libra- prefix, so no tool's command can collide
## Context
A skill is installed as a directory under `.agents/skills/` or `.claude/skills/`,
and its directory name, its frontmatter `name` and the word a human invokes are
one string. That makes the name a global identifier inside every tool that loads
the set. When a tool ships a command with the same name, one of the two silently
wins, and the human cannot tell which.

Phase A answered the problem name by name: `resume`, `review`, `verify`,
`simplify` and `debug` were renamed once, with no check left behind. `ship` has
since collided with a command Claude ships. A tool adds commands on its own
schedule; this repo cannot watch it, and a reserved-name list would be wrong on
the day of the next release. The failure mode is silent, so the method has to be
one that cannot be forgotten.
## Decision
Every skill name begins with `libra-`. The directory, the frontmatter `name` and
the H1 are the same string, so one rule covers all three. `scripts/check.sh`
fails a name that does not match `libra-*`, and `scripts/test-check-docs.sh`
proves the rule fires on a tree that was green first.

The rule is a prefix, not a list: a tool would have to ship a command starting
with `libra-` to collide, and this set owns that namespace. One name is not
formed by adding the prefix: `using-libra` becomes `libra-start`, because
`libra-using-libra` is a stutter on the line every generated `AGENTS.md` carries.
It still satisfies the rule.

This is a breaking change to the public surface. The 27 invocation names change,
every install must be refreshed, and the README names the old links to remove.
`CHANGELOG.md` records it under `Unreleased`; the version bump belongs to
`release`.
## Rejected options
- **Rename only the names that collide today.** Phase A did exactly this, and
  `ship` collided within days. The rename is cheap and the second one is not,
  because by then the old names are in other people's projects.
- **Keep a reserved-name list per tool and check against it.** The list has to be
  refreshed whenever Claude, Codex, OpenCode or Cursor ships a command, and
  nothing here can detect that a refresh is due. A stale list passes a name that
  collides and fails a name that does not.
- **Namespace at install time.** Plugin installs namespace their commands, but
  `install.sh` and `npx skills add` write flat directories, and flat is the only
  layout Codex and OpenCode read. The collision survives where it matters most.
- **Prefix only the short, generic names (`build`, `release`, `ship`).** Deciding
  which names are generic is a judgment that cannot be checked, and the judgment
  is the part that failed before.
- **Keep `using-libra` unprefixed as the one known-safe name.** "Known safe" is
  the claim that just failed for `ship`, and a single exception reopens the
  question for the next name.
## Consequences
- A human types `libra-ship` and the tool's `/ship` still works. The two can be
  installed side by side, which was the point.
- Names are longer: the longest is `libra-constraint-driven-development` at 35
  characters, inside the 64 a skill name allows.
- A request routes by `description`, so routing is untouched; only what a human
  types and what the files are called change.
- Upgrading costs one removal of 27 old links. The README carries the paragraph,
  and the uninstall loop lists the new names only.
- Adding a skill is now self-checking: an unprefixed name fails before it is
  committed, and the migration of this version is the only one of its kind.
