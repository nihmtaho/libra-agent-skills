#!/usr/bin/env bash
# Three install properties: it links, it is idempotent, it refuses to overwrite.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT
fail=0

"$root/install.sh" --to agents,claude --dest "$d" >/dev/null || {
  echo "FAIL install first run"; exit 1; }

[ -r "$d/.agents/skills/using-libra/SKILL.md" ] || { echo "FAIL no skill readable via agents"; fail=1; }
[ -L "$d/.claude/skills/using-libra" ] || { echo "FAIL no claude symlink"; fail=1; }

count=$(ls "$d/.agents/skills" | wc -l | tr -d ' ')
expected=$(ls -d "$root"/skills/*/ | wc -l | tr -d ' ')
[ "$count" = "$expected" ] || { echo "FAIL linked $count of $expected"; fail=1; }

before=$(readlink "$d/.agents/skills/using-libra")
"$root/install.sh" --to agents,claude --dest "$d" >/dev/null || {
  echo "FAIL second run failed"; fail=1; }
[ "$before" = "$(readlink "$d/.agents/skills/using-libra")" ] || {
  echo "FAIL symlink changed on second run"; fail=1; }

mkdir -p "$d/x/.agents/skills/using-libra"
out=$("$root/install.sh" --to agents --dest "$d/x" 2>&1)
rc=$?
[ "$rc" -eq 1 ] || { echo "FAIL collision not refused (exit $rc)"; fail=1; }
case "$out" in
  *"refusing:"*) ;;
  *) echo "FAIL no refusing message"; fail=1 ;;
esac

[ "$fail" -eq 0 ] && echo "install tests passed"
exit "$fail"
