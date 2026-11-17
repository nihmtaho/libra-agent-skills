#!/usr/bin/env bash
# Routing eval: does a model pick the skill a human would, from the descriptions
# alone? The script builds the list from the skills that exist, so it cannot
# drift, and grades the exact skill name.
#   run.sh                 prepare a sandbox and print the prompt
#   run.sh --verify <dir>  grade answers.tsv
#   run.sh --self-test     no answer fails, the known answer passes, one wrong fails
set -u
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
bad=0
fail() { echo "FAIL $*"; bad=1; }

descriptions() {
  for d in "$root"/skills/*/; do
    n=$(basename "$d")
    desc=$(awk '/^description:[ ]*/{sub(/^description:[ ]*/,""); print; exit}' "$d/SKILL.md")
    printf '%s: %s\n' "$n" "$desc"
  done
}

grade() { # <sandbox>; returns 1 when any line is wrong
  s=$1
  gbad=0
  if [ ! -f "$s/answers.tsv" ]; then
    echo "FAIL no answers.tsv was written"
    return 1
  fi
  while IFS=$'\t' read -r id want; do
    [ -n "$id" ] || continue
    g=$(awk -F'\t' -v i="$id" '$1==i {print $2; exit}' "$s/answers.tsv")
    [ "$g" = "$want" ] ||
      { echo "FAIL $id: expected $want, got ${g:-nothing}"; gbad=1; }
  done < "$here/expected.tsv"
  return "$gbad"
}

case "${1:-}" in
  --verify)
    [ $# -eq 2 ] || { echo "--verify needs a sandbox directory" >&2; exit 2; }
    [ -d "$2" ] || { echo "no such sandbox: $2" >&2; exit 2; }
    grade "$2" || bad=1
    [ "$bad" -eq 0 ] && echo "case passed"
    exit "$bad"
    ;;
  --self-test)
    t=$(mktemp -d)
    trap 'rm -rf "$t"' EXIT
    try() { # <answers file or ""> <expected exit> <label>
      s="$t/$3"
      mkdir -p "$s"
      if [ -n "$1" ]; then cp "$here/$1" "$s/answers.tsv"; fi
      rc=0
      grade "$s" >/dev/null 2>&1 || rc=1
      [ "$rc" = "$2" ] ||
        { echo "FAIL self-test routing/$3: expected exit $2, got $rc"; bad=1; }
    }
    try "" 1 fixture
    try fix/answers.tsv 0 fix
    try wrong/answers.tsv 1 wrong
    [ "$bad" -eq 0 ] && echo "self-test passed"
    exit "$bad"
    ;;
  "")
    sandbox="${TMPDIR:-/tmp}/libra-eval-routing"
    [ -e "$sandbox" ] &&
      { echo "refusing: $sandbox exists; move it aside first" >&2; exit 1; }
    mkdir -p "$sandbox"
    cp "$here/requests.tsv" "$sandbox/requests.tsv"
    descriptions > "$sandbox/descriptions.txt"
    echo "sandbox: $sandbox"
    echo "Work only in this directory; a run that edits the repo is a failed run."
    echo "--- prompt ---"
    cat "$here/prompt.md"
    echo "--- after the run ---"
    echo "bash evals/routing/run.sh --verify $sandbox"
    ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2
    ;;
esac
