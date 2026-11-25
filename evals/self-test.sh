#!/usr/bin/env bash
# Prove evals/run.sh can fail. Each case copies the repository, breaks one rule,
# and expects the contract suite to go red. A suite that stays green when a rule
# is negated or a path is removed is the bug this file exists to catch.
# evals/run.sh calls this, and sets LIBRA_EVAL_SELF_TEST so the copy does not
# call it again.
set -u
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
bad=0

copy_repo() { # <dir>; the parts evals/run.sh reads, without the 758M docs/
  cp -R "$root/skills" "$root/evals" "$root/scripts" "$1/"
  cp "$root/AGENTS.md" "$1/"
}

# An unmutated copy must be green first: a copy that is already red proves
# nothing about the mutation.
t=$(mktemp -d)
copy_repo "$t"
if ! LIBRA_EVAL_SELF_TEST=1 bash "$t/evals/run.sh" >/dev/null 2>&1; then
  echo "FAIL self-test: the unmutated copy is already red"
  exit 1
fi
rm -rf "$t"

breaks() { # <label> <shell run inside the copy>
  label=$1
  t=$(mktemp -d)
  copy_repo "$t"
  ( cd "$t" && eval "$2" ) >/dev/null 2>&1
  if LIBRA_EVAL_SELF_TEST=1 bash "$t/evals/run.sh" >/dev/null 2>&1; then
    echo "FAIL self-test/$label: the suite stayed green after the rule broke"
    bad=1
  fi
  rm -rf "$t"
}

breaks "negated rule" \
  "sed 's/^One question per turn/Never ask one question per turn/' skills/libra-interview-me/SKILL.md > x && mv x skills/libra-interview-me/SKILL.md"

breaks "Write names no docs path" \
  "sed 's|docs/specs/|docs/notes/|g' skills/libra-spec-driven-development/SKILL.md > x && mv x skills/libra-spec-driven-development/SKILL.md"

breaks "template missing" \
  "rm -f skills/libra-idea-refine/templates/*.md"

breaks "second owner" \
  "awk '/^## Write\$/{print; print \"docs/specs/\"; next} {print}' skills/libra-interview-me/SKILL.md > x && mv x skills/libra-interview-me/SKILL.md"

breaks "eval file missing" \
  "rm -f evals/skills/libra-decide/evals.json"

[ "$bad" -eq 0 ] && echo "self-test passed"
exit "$bad"
