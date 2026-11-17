#!/usr/bin/env bash
# Pass only if a proposal landed in docs/ideas/ with the options it beat, the
# riskiest assumption, a cheap test, and nothing outside docs/ was touched.
set -u
here=$(cd "$(dirname "$0")" && pwd)
. "$here/../../lib.sh" 2>/dev/null ||
  { echo "FAIL the grader helper lib.sh is missing"; exit 1; }
root=$(cd "$here/../../../.." && pwd)
sandbox=$1
bad=0
fail() { echo "FAIL $*"; bad=1; }

f=$(ls "$sandbox"/docs/ideas/*.md 2>/dev/null | head -1)
if [ -z "$f" ]; then
  fail "no docs/ideas/<slug>.md was written"
else
  n=$(awk '/^## Options considered/{f=1;next} /^## /{f=0} f && /^[0-9]+\./{c++} END{print c+0}' "$f")
  [ "$n" -ge 5 ] || fail "only $n options considered; the skill forces 5 to 7"
  bash "$root/scripts/check-docs.sh" "$f" >/dev/null 2>&1 ||
    fail "the idea document fails the project checker"
fi

out=$(only_docs_changed "$here/fixture" "$sandbox")
[ -z "$out" ] || { printf '%s\n' "$out"; bad=1; }

[ "$bad" -eq 0 ] && echo "case passed"
exit "$bad"
