---
name: doubt-driven-development
description: Put an important claim through CLAIM, EXTRACT, DOUBT, RECONCILE and STOP in a fresh context before relying on it. Use when a claim must be re-derived in a fresh context and no command can check it.
---

# doubt-driven-development

The decisions that hurt are the ones nobody argued with. A command can settle a
fact; only another mind, given the same claim cold, can settle a judgement.

## When to use

Use before relying on an architectural call, a security or money path, a belief
about how a library behaves that nothing in the repo proves, or a claim in a spec
that was never tested.
Not for a fact a command can settle: run the command, and let `verify` report it.
Not for taste, naming or style.

## Read first

1. The claim, written in one sentence you could be wrong about.
2. What depends on it: which decision, which code, which person.
3. The evidence you actually have, quoted, not remembered.

## Steps

1. **CLAIM** — one sentence that could be false. "It is safe" is not a claim;
   "it is safe when the caller holds the lock" is.
2. **EXTRACT** — list what the claim assumes and what would break it: inputs,
   order, scale, concurrency, failure of a dependency, a second reader.
3. **DOUBT** — hand the claim, and only the claim, to a fresh context that never
   saw your reasoning: `subagent-driven-development` for the mechanics, or a
   cold re-read if you have no subagent. Ask for the strongest case against it.
   Never hand it your conclusion or your preferred answer.
4. **RECONCILE** — take each objection and file it: refuted with the evidence,
   accepted into a weaker claim, or open with what would settle it.
5. **STOP** — a claim with an open objection is not settled. Say which objection
   is open and what would close it. Do not upgrade "probably fine" to "done".

## Write

`docs/PROJECT.md` `## Next` when a failed claim becomes work, and its `## Decisions`
line only through `decide`. Otherwise `none`: a claim that survived leaves no
document, only a commit that no longer rests on a guess.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when an objection cannot be refuted and cannot be accepted without asking a
human. Report the claim, the objection, and what would settle it. One open
objection is a real answer; a fifth round of doubt is stalling.
