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

# The Define ladder: unclear request, then hunch, then chosen direction, then bar.
route 'ambiguous request|two readings'                interview-me
route 'one question per turn|you know what I mean'    interview-me
route 'vague idea'                                    idea-refine
route 'hunch|no shape yet'                            idea-refine
route 'spec before the code|code style'               spec-driven-development
route 'direction is chosen'                           spec-driven-development
route 'lint rule|quality bar'                         constraint-driven-development
route 'no bar written down|weakened'                  constraint-driven-development

# Neighbours that must not be swallowed by the new four.
route 'ordered tasks|spec is accepted'                plan-work
route 'failing test first'                            test-driven-development
route 'too big|too risky'                             incremental-implementation
route 'no command can check|re-derive'                doubt-driven-development
route 'missing context|too much to read|rules file'   context-engineering
route 'which library|cannot be proved from'           source-driven-development
route 'in parallel|independent tasks'                 subagent-driven-development
route 'responsive|a11y|component'                     frontend-ui-engineering
route 'response shape|error format'                   api-and-interface-design
route '[Cc]ut a version'                              release
route 'verdict passed'                                ship

# Two pairs that name nearly the same moment, and must stay apart.
route 'claim a pass'                                  verify
route 'bound to one commit'                           review

[ "$fail" -eq 0 ] && echo "routing passed"
exit "$fail"
