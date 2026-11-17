#!/usr/bin/env bash
# Pass only if a spec landed in docs/specs/ with all six parts, a checkable
# acceptance line, and no code was written before it.
set -u
here=$(cd "$(dirname "$0")" && pwd)
. "$here/../../lib.sh" 2>/dev/null ||
  { echo "FAIL the grader helper lib.sh is missing"; exit 1; }
root=$(cd "$here/../../../.." && pwd)
sandbox=$1
bad=0
fail() { echo "FAIL $*"; bad=1; }

f=$(ls "$sandbox"/docs/specs/*.md 2>/dev/null | head -1)
if [ -z "$f" ]; then
  fail "no docs/specs/<slug>.md was written"
else
  for h in 'Problem' 'Use cases' 'Structure' 'Code style' 'Test plan' \
           'Acceptance criteria' 'Out of scope'; do
    grep -qxF "## $h" "$f" || fail "the spec has no '## $h'"
  done
  grep -q 'It works' "$f" &&
    fail "an acceptance line says 'It works', which no command can check"
  bash "$root/scripts/check-docs.sh" "$f" >/dev/null 2>&1 ||
    fail "the spec fails the project checker"
fi

out=$(only_docs_changed "$here/fixture" "$sandbox")
[ -z "$out" ] || { printf '%s\n' "$out"; bad=1; }

[ "$bad" -eq 0 ] && echo "case passed"
exit "$bad"
