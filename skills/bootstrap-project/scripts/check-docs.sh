#!/usr/bin/env bash
# Check markdown documents against the rules in docs/specs/markdown-check.md.
# Usage: check-docs.sh <file>...
# Silent and exit 0 when every file is clean; one FAIL line per problem otherwise.
set -u
fail=0
[ $# -gt 0 ] || { echo "usage: check-docs.sh <file>..." >&2; exit 2; }

for f in "$@"; do
  if [ ! -f "$f" ]; then
    echo "FAIL $f:0: not a markdown file (pass file paths, not directories)"
    fail=1
    continue
  fi
  case "$f" in *.md|*.MD) ;; *)
    echo "FAIL $f:0: not a markdown file"
    fail=1
    continue
    ;;
  esac
  fl=$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')
  tpl=0
  case "$fl" in */templates/*.md) tpl=1 ;; esac
  # frontmatter is a docs/ convention; a README at the project root has none.
  # A shipped template keeps one, because it is a document being written.
  indocs=0
  case "$fl" in */docs/*|docs/*) indocs=1 ;; esac
  [ "$tpl" = 1 ] && indocs=1
  # an imported document is machine-extracted: its first line names the source,
  # so the one-H1 rules cannot apply to it
  imp=0
  case "$fl" in */docs/imports/*.md|docs/imports/*.md) imp=1 ;; esac

  # 1. frontmatter opens on line 1 and closes by line 10
  fmend=0
  if [ "$indocs" = 0 ]; then
    :
  elif [ "$(head -1 "$f")" != "---" ]; then
    echo "FAIL $f:1: no frontmatter"
    fail=1
  else
    close=$(sed -n '2,10p' "$f" | grep -nxF -- '---' | head -1 | cut -d: -f1)
    if [ -z "$close" ]; then
      echo "FAIL $f:1: frontmatter not closed by '---'"
      fail=1
    else
      fmend=$((close+1))
    fi
  fi

  # 2. title present; updated is YYYY-MM-DD (a template keeps the literal placeholder)
  if [ "$indocs" = 1 ]; then
    [ -n "$(awk -v e="$fmend" 'NR<=e && /^title:[ ]*[^ ]/{print; exit}' "$f")" ] ||
      { echo "FAIL $f:1: empty or missing title"; fail=1; }
    awk -v e="$fmend" -v tpl="$tpl" '
      NR <= e && (/^updated: [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ ||
                  (tpl && /^updated: YYYY-MM-DD$/)) { ok = 1 }
      END { exit !ok }' "$f" ||
      { echo "FAIL $f:1: updated is not YYYY-MM-DD"; fail=1; }
  fi

  # 3-6. one H1 first, no empty heading, no empty section, fences balanced
  body=$(awk -v f="$f" -v fm="$fmend" -v imp="$imp" '
    function bad(n, msg) { printf "FAIL %s:%d: %s\n", f, n, msg }
    NR <= fm { next }
    match($0, /^(`{3,}|~{3,})/) {
                 ch = substr($0, 1, 1); w = RLENGTH; rest = substr($0, RLENGTH + 1)
                 if (fence == "") { pend = ""; fence = ch; fw = w; nfence = 1 }
                 else if (ch == fence && w >= fw && rest ~ /^[ \t]*$/) { fence = ""; nfence = 0 }
                 next }
    fence { next }
    /[^ \t]/ {
      if (!first) { first = NR; firstline = $0 }
      if ($0 ~ /^#+[ \t]*$/) { bad(NR, "heading with no text"); pend = ""; next }
      if ($0 ~ /^# /) { h1 += 1; pend = ""; next }   # the title section is the whole document
      if ($0 ~ /^#/) {
        if (pend != "") bad(NR, "empty section under " pend " (line " pendline ")")
        pend = $0; pendline = NR
      } else pend = ""
    }
    END {
      if (pend != "") bad(pendline, "empty section under " pend)
      if (nfence) bad(NR, "unclosed code fence")
      if (!imp) {
        if (h1 != 1) bad(first, "expected one H1, found " h1)
        else if (fm > 0 && firstline !~ /^# /) bad(first, "first body line is not the H1")
      }
    }' "$f")
  [ -z "$body" ] || { printf '%s\n' "$body"; fail=1; }

  # 7. internal links resolve, relative to the document
  links=$(awk '
    match($0, /^(`{3,}|~{3,})/) {
      ch = substr($0, 1, 1); w = RLENGTH; rest = substr($0, RLENGTH + 1)
      if (fence == "") { fence = ch; fw = w }
      else if (ch == fence && w >= fw && rest ~ /^[ \t]*$/) fence = ""
      next }
    fence { next }
    { gsub(/`[^`]*`/, "")
      while (match($0, /\]\([^)]*\)/)) {
        print NR "\t" substr($0, RSTART+2, RLENGTH-3)
        $0 = substr($0, RSTART+RLENGTH)
      } }' "$f")
  while IFS=$'\t' read -r line target; do
    [ -n "${target:-}" ] || continue
    target=${target%%\"*}; target=${target%" "}; target=${target%%#*}
    case "$target" in ''|http://*|https://*|mailto:*|\#*) continue ;; esac
    # shortcut: percent-encoded paths are not decoded, upgrade if a link uses %20
    [ -e "$(dirname "$f")/$target" ] ||
      { echo "FAIL $f:$line: link target not found: $target"; fail=1; }
  done <<< "$links"

  # 8. a table row is a table only when the row under it is a valid separator row;
  #    otherwise the pipes render as one paragraph of text. A fence may be indented
  #    up to three spaces and a four-space indent is a code block, so neither is a
  #    table row.
  tables=$(awk -v f="$f" '
    function bad(n, msg) { printf "FAIL %s:%d: %s\n", f, n, msg }
    function sep(line,   n, i, cells, c) {
      sub(/^\|/, "", line); sub(/\|[ \t]*$/, "", line)
      n = split(line, cells, "|")
      for (i = 1; i <= n; i++) {
        c = cells[i]; gsub(/^[ \t]+|[ \t]+$/, "", c)
        if (c !~ /^:?-+:?$/) return 0
      }
      return 1 }
    NR <= fm { next }
    {
      if ($0 ~ /^ {4,}/) { head = 0; next }
      line = $0; sub(/^ {0,3}/, "", line)
      if (match(line, /^(`{3,}|~{3,})/)) {
        ch = substr(line, 1, 1); w = RLENGTH; rest = substr(line, RLENGTH + 1)
        if (fence == "") { fence = ch; fw = w }
        else if (ch == fence && w >= fw && rest ~ /^[ \t]*$/) fence = ""
        head = 0; next
      }
      if (fence != "") next
      if (line ~ /^\|/) {
        if (!head) { head = NR; next }
        if (head > 0) {
          if (!sep(line)) bad(head, "table has no valid separator row, so it renders as text")
          head = -1
        }
        next
      }
      head = 0
    }' "$f")
  [ -z "$tables" ] || { printf '%s\n' "$tables"; fail=1; }

  # 9. headings required by document type
  type=""
  case "$fl" in
    */docs/project.md|docs/project.md) type=project ;;
    */docs/specs/*.md|docs/specs/*.md) type=spec ;;
    */docs/adr/*.md|docs/adr/*.md) type=adr ;;
    */docs/tasks/*.md|docs/tasks/*.md) type=task ;;
    */docs/imports/*.md|docs/imports/*.md) type=import ;;
    */docs/constraints.md|docs/constraints.md) type=constraints ;;
    */docs/ideas/*.md|docs/ideas/*.md) type=idea ;;
    */templates/project.md) type=project ;;
    */templates/spec.md) type=spec ;;
    */templates/adr.md) type=adr ;;
    */templates/task.md) type=task ;;
    */templates/idea.md) type=idea ;;
    */templates/constraints.md) type=constraints ;;
  esac
  case "$type" in
    project) need="Run & verify|Module map|Features|Decisions|Next" ;;
    spec) need="Problem|Use cases|Acceptance criteria|Out of scope" ;;
    adr) need="Context|Decision|Rejected options|Consequences" ;;
    task) need="Checkpoint" ;;
    idea) need="Problem|Options considered|Chosen direction|Riskiest assumption|Cheapest test" ;;
    constraints) need="Quality bar|Never|When a check is red" ;;
    *) need="" ;;
  esac
  # required headings must be real headings: outside frontmatter and outside fences,
  # so a heading quoted in a code block cannot satisfy the rule
  heads=$(awk -v fm="$fmend" '
    NR <= fm { next }
    match($0, /^(`{3,}|~{3,})/) {
      ch = substr($0, 1, 1); w = RLENGTH; rest = substr($0, RLENGTH + 1)
      if (fence == "") { fence = ch; fw = w }
      else if (ch == fence && w >= fw && rest ~ /^[ \t]*$/) fence = ""
      next }
    fence { next }
    /^#/ { print }' "$f")
  while IFS= read -r h; do
    [ -n "$h" ] || continue
    printf '%s\n' "$heads" | awk -v h="## $h" '
      { if ($0 == h || (index($0, h) == 1 && substr($0, length(h) + 1, 1) == " ")) ok = 1 }
      END { exit !ok }' ||
      { echo "FAIL $f:1: missing heading '## $h'"; fail=1; }
  done <<< "$(printf '%s' "$need" | tr '|' '\n')"
  case "$type" in
    task)
      grep -qE '^Stopped at:' "$f" || { echo "FAIL $f:1: missing 'Stopped at:'"; fail=1; }
      grep -qE '^[[:space:]]*- \[[ xX]\]' "$f" || { echo "FAIL $f:1: no task checkbox"; fail=1; }
      awk -v e="$fmend" 'NR<=e && /^spec:/{ok=1} END{exit !ok}' "$f" ||
        { echo "FAIL $f:1: no spec: in frontmatter"; fail=1; }
      ;;
    import)
      awk -v e="$fmend" 'NR<=e && /^trust: external$/{ok=1} END{exit !ok}' "$f" ||
        { echo "FAIL $f:1: no 'trust: external' in frontmatter"; fail=1; }
      ;;
  esac
done

exit "$fail"
