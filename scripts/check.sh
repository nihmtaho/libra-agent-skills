#!/usr/bin/env bash
# Check every skill against the repo contract.
# Prints one FAIL line per problem and exits 1 if any.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0
shopt -s nullglob

skill_count=0

for dir in "$root"/skills/*/; do
  name=$(basename "$dir")
  f="$dir/SKILL.md"
  skill_count=$((skill_count+1))
  if [ ! -f "$f" ]; then
    echo "FAIL $name: missing SKILL.md"
    fail=1
    continue
  fi
  [ "$(head -1 "$f")" = "---" ] || { echo "FAIL $name: no frontmatter"; fail=1; }
  if ! sed -n '2,10p' "$f" | grep -qxF -- '---'; then
    echo "FAIL $name: frontmatter not closed by '---' on its own line"
    fail=1
  fi
  fmname=$(awk '/^name:[ ]*/{sub(/^name:[ ]*/,""); print; exit}' "$f")
  desc=$(awk '/^description:[ ]*/{sub(/^description:[ ]*/,""); print; exit}' "$f")
  [ "$fmname" = "$name" ] || { echo "FAIL $name: name field is '$fmname'"; fail=1; }
  [[ "$name" =~ ^[a-z0-9-]+$ ]] || { echo "FAIL $name: directory name not [a-z0-9-]"; fail=1; }
  case "$desc" in
    *"Use when"*) ;;
    *) echo "FAIL $name: description lacks 'Use when'"; fail=1 ;;
  esac
  case "$desc" in
    *": "*)
      echo "FAIL $name: description contains ': ', which breaks YAML unless quoted"
      fail=1
      ;;
  esac
  lines=$(wc -l < "$f" | tr -d ' ')
  [ "$lines" -le 80 ] || { echo "FAIL $name: $lines lines (max 80)"; fail=1; }
  for h in "## When to use" "## Read first" "## Steps" "## Write" "## Stop"; do
    grep -qxF "$h" "$f" || { echo "FAIL $name: missing heading '$h'"; fail=1; }
  done
  for t in 'Bash(' 'Read(' 'Edit(' 'Write(' 'Grep(' 'Glob(' 'Task(' '.claude/' '.agents/' 'opencode' 'skills/'; do
    if grep -qF -- "$t" "$f"; then
      echo "FAIL $name: forbidden token '$t'"
      fail=1
    fi
  done
  write_body=$(awk '/^## Write$/{f=1;next} /^## /{f=0} f' "$f")
  case "$write_body" in
    *docs/*|*none*) ;;
    *) echo "FAIL $name: '## Write' names no docs/ path and no 'none'"; fail=1 ;;
  esac
  case "$write_body" in
    *docs/*)
      case "$write_body" in
        *check-docs.sh*) ;;
        *) echo "FAIL $name: '## Write' names docs/ but never runs check-docs.sh"; fail=1 ;;
      esac
      ;;
  esac
  # A skill that reads pull request text takes orders from a stranger unless its
  # own rules say that text is data.
  if grep -qE '\bPR\b|pull request' "$f"; then
    grep -q 'untrusted' "$f" ||
      { echo "FAIL $name: PR text is read but never called untrusted"; fail=1; }
  fi
done

if [ "$skill_count" -eq 0 ]; then
  echo "FAIL skills/: no skill directories found"
  fail=1
fi

# The checker ships inside bootstrap-project and is copied into each project, so
# the repo copy and the bundled copy must stay byte-identical.
for f in scripts/check-docs.sh skills/bootstrap-project/scripts/check-docs.sh; do
  [ -f "$root/$f" ] || { echo "FAIL $f: missing"; fail=1; }
done
if [ -f "$root/scripts/check-docs.sh" ] && [ -f "$root/skills/bootstrap-project/scripts/check-docs.sh" ]; then
  cmp -s "$root/scripts/check-docs.sh" "$root/skills/bootstrap-project/scripts/check-docs.sh" ||
    { echo "FAIL the two copies of check-docs.sh differ"; fail=1; }
fi

p="$root/docs/PROJECT.md"
if [ -f "$p" ]; then
  if ! awk '
    /^## / && last ~ /^## / { print "FAIL docs/PROJECT.md: empty section: " last; bad=1 }
    $0 ~ /[^ ]/ { last=$0 }
    END {
      if (last ~ /^## /) { print "FAIL docs/PROJECT.md: empty section at end: " last; bad=1 }
      exit bad?1:0
    }
  ' "$p"; then
    fail=1
  fi
fi

[ "$fail" -eq 0 ] && echo "all checks passed"
exit "$fail"
