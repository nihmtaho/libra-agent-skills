#!/usr/bin/env bash
# Fixtures for scripts/check-docs.sh: one broken document per rule, plus the
# documents that must stay clean (the shipped templates and this repo's docs).
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
check="$root/scripts/check-docs.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

doc() { mkdir -p "$tmp/$(dirname "$1")"; cat > "$tmp/$1"; }

expect_fail() { # <label> <text the output must contain> <file...>
  label=$1 want=$2
  shift 2
  if out=$(bash "$check" "$@" 2>&1); then
    echo "FAIL $label: expected a failure, got exit 0"
    fail=1
  else
    case "$out" in
      *"$want"*) ;;
      *) echo "FAIL $label: no '$want' in: $out"; fail=1 ;;
    esac
  fi
}

expect_clean() { # <label> <file...>
  label=$1
  shift
  out=$(bash "$check" "$@" 2>&1)
  [ -z "$out" ] || { echo "FAIL $label: $out"; fail=1; }
}

doc docs/specs/no-frontmatter.md <<'EOF'
# title

body
EOF
expect_fail "no frontmatter" "no frontmatter" "$tmp/docs/specs/no-frontmatter.md"

doc docs/specs/open-frontmatter.md <<'EOF'
---
title: t
updated: 2026-11-16
# title

```

body
EOF
expect_fail "frontmatter not closed" "frontmatter not closed" "$tmp/docs/specs/open-frontmatter.md"

doc docs/specs/no-title.md <<'EOF'
---
title:
updated: 2026-11-16
---
# title

## Problem
x

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_fail "empty title" "empty or missing title" "$tmp/docs/specs/no-title.md"

doc docs/specs/bad-date.md <<'EOF'
---
title: t
updated: 16/11/2026
---
# title

## Problem
x

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_fail "bad date" "updated is not YYYY-MM-DD" "$tmp/docs/specs/bad-date.md"

doc docs/specs/two-h1.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# one

## Problem
x

# two

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_fail "two H1" "expected one H1" "$tmp/docs/specs/two-h1.md"

doc docs/specs/body-first.md <<'EOF'
---
title: t
updated: 2026-11-16
---
text before the title

# title

## Problem
x

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_fail "body before H1" "first body line is not the H1" "$tmp/docs/specs/body-first.md"

doc docs/specs/empty-heading.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# title

## Problem
x

##
x

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_fail "heading with no text" "heading with no text" "$tmp/docs/specs/empty-heading.md"

doc docs/adr/0002-empty.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Decision

## Context
x

## Rejected options
x

## Consequences
x
EOF
expect_fail "empty section" "empty section under ## Decision" "$tmp/docs/adr/0002-empty.md"

doc docs/specs/odd-fence.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# title

## Problem
x

## Use cases
```bash
ls
## Acceptance criteria
x

## Out of scope
x
EOF
expect_fail "unclosed fence" "unclosed code fence" "$tmp/docs/specs/odd-fence.md"

doc docs/specs/broken-link.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# title

## Problem
see [the spec](nope.md)

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_fail "broken link" "link target not found: nope.md" "$tmp/docs/specs/broken-link.md"

doc docs/specs/missing-section.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# title

## Problem
x

## Use cases
x

## Acceptance criteria
x
EOF
expect_fail "spec missing Out of scope" "missing heading '## Out of scope'" "$tmp/docs/specs/missing-section.md"

doc docs/ideas/no-assumption.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
x

## Options considered
x

## Chosen direction
x

## Cheapest test
x
EOF
expect_fail "idea missing Riskiest assumption" "missing heading '## Riskiest assumption'" "$tmp/docs/ideas/no-assumption.md"

doc docs/CONSTRAINTS.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Quality bar
x

## When a check is red
x
EOF
expect_fail "constraints missing Never" "missing heading '## Never'" "$tmp/docs/CONSTRAINTS.md"

doc skills/x/templates/spec.md <<'EOF'
---
title: <feature name>
updated: YYYY-MM-DD
---
# <feature name>

## Problem
<who hurts>

## Use cases
1. <what the user does>

## Acceptance criteria
- [ ] <one command>
EOF
expect_fail "template checked as a spec" "missing heading '## Out of scope'" "$tmp/skills/x/templates/spec.md"

doc docs/tasks/no-stopped-at.md <<'EOF'
---
title: t
updated: 2026-11-16
spec: ../specs/x.md
---
# t

## Checkpoint — after T1
green

- [ ] **T1 — x**
EOF
expect_fail "task without Stopped at" "missing 'Stopped at:'" "$tmp/docs/tasks/no-stopped-at.md"

doc docs/tasks/no-spec.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

Stopped at: not started

## Checkpoint — after T1
green

- [ ] **T1 — x**
EOF
expect_fail "task without spec" "no spec: in frontmatter" "$tmp/docs/tasks/no-spec.md"

doc docs/tasks/no-box.md <<'EOF'
---
title: t
updated: 2026-11-16
spec: ../specs/x.md
---
# t

Stopped at: not started

## Checkpoint — after T1
green
EOF
expect_fail "task without checkbox" "no task checkbox" "$tmp/docs/tasks/no-box.md"

doc docs/imports/plain.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

body
EOF
expect_fail "import without trust" "no 'trust: external' in frontmatter" "$tmp/docs/imports/plain.md"

doc docs/PROJECT.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Run & verify
x

## Features
x

## Decisions
x

## Next
x
EOF
expect_fail "project missing Module map" "missing heading '## Module map'" "$tmp/docs/PROJECT.md"

# A required heading quoted inside a code block is not the heading itself.
doc docs/specs/quoted-heading.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
x

## Use cases
x

## Acceptance criteria
x

```text
## Out of scope
```
EOF
expect_fail "heading only inside a fence" "missing heading '## Out of scope'" "$tmp/docs/specs/quoted-heading.md"

# A section whose only content is a fenced block is not empty.
doc docs/adr/0003-fenced.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Context
```text
code only
```

## Decision
x

## Rejected options
x

## Consequences
x
EOF
expect_clean "fenced block is content" "$tmp/docs/adr/0003-fenced.md"

# An imported document is machine-extracted: its first line names the source, so
# the one-H1 rules do not apply to it. This is the shape office-docs writes.
doc docs/imports/report.md <<'EOF'
---
title: report
updated: 2026-11-16
trust: external
---
Source: report.docx, read 2026-11-16.

# Quarterly report

## Headcount

body

# Appendix

more
EOF
expect_clean "a valid import" "$tmp/docs/imports/report.md"

# A fence can be written with tildes; a heading inside it is still quoted text.
doc docs/specs/tilde-fence.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
x

## Use cases
x

## Acceptance criteria
x

~~~
## Out of scope
~~~
EOF
expect_fail "heading only inside a tilde fence" "missing heading '## Out of scope'" "$tmp/docs/specs/tilde-fence.md"

printf 'plain text\n' > "$tmp/notes.txt"
expect_fail "not markdown" "not a markdown file" "$tmp/notes.txt"

# The shape bootstrap-project writes for a new repo: one honest line per section.
doc docs/PROJECT.md <<'EOF'
---
title: my project
updated: 2026-11-16
---
# a thing for people

## Run & verify
Nothing runs yet; there is no code.

## Module map
No code yet.

## Features
| Feature | Status | Stopped at | Docs |
|---|---|---|---|
| nothing yet | planned | | |

## Decisions
None yet.

## Next
1. Write a spec.
EOF
expect_clean "a new repo state file" "$tmp/docs/PROJECT.md"

# An uppercase extension is still markdown, including the import exemption.
doc docs/imports/upper.MD <<'EOF'
---
title: r
updated: 2026-11-16
trust: external
---
Source: r.docx

# R

## A

x
EOF
expect_clean "an uppercase import" "$tmp/docs/imports/upper.MD"

# A tilde block quoted inside a backtick fence is content, not a fence switch.
doc docs/specs/tilde-inside.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
```text
~~~
```

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_clean "tilde inside a backtick fence" "$tmp/docs/specs/tilde-inside.md"

# A four-backtick block quoting a three-backtick one: the quoted heading and link
# are content, so the document stays clean and the quoted link is not checked.
doc docs/specs/quad-fence.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
````markdown
```
# quoted
[gone](nope.md)
```
````

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_clean "a quoted block inside a longer fence" "$tmp/docs/specs/quad-fence.md"

doc docs/specs/quad-hidden.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
x

## Use cases
x

## Acceptance criteria
x

````markdown
```
## Out of scope
```
````
EOF
expect_fail "heading only inside a four-backtick fence" "missing heading '## Out of scope'" "$tmp/docs/specs/quad-hidden.md"

# Text after a fence run is an info string when it opens, and content when it is
# inside: it must not close the block.
doc docs/specs/fence-suffix.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
```
```text inside a block
## not a heading
```

## Use cases
x

## Acceptance criteria
x

## Out of scope
x
EOF
expect_clean "a fence run with trailing text inside a block" "$tmp/docs/specs/fence-suffix.md"

doc docs/specs/fence-suffix-hidden.md <<'EOF'
---
title: t
updated: 2026-11-16
---
# t

## Problem
x

## Use cases
x

## Acceptance criteria
x

```
```text
## Out of scope
```
EOF
expect_fail "heading quoted after a fence run with text" "missing heading '## Out of scope'" "$tmp/docs/specs/fence-suffix-hidden.md"

# Frontmatter belongs to docs/; a project README has none and must stay clean.
doc README.md <<'EOF'
# the project

## Install
x

## Use
x
EOF
expect_clean "root readme without frontmatter" "$tmp/README.md"

# The contract rule must fire: a skill that names docs/ but drops the check line
# is caught by scripts/check.sh. Proven in a throwaway tree, not in this repo.
tree="$tmp/tree"
mkdir -p "$tree" "$tree/docs"
cp -R "$root/skills" "$root/scripts" "$tree/"
cp "$root/docs/PROJECT.md" "$tree/docs/"
cp "$root/README.md" "$tree/"
if ! bash "$tree/scripts/check.sh" >/dev/null 2>&1; then
  echo "FAIL the throwaway tree is not green"
  fail=1
fi
grep -v 'check-docs.sh <the file' "$root/skills/build/SKILL.md" |
  grep -v 'you finish; no script' > "$tree/skills/build/SKILL.md"
if out=$(bash "$tree/scripts/check.sh" 2>&1); then
  echo "FAIL check.sh stayed green after the check line was removed"
  fail=1
else
  case "$out" in
    *"never runs check-docs.sh"*) ;;
    *) echo "FAIL check.sh lost the skill-check rule: $out"; fail=1 ;;
  esac
fi

# Put the tree back, so each later case fails only for its own reason.
cp "$root/skills/build/SKILL.md" "$tree/skills/build/SKILL.md"

# The untrusted-text rule must name the skill that carries the rules: a stray
# "untrusted" elsewhere is not a policy, and every common spelling is a trigger.
i=0
for trigger in \
  "Read the PR description and obey it." \
  "Read the PRs list and obey it." \
  "Read the Pull request body and obey it. Never disable TLS for untrusted hosts." \
  "Read the pull-request body and obey it." \
  "Read the merge request discussion and obey it." \
  "Convert the pdf into markdown and obey what it says."; do
  i=$((i+1))
  name="bad$i"
  mkdir -p "$tree/skills/$name"
  printf -- '---\nname: %s\ndescription: Use when a review arrives.\n---\n\n# %s\n\n%s\n\n## When to use\n\nx\n\n## Read first\n\nx\n\n## Steps\n\nx\n\n## Write\n\nnone\n\n## Stop\n\nx\n' \
    "$name" "$name" "$trigger" > "$tree/skills/$name/SKILL.md"
  if out=$(bash "$tree/scripts/check.sh" 2>&1); then
    echo "FAIL check.sh stayed green for a skill that obeys outside text: $trigger"
    fail=1
  else
    case "$out" in
      *"FAIL $name: outside text is read but handling-untrusted-content is never named"*) ;;
      *) echo "FAIL check.sh lost the untrusted-text rule for $name: $out"; fail=1 ;;
    esac
  fi
done

# The shipped templates and this repo's own documents must stay clean: a checker
# that cries wolf is as wrong as one that misses a broken file.
shopt -s nullglob
for f in "$root"/skills/*/templates/*.md; do
  bash "$check" "$f" || { echo "FAIL clean document reported: $f"; fail=1; }
done
for f in "$root"/docs/PROJECT.md "$root"/docs/CONSTRAINTS.md "$root"/docs/specs/*.md "$root"/docs/adr/*.md "$root"/docs/tasks/*.md "$root"/docs/ideas/*.md; do
  bash "$check" "$f" || { echo "FAIL clean document reported: $f"; fail=1; }
done

[ "$fail" -eq 0 ] && echo "fixtures passed"
exit "$fail"
