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
    if desc_of "$name" | grep -qiE "$req"; then hits="$hits $name"; fi
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
route 'failing test first'                            build
route 'cut a version'                                 release
route 'verdict passed'                                ship

[ "$fail" -eq 0 ] && echo "routing passed"
exit "$fail"
