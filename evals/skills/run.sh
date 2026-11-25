#!/usr/bin/env bash
# Prepare one per-skill eval sandbox, or inventory every case.
# usage:
#   run.sh <skill> <eval-id> [with|without]
#   run.sh --inventory
# The script never calls a model. An agent session reads the prompt and works in
# the printed sandbox; the expectations are printed for the grader.
set -u
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
fail=0

list_cases() {
  python3 - "$here" <<'PY'
import json, sys
from pathlib import Path
base = Path(sys.argv[1])
for f in sorted(base.glob('*/evals.json')):
    data = json.loads(f.read_text())
    for e in data.get('evals', []):
        print(data['skill_name'], e['id'])
PY
}

case "${1:-}" in
  --inventory)
    cases=$(list_cases) || { echo "FAIL list_cases"; exit 1; }
    [ -n "$cases" ] || { echo "FAIL no cases"; exit 1; }
    seen=0
    while read -r skill id; do
      [ -n "$skill" ] || continue
      seen=$((seen + 1))
      sandbox="${TMPDIR:-/tmp}/libra-inventory-$skill-$id"
      rm -rf "$sandbox"
      mkdir -p "$sandbox"
      if bash "$here/fixtures.sh" "$sandbox" "$skill" "$id" >/dev/null 2>&1; then
        printf 'OK   %s %s\n' "$skill" "$id"
      else
        printf 'FAIL %s %s\n' "$skill" "$id"
        fail=1
      fi
      rm -rf "$sandbox" "${sandbox}-remote.git"
    done <<< "$cases"
    [ "$seen" -ge $(($(ls -1 "$root/skills" | wc -l | tr -d ' ') * 2)) ] ||
      { echo "FAIL expected at least two cases per skill, got $seen"; fail=1; }
    [ "$fail" -eq 0 ] && echo "inventory passed"
    exit "$fail"
    ;;
  "")
    echo "usage: run.sh <skill> <eval-id> [with|without] | run.sh --inventory" >&2
    exit 2
    ;;
esac

skill=$1
id=${2:-}
mode=${3:-with}
json="$here/$skill/evals.json"
[ -f "$json" ] || { echo "no such eval file: $json" >&2; exit 2; }
[ "$mode" = "with" ] || [ "$mode" = "without" ] || { echo "mode must be with or without" >&2; exit 2; }

meta=$(mktemp -d)
trap 'rm -rf "$meta"' EXIT
python3 - "$json" "$id" "$meta" <<'PY'
import json, sys
from pathlib import Path
f, eid, out = sys.argv[1], int(sys.argv[2]), Path(sys.argv[3])
data = json.loads(Path(f).read_text())
e = next((x for x in data['evals'] if x['id'] == eid), None)
if e is None:
    raise SystemExit(f"no eval {eid} in {f}")
(out / 'prompt').write_text(e['prompt'])
(out / 'expected').write_text(e['expected_output'])
(out / 'expectations').write_text('\n'.join(e.get('expectations', [])))
PY
[ $? -eq 0 ] || { echo "eval $id not found in $skill" >&2; exit 2; }

sandbox="${TMPDIR:-/tmp}/libra-skill-$skill-$id-$mode"
[ -e "$sandbox" ] && { echo "refusing: $sandbox exists; move it aside first" >&2; exit 1; }
mkdir -p "$sandbox"
bash "$here/fixtures.sh" "$sandbox" "$skill" "$id"

if [ "$mode" = "with" ]; then
  mkdir -p "$sandbox/.claude/skills"
  cp -R "$root"/skills/. "$sandbox/.claude/skills/"
  [ -d "$sandbox/.git" ] && printf '.claude/\n' >> "$sandbox/.git/info/exclude"
fi

echo "sandbox: $sandbox"
echo "mode: $mode"
if [ "$mode" = "with" ]; then
  echo "skill: $root/skills/$skill/SKILL.md"
else
  echo "skill: none (baseline)"
fi
echo "--- prompt ---"
cat "$meta/prompt"
echo
echo "--- expected ---"
cat "$meta/expected"
echo
echo "--- expectations ---"
cat "$meta/expectations"
echo
echo "--- after the run ---"
echo "bash evals/skills/verify.sh $skill $id $sandbox"
