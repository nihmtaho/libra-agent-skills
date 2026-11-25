#!/usr/bin/env bash
# Grade one per-skill eval run, or print the grader prompt when no grade exists.
# usage: verify.sh <skill> <eval-id> <sandbox>
set -u
here=$(cd "$(dirname "$0")" && pwd)
skill=${1:-}
id=${2:-}
sandbox=${3:-}
[ -n "$skill" ] && [ -n "$id" ] && [ -d "$sandbox" ] || {
  echo "usage: verify.sh <skill> <eval-id> <sandbox>" >&2; exit 2; }
json="$here/$skill/evals.json"
[ -f "$json" ] || { echo "no such eval file: $json" >&2; exit 2; }

if [ -f "$sandbox/grading.json" ]; then
  python3 - "$json" "$id" "$sandbox/grading.json" <<'PY'
import json, sys
from pathlib import Path
eval_file, eid, grade_file = sys.argv[1], int(sys.argv[2]), Path(sys.argv[3])
data = json.loads(Path(eval_file).read_text())
e = next((x for x in data['evals'] if x['id'] == eid), None)
grade = json.loads(grade_file.read_text())
if e is None:
    print(f"FAIL no eval {eid}")
    raise SystemExit(1)
want = e.get('expectations', [])
if not want:
    print("FAIL no expectations")
    raise SystemExit(1)
got = grade.get('expectations', [])
bad = 0
# The grader reflows a sentence; comparing exact text turned that into
# "missing grade". Whitespace is not part of an expectation.
norm = lambda s: ' '.join(str(s).split())
for item in want:
    row = next((r for r in got if norm(r.get('text')) == norm(item)), None)
    if row is None:
        print(f"FAIL missing grade: {item}")
        bad = 1
    elif row.get('passed') is not True:
        print(f"FAIL {item}")
        print(f"     evidence: {row.get('evidence', '')}")
        bad = 1
if bad:
    print("grading failed")
    raise SystemExit(1)
print(f"grading passed ({len(want)} of {len(want)})")
PY
  exit $?
fi

echo "No grading.json yet in $sandbox."
echo "--- prompt ---"
python3 - "$json" "$id" <<'PY'
import json, sys
data = json.loads(open(sys.argv[1]).read())
e = next(x for x in data['evals'] if x['id'] == int(sys.argv[2]))
print(e['prompt'])
print("\n--- expectations ---")
for x in e.get('expectations', []):
    print(f"- {x}")
PY
echo
echo "--- files ---"
find "$sandbox" -path '*/.git' -prune -o -type f -print | sed "s|$sandbox/||" | sort
echo
cat <<EOF
--- grader task ---
Read the prompt and expectations above, then inspect the files in:
  $sandbox
Grade every expectation PASS or FAIL with the exact evidence you found. The
burden of proof is on the expectation. Write $sandbox/grading.json with:
  {"expectations":[{"text":"<exact expectation>","passed":true,"evidence":"<quote>"}],
   "summary":{"passed":N,"failed":N,"total":N,"pass_rate":0.0}}
Then run: bash evals/skills/verify.sh $skill $id $sandbox
EOF
