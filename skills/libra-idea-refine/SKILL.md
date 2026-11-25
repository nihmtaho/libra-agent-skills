---
name: libra-idea-refine
description: Widen a vague idea into a set of options, then keep one and record why the rest died. Use when the human has a hunch, a feature name or a complaint and no shape yet.
---

# libra-idea-refine

Widen first, or you will polish the first idea. Narrow second, or you will ship a
list. The output is one direction, the options it beat, and the assumption that
could kill it.

## When to use

Use when the idea is a feeling ("we should do something about onboarding"), when
a solution arrived before the problem, or when the first proposal is suspiciously
easy.
Not for a request you cannot restate yet (`libra-interview-me`) or a direction already
chosen (`libra-spec-driven-development` writes it down).

## Read first

1. `docs/PROJECT.md` — what exists, so the idea is not already built.
2. `docs/ideas/` for an earlier pass at this idea. Extend that file; do not open
   a second one for the same idea.
3. The four-line summary from `libra-interview-me`, if this session has one.

## Steps

Widen, without judging yet:

1. Name the problem under the idea: who hurts, how often, what they do today
   instead.
2. Write 5 to 7 different answers. Vary scope (tweak vs rebuild), kind (product,
   process, policy) and timing. Include one that removes something and one that
   does the opposite of the obvious move.
3. For each, one line: what it costs and what it assumes.

Narrow:

4. Kill options on the assumption that is cheapest to test, not on taste. One line
   per death, so the next reader does not revive it.
5. Keep one direction, the runner-up, and the condition under which the runner-up
   wins.
6. Name the riskiest assumption — the one that, if false, kills the direction —
   and the cheapest test that would show it false before any code.
7. Hand off: `libra-spec-driven-development` for the spec, `libra-decide` if two directions
   are still alive, `libra-interview-me` if the problem itself is still fuzzy.

## Write

`docs/ideas/<slug>.md` from the template. Nothing else unless the human wants it
tracked, then one row in `docs/PROJECT.md` `## Features` with status `idea`.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when the problem cannot be stated without the solution inside it: that is an
`libra-interview-me` problem, not an idea. Stop also when the direction needs a decision
only the human can make; write both options into the file and say so.
