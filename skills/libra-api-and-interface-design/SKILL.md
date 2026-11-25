---
name: libra-api-and-interface-design
description: Write the contract before the handler — shapes, errors, versioning, validation at the boundary. Use when adding an endpoint or changing an API, a response shape or an error format.
---

# libra-api-and-interface-design

Callers build on what they observe, not on what you meant. A contract written
before the code is the only moment you get to choose what they can depend on.

## When to use

Use when adding an endpoint or a public function, when changing a response shape,
when touching the error format, or when defining an event or a message schema.
Not for a change no caller outside the file can see: that is ordinary code.

## Read first

1. `docs/api/` for the contract this one must match, and the error format every
   endpoint already uses.
2. The callers in this repository. What they read today is the contract, whatever
   the document says.
3. `docs/adr/` for a decision already made about this interface.

## Steps

1. Write the contract first in `docs/api/<name>.md`: method and path (or the
   signature), the request shape, the success shape, every error shape with its
   status, the auth it needs, and the version it belongs to. Before the handler.
2. Apply Hyrum's Law: every observable behaviour is a contract someone will rely
   on — field order, null versus absent, error text, status codes, timing. Anything
   you would not promise, do not expose. Do not leak a database column name.
3. One error format, everywhere: a stable machine-readable code plus a human
   message, and the same envelope in every failure. The envelope is a body shape,
   not a list of codes. Never return a raw exception; never return 200 with a
   failure inside unless the whole API already does.
4. Validate at the boundary, once: reject a missing, unknown or wrongly typed
   field at the edge, before any business logic. Never trust a caller's type,
   however typed the client is. A handler that names error shapes but rejects
   no bad field is not done.
5. A write that can be retried is idempotent: a key the caller supplies, or a
   documented rule for repeating it safely.
6. Additive change needs no version; a breaking change does. Say which one this
   is, in the contract and in the commit.
7. Update the contract in the same change as the code. A contract that lies is
   worse than no contract, because the next reader believes it.

## Write

`docs/api/<name>.md` — the contract, with the error shapes spelled out.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when two error conventions exist and neither is declared canonical, when a
breaking change has consumers you cannot list, or when the contract cannot be
expressed in the current types without a decision the spec does not make. Report
which one.
