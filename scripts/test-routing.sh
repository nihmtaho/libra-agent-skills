#!/usr/bin/env bash
# Routing fixtures: the words a human types must match exactly one skill
# description. An agent picks a skill by its description, so two descriptions
# that answer the same words are a bug, not a style choice.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0

desc_of() {
  awk '/^description:[ ]*/{sub(/^description:[ ]*/,""); print; exit}' "$root/skills/$1/SKILL.md"
}

route() { # <regex of a request a human would type> <the one skill that answers it>
  req=$1 want=$2
  hits=""
  for d in "$root"/skills/*/; do
    name=$(basename "$d")
    if desc_of "$name" | grep -qE "$req"; then hits="$hits $name"; fi
  done
  [ "$hits" = " $want" ] && return 0
  echo "FAIL routing '$req': expected $want, matched:${hits:- nothing}"
  fail=1
}

# A new idea enters through the classifier, not straight into an editor.
route 'new idea|behavior change'                      using-libra
# The Define ladder: unclear request, then hunch, then chosen direction, then bar.
route 'request is ambiguous'                          interview-me
route 'one question per turn|you know what I mean'    interview-me
route 'vague idea'                                    idea-refine
route 'hunch|no shape yet'                            idea-refine
route 'spec before the code|code style'               spec-driven-development
route 'direction is chosen'                           spec-driven-development
route 'lint rule|quality bar'                         constraint-driven-development
route 'no bar written down|weakened'                  constraint-driven-development

# Neighbours that must not be swallowed by the new four.
route 'ordered tasks|spec is accepted'                plan-work
route 'no failing test'                               test-driven-development
route 'failing test first'                            test-driven-development
route 'too big'                                       incremental-implementation
route 'too risky'                                     incremental-implementation
route 'rollback'                                      incremental-implementation
route 'no command can check'                          doubt-driven-development
route 'missing context'                               context-engineering
route 'has too much to read'                          context-engineering
route 'rules file'                                    context-engineering
route 'which library'                                 source-driven-development
route 'cite the docs'                                 source-driven-development
route 'in parallel'                                   subagent-driven-development
route 'independent tasks'                             subagent-driven-development
route 'a11y'                                          frontend-ui-engineering
route 'component'                                     frontend-ui-engineering
route 'adding an endpoint'                            api-and-interface-design
route 'response shape'                                api-and-interface-design
route 'error format'                                  api-and-interface-design
route 'ready to implement'                            build
route 'squash or keep the commits'                    git-workflow-and-versioning
route 'branching model'                               git-workflow-and-versioning
route '[Cc]ut a version'                              release
route 'verdict passed'                                libra-ship

# Two pairs that name nearly the same moment, and must stay apart.
route 'claim a pass'                                  verify-work
route 'bound to one commit'                           change-review

# An OR-ed case hides a dead branch: one live alternative makes the whole line
# green while the other matches no description at all. Every alternative must
# match something. Matching is case-sensitive, so a phrase that only appears at
# the start of a description sentence will never match: pick mid-sentence words.
dead=$(sed -n "s/^[[:space:]]*route '\([^']*\)'[[:space:]].*/\1/p" "$0" | tr '|' '\n')
[ -n "$dead" ] || { echo "FAIL routing: the guard extracted no route lines"; fail=1; }
while IFS= read -r alt; do
  [ -z "$alt" ] && continue
  live=0
  for d in "$root"/skills/*/; do
    desc_of "$(basename "$d")" | grep -qE "$alt" && live=1
  done
  [ "$live" -eq 1 ] || { echo "FAIL routing: dead alternative '$alt'"; fail=1; }
done <<EOF
$dead
EOF

[ "$fail" -eq 0 ] && echo "routing passed"
exit "$fail"
