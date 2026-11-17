---
name: frontend-ui-engineering
description: Build a screen from components, one design system and one state model, and make it work at every width and for every keyboard. Use when building or changing a component, a responsive layout, or an accessibility fix.
---

# frontend-ui-engineering

A screen is three decisions, not one: what it is made of, where its truth lives,
and who can use it. Made separately, in that order, each stays cheap. Made
together, every new screen costs the same as the first.

## When to use

Use when adding or changing a screen or a component, when a layout must work at
more than one width, or when someone reports that a control cannot be reached by
keyboard.
Not for a copy change or a colour tweak that the design system already names.

## Read first

1. `docs/design-system.md` if it exists: tokens, existing components, where state
   lives.
2. The component the change replaces or sits beside, to follow its shape.
3. The state conventions already in the app: query library, store, or props only.
   A second pattern is a second bug surface.

## Steps

1. Tokens before literals: colour, spacing, type and radius come from the design
   system, never from a hex value typed into a component. A token that does not
   exist is a change to the system, not a local exception.
2. One component, one responsibility. A component that fetches, formats and paints
   is three components: split by what changes for a different reason.
3. Props in, events out. A component that reaches into a global store, a router
   and a fetch is not reusable and cannot be tested alone.
4. Name the two states separately: server state (what the API said) and UI state
   (what this screen is doing). One source per value; derive the rest. Never copy
   server data into local state unless you also decide when it goes stale.
5. Every layout works at 320, 768 and 1280 pixels wide at least, with no fixed
   width on a container. Check with the viewport, not by eye.
6. Accessibility, WCAG 2.1 AA: every control is reachable and operable by keyboard,
   focus is visible, every input has a label, images have alt text (empty when
   decorative), body text contrast is at least 4.5:1 and large text 3:1, meaning is
   never carried by colour alone, and `prefers-reduced-motion` is respected.
7. A screen is done when it works with the keyboard only and at the narrowest
   width. Not before.

## Write

`docs/design-system.md` when the system does not exist yet or a token or component
was added to it: tokens, the components that exist, and where state lives. One
page; it is a reference, not a design document.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when the design source is a picture only the human can interpret, when a
token is missing and the human must choose its value, or when passing accessibility
would change the design (say which rule and what it costs).

Coverage cut on purpose: animation choreography, internationalisation layout, and
design-tool integration are out of scope for this skill. Say so rather than
inventing a rule.
