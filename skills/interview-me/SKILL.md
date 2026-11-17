---
name: interview-me
description: Ask one question per turn until a request has one reading, and write nothing. Use when a request is ambiguous, when two readings are possible, or when the human says you know what I mean.
---

# interview-me

One question per turn. The interview ends when you can predict the answer to the
next question, not when you run out of questions.

## When to use

Use when the request could mean two different things, when a decision is
expensive to reverse, or when someone says "you know what I mean".
Not for a hunch that needs options (`idea-refine`), a chosen direction
(`spec-driven-development`), or a request whose acceptance line is already
written (`build`).

## Read first

1. `docs/PROJECT.md` — what already exists, so you do not ask what the file
   already answers.
2. The sentence the human used, word for word. Quote it back before question one.
3. `docs/CONSTRAINTS.md` if it exists: the quality bar is not up for interview.

## Steps

1. Write the one sentence you think they want, in your own words, and ask them to
   correct it. That is question zero; it costs a turn and saves five.
2. Ask one question at a time. Never a list, never "and also": a list gets one
   answer for five questions.
3. Ask the question whose answer changes the most. Order: who is hurt, what they
   do today, what would prove it worked, what must not change, what the budget is
   (time, money, people).
4. After each answer, restate in one line what changed in your understanding. If
   nothing changed, the question was wrong; ask a sharper one.
5. Stop at 95%: you can state the goal, three use cases, the checkable acceptance
   line, and the one thing that would make it wrong — without guessing. Write
   those four lines and ask "anything wrong in this?".
6. Cap it at eight questions. Past that, the missing answer is usually a decision
   the human has not made, not a fact you can extract. Say which of the five
   answers is missing and stop.

## Write

none — the four-line summary goes in the reply. If the answers need a document,
the next skill is `idea-refine` for a hunch, `spec-driven-development` for
something clear enough to spec, or `decide` for a choice between options.

## Stop

Stop when an answer would change scope and only the human can give it, when the
question is really a decision (hand it to `decide`), or at the eight-question cap.
Never fill a missing answer with a plausible one.
