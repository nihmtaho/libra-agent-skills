#!/usr/bin/env bash
# Behavior evals. This script never calls a model: it prepares a sandbox, prints
# the prompt, and grades the artifacts afterwards. A human or an agent session
# does the run.
#   run.sh                     list the cases
#   run.sh <case>              prepare a sandbox and print the prompt
#   run.sh <case> --verify <dir>
#   run.sh <case> --self-test  fixture must fail, fix must pass, wrong must fail
set -u
here=$(cd "$(dirname "$0")" && pwd)
cases="$here/cases"
bad=0

if [ $# -eq 0 ]; then
  for d in "$cases"/*/; do basename "$d"; done
  exit 0
fi

name=$1
shift
dir="$cases/$name"
[ -d "$dir" ] || { echo "no such case: $name" >&2; exit 2; }

case "${1:-}" in
  --verify)
    [ $# -eq 2 ] || { echo "--verify needs a sandbox directory" >&2; exit 2; }
    [ -d "$2" ] || { echo "no such sandbox: $2" >&2; exit 2; }
    bash "$dir/expect.sh" "$2"
    ;;
  --self-test)
    # An eval that cannot fail is a test of nothing, so every case proves all
    # three states: no answer, the known fix, and the plausible wrong answer.
    t=$(mktemp -d)
    trap 'rm -rf "$t"' EXIT
    run_case() { # <overlay dir or ""> <expected exit> <label>
      s="$t/$3"
      mkdir -p "$s"
      cp -R "$dir/fixture/." "$s/"
      if [ -n "$1" ]; then cp -R "$dir/$1/." "$s/"; fi
      got=0
      bash "$dir/expect.sh" "$s" >/dev/null 2>&1 || got=1
      [ "$got" = "$2" ] ||
        { echo "FAIL self-test $name/$3: expected exit $2, got $got"; bad=1; }
    }
    run_case "" 1 fixture
    run_case fix 0 fix
    [ -d "$dir/wrong" ] && run_case wrong 1 wrong
    [ -d "$dir/cheat" ] && run_case cheat 1 cheat
    [ "$bad" -eq 0 ] && echo "self-test passed"
    exit "$bad"
    ;;
  "")
    sandbox="${TMPDIR:-/tmp}/libra-eval-$name"
    [ -e "$sandbox" ] &&
      { echo "refusing: $sandbox exists; move it aside first" >&2; exit 1; }
    mkdir -p "$sandbox"
    cp -R "$dir/fixture/." "$sandbox/"
    echo "sandbox: $sandbox"
    echo "Work only in this directory; a run that edits the repo is a failed run."
    echo "--- prompt ---"
    cat "$dir/prompt.md"
    echo "--- after the run ---"
    echo "bash evals/behavior/run.sh $name --verify $sandbox"
    ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2
    ;;
esac
