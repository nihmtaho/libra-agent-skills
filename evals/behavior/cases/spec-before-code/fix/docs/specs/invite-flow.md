---
title: Invite flow for workspace settings
updated: 2026-11-17
---
# Invite flow for workspace settings

## Problem
Workspace owners cannot add a teammate without leaving the product. They copy an
address into a personal mailbox, so the invite has no record and no retry.

## Use cases
1. An owner types an address in workspace settings and sends one invite.
2. The owner sees who was invited, when, and whether it was accepted.
3. The owner resends an invite that was never accepted.

## Structure
- `src/settings/invite.ts` — the form and its validation; no data crosses except
  the address and the workspace id.
- `src/invite/send.ts` — takes `{address, workspaceId}`, returns `{inviteId}`.
- `src/invite/store.ts` — the pending list, one row per invite.

## Code style
- Follow `src/settings/member.ts`: named exports, one `Result` type for errors,
  no thrown strings.

## Test plan
- `npm test -- invite` — the three use cases, one assertion each.
- failure path: an address that already belongs to a member must return
  `already_member`, not send a second mail.

## Acceptance criteria
- [ ] An invite sent from settings appears in the pending list with its timestamp.
- [ ] Resending the same address twice sends one mail and returns the same
      `inviteId`.
- [ ] `npm test -- invite` exits 0.

## Out of scope
- Bulk invites by CSV: the owner can paste one address at a time this version.
- Revoking an invite after it is accepted.
