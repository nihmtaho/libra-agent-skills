#!/usr/bin/env bash
# Contract evals for the Define skills: the rules that make each skill do its
# job, the one-owner-per-artifact rule, and the wiring between them.
# These prove the rules are written down and unambiguous. They cannot prove an
# agent follows them; evals/README.md holds the live rubric for that.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0

write_body() { awk '/^## Write$/{f=1;next} /^## /{f=0} f' "$1"; }
steps_body() { awk '/^## Steps$/{f=1;next} /^## /{f=0} f' "$1" | tr '\n' ' ' | tr -s ' '; }

# Prose reflows, so match against a flattened copy: a rule split across two
# lines is still the rule.
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }

has() { # <skill> <fixed string> <rule label>
  flat "$root/skills/$1/SKILL.md" | grep -qiF -- "$2" ||
    { echo "FAIL $1: $3"; fail=1; }
}

# --- interview-me: asks, never writes, never guesses -------------------------
write_body "$root/skills/interview-me/SKILL.md" | grep -q 'none' ||
  { echo "FAIL interview-me: Write must be none, it is a conversation"; fail=1; }
has interview-me 'One question per turn'        'does not state one question per turn'
has interview-me 'Stop at 95%'                  'has no stopping rule, so the interview never ends'
has interview-me 'Cap it at eight questions'    'has no cap, so a decision becomes ten questions'
has interview-me 'Never fill a missing answer'  'may invent an answer instead of reporting a gap'
has interview-me 'idea-refine'                  'does not hand off to idea-refine'

# --- idea-refine: widens before it narrows ----------------------------------
has idea-refine '5 to 7 different answers'      'does not force more than one option'
has idea-refine 'One line per death'            'does not record why an option died'
has idea-refine 'riskiest assumption'           'names no assumption that could kill the direction'
has idea-refine 'Cheapest test'                 'has no cheap test before code'
write_body "$root/skills/idea-refine/SKILL.md" | grep -qF 'docs/ideas/' ||
  { echo "FAIL idea-refine: Write does not name docs/ideas/"; fail=1; }

# --- spec-driven-development: the six parts, before code --------------------
for part in 'Goal:' 'Structure:' 'Code style:' 'Test plan:' 'Limits:'; do
  has spec-driven-development "$part" "does not require the $part part"
done
has spec-driven-development 'checkable by a command or an observation' \
  'acceptance criteria may be unverifiable'
has spec-driven-development '## Open questions'  'has nowhere to park an unanswered question'
has spec-driven-development 'Never guess one'    'may guess an answer into the spec'
has spec-driven-development 'plan-work'          'does not hand off to plan-work'
write_body "$root/skills/spec-driven-development/SKILL.md" | grep -qF 'docs/specs/' ||
  { echo "FAIL spec-driven-development: Write does not name docs/specs/"; fail=1; }

# --- constraint-driven-development: the bar, and the ways it is lowered -----
for way in 'deleting or commenting a test' 'a new skip' 'a looser threshold' \
           'a new ignore comment'; do
  has constraint-driven-development "$way" "does not name '$way' as a non-fix"
done
has constraint-driven-development "human's name"   'a lowered bar needs no name'
has constraint-driven-development 'count of tests' 'does not compare numbers to the file'
write_body "$root/skills/constraint-driven-development/SKILL.md" | grep -qF 'docs/CONSTRAINTS.md' ||
  { echo "FAIL constraint-driven-development: Write does not name docs/CONSTRAINTS.md"; fail=1; }

# --- one owner per artifact --------------------------------------------------
owners() {
  for d in "$root"/skills/*/; do
    n=$(basename "$d")
    write_body "$d/SKILL.md" | grep -qF -- "$1" && printf '%s\n' "$n"
  done
}
for artifact in 'docs/specs/' 'docs/ideas/' 'docs/CONSTRAINTS.md'; do
  names=$(owners "$artifact")
  count=$(printf '%s' "$names" | grep -c .)
  [ "$count" -eq 1 ] ||
    { echo "FAIL ownership: $artifact has $count owners: $(printf '%s' "$names" | tr '\n' ' ')"; fail=1; }
done

# --- the bar is read where it is enforced -----------------------------------
has verify 'docs/CONSTRAINTS.md' 'the floor is checked without the project bar'
has review 'docs/CONSTRAINTS.md' 'the downgrade check ignores the project bar'

# --- templates ship with the skills that write them -------------------------
for s in idea-refine spec-driven-development constraint-driven-development; do
  ls "$root/skills/$s/templates/"*.md >/dev/null 2>&1 ||
    { echo "FAIL $s: writes a document but ships no template"; fail=1; }
done

# --- build: a commit knows its branch ---------------------------------------
steps_body "$root/skills/build/SKILL.md" | grep -qiF 'git rev-parse --abbrev-ref HEAD' ||
  { echo "FAIL build: may commit without knowing the branch"; fail=1; }

# --- release: the gates are commands in the steps, not advice ---------------
for gate in 'git rev-parse --abbrev-ref HEAD' 'git status --short' \
            'git status -sb' 'git tag -l' 'git ls-remote --tags origin'; do
  steps_body "$root/skills/release/SKILL.md" | grep -qiF -- "$gate" ||
    { echo "FAIL release: gate '$gate' is not in the steps"; fail=1; }
done
steps_body "$root/skills/release/SKILL.md" | grep -qiF 'exit 0 and print nothing' ||
  { echo "FAIL release: gate 4 lets an unreachable host look like a free name"; fail=1; }
steps_body "$root/skills/release/SKILL.md" | grep -qiF 'behind' ||
  { echo "FAIL release: gate 3 does not refuse a branch behind its upstream"; fail=1; }
steps_body "$root/skills/release/SKILL.md" | grep -qiF 'gh release view' ||
  { echo "FAIL release: never verifies the release exists"; fail=1; }

# --- a dead skill name is a routing bug -------------------------------------
for f in "$root"/skills/*/SKILL.md; do
  grep -q 'write-spec' "$f" &&
    { echo "FAIL $(basename "$(dirname "$f")"): names a skill that no longer exists"; fail=1; }
done

# --- behavior evals: the grader must tell a right answer from a wrong one -----
for c in "$root"/evals/behavior/cases/*/; do
  n=$(basename "$c")
  out=$(bash "$root/evals/behavior/run.sh" "$n" --self-test 2>&1) ||
    { echo "FAIL behavior eval $n: $out"; fail=1; }
done

# --- routing eval: does a model pick the skill a human would? ----------------
out=$(bash "$root/evals/routing/run.sh" --self-test 2>&1) ||
  { echo "FAIL routing eval: $out"; fail=1; }

[ "$fail" -eq 0 ] && echo "evals passed"
exit "$fail"
