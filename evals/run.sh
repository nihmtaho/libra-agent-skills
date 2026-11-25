#!/usr/bin/env bash
# Contract evals for the Define skills: the rules that make each skill do its
# job, the one-owner-per-artifact rule, and the wiring between them.
# These prove the rules are written down and unambiguous. They cannot prove an
# agent follows them; evals/README.md holds the live rubric for that.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0

write_body() { awk '/^## Write$/{f=1;next} /^## /{f=0} f' "$1"; }
steps_body() { awk '/^## Steps$/{f=1;next} /^## /{f=0} f' "$1" | tr '\n' ' ' | tr -s ' '; }

# Prose reflows, so match against a flattened copy: a rule split across two
# lines is still the rule.
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }

has() { # <skill> <fixed string> <rule label>; case-sensitive on purpose
  text=$(flat "$root/skills/$1/SKILL.md")
  printf '%s' "$text" | grep -qF -- "$2" ||
    { echo "FAIL $1: $3"; fail=1; return; }
  # A substring match survives a policy flip: "Never ask one question per turn"
  # still contains "One question per turn". A pinned rule that carries no
  # negation of its own must not appear only inside negated sentences.
  case "$2" in *' '*) ;; *) return ;; esac
  case "$2" in *[Nn]ever*|*'not '*|*'no '*|*cannot*|*"can't"*) return ;; esac
  printf '%s' "$text" | awk -v p="$2" '
    { n = split($0, s, /[.!?][")]* /)
      for (i = 1; i <= n; i++) if (index(s[i], p)) {
        seen++
        if (index(s[i], p) > 1 && tolower(s[i]) ~ /^[ \t>*_`]*(do not|don.t|never|no longer|no |not |stop|skip|drop|remove|ignore|cannot|can.t)[ \t]/) neg++
      } }
    END { exit (seen > 0 && neg == seen) }' ||
    { echo "FAIL $1: $3 (stated, then negated)"; fail=1; }
}

# --- libra-start: classify before editing, branch before editing ----------
has libra-start 'Classify the request in one line before touching a file' 'does not classify before an edit'
has libra-start 'No task file, no edit' 'may edit a feature without a task'
has libra-start 'create the branch before the first edit' 'may edit before creating a branch'
grep -qF 'libra-start' "$root/AGENTS.md" ||
  { echo "FAIL AGENTS.md: a new session is never sent to the classifier"; fail=1; }
# --- libra-interview-me: asks, never writes, never guesses -------------------------
write_body "$root/skills/libra-interview-me/SKILL.md" | grep -q 'none' ||
  { echo "FAIL libra-interview-me: Write must be none, it is a conversation"; fail=1; }
has libra-interview-me 'One question per turn'        'does not state one question per turn'
has libra-interview-me 'Stop at 95%'                  'has no stopping rule, so the interview never ends'
has libra-interview-me 'Cap it at eight questions'    'has no cap, so a decision becomes ten questions'
has libra-interview-me 'Never fill a missing answer'  'may invent an answer instead of reporting a gap'
has libra-interview-me 'libra-idea-refine'                  'does not hand off to libra-idea-refine'

# --- libra-idea-refine: widens before it narrows ----------------------------------
has libra-idea-refine 'Write 5 to 7 different answers'      'does not force more than one option'
has libra-idea-refine 'One line per death, so the next reader'            'does not record why an option died'
has libra-idea-refine 'Name the riskiest assumption'   'names no assumption that could kill the direction'
has libra-idea-refine 'and the cheapest test that would show it false' 'has no cheap test before code'
write_body "$root/skills/libra-idea-refine/SKILL.md" | grep -qF 'docs/ideas/' ||
  { echo "FAIL libra-idea-refine: Write does not name docs/ideas/"; fail=1; }

# --- libra-spec-driven-development: the six parts, before code --------------------
for part in 'Goal:' 'Structure:' 'Code style:' 'Test plan:' 'Limits:'; do
  has libra-spec-driven-development "$part" "does not require the $part part"
done
has libra-spec-driven-development 'one line per use case, checkable by a command' \
  'acceptance criteria may be unverifiable'
has libra-spec-driven-development '## Open questions'  'has nowhere to park an unanswered question'
has libra-spec-driven-development 'Never guess one'    'may guess an answer into the spec'
has libra-spec-driven-development 'libra-plan-work'          'does not hand off to libra-plan-work'
steps_body "$root/skills/libra-spec-driven-development/SKILL.md" | grep -qF 'with a rejected alternative, gets its ADR before the spec is called done' ||
  { echo "FAIL libra-spec-driven-development: a decided choice may leave no ADR behind"; fail=1; }
write_body "$root/skills/libra-spec-driven-development/SKILL.md" | grep -qF 'docs/specs/' ||
  { echo "FAIL libra-spec-driven-development: Write does not name docs/specs/"; fail=1; }

# --- libra-constraint-driven-development: the bar, and the ways it is lowered -----
for way in 'These are not fixes: deleting or commenting a test' 'a looser threshold' \
           'a new ignore comment'; do
  has libra-constraint-driven-development "$way" "does not name '$way' as a non-fix"
done
has libra-constraint-driven-development 'a new skip, a looser threshold, a new ignore comment' \
  'a new skip is not named as a non-fix, so a flaky test may be skipped'
has libra-constraint-driven-development "with the human's name and today's" 'a lowered bar needs no name'
has libra-constraint-driven-development 'threshold, count of tests, count of skipped tests' 'does not compare numbers to the file'
write_body "$root/skills/libra-constraint-driven-development/SKILL.md" | grep -qF 'docs/CONSTRAINTS.md' ||
  { echo "FAIL libra-constraint-driven-development: Write does not name docs/CONSTRAINTS.md"; fail=1; }

# --- decide: a decision is recorded when it is made, not when work lands ----
grep -qF 'Write it when the decision is made, not when the code lands' "$root/skills/libra-decide/SKILL.md" ||
  { echo "FAIL libra-decide: the ADR may wait until the code lands"; fail=1; }
write_body "$root/skills/libra-decide/SKILL.md" | grep -qF 'docs/adr/' ||
  { echo "FAIL libra-decide: Write does not name docs/adr/"; fail=1; }

# --- one owner per artifact --------------------------------------------------
owners() {
  for d in "$root"/skills/*/; do
    n=$(basename "$d")
    write_body "$d/SKILL.md" | grep -qF -- "$1" && printf '%s\n' "$n"
  done
}
for artifact in 'docs/specs/' 'docs/ideas/' 'docs/CONSTRAINTS.md' 'docs/GIT.md'; do
  names=$(owners "$artifact")
  count=$(printf '%s' "$names" | grep -c .)
  [ "$count" -eq 1 ] ||
    { echo "FAIL ownership: $artifact has $count owners: $(printf '%s' "$names" | tr '\n' ' ')"; fail=1; }
done

# --- the bar is read where it is enforced -----------------------------------
has libra-verify-work 'docs/CONSTRAINTS.md' 'the floor is checked without the project bar'
has libra-change-review 'docs/CONSTRAINTS.md' 'the downgrade check ignores the project bar'

# --- templates ship with the skills that write them -------------------------
for s in libra-idea-refine libra-spec-driven-development libra-constraint-driven-development libra-release; do
  ls "$root/skills/$s/templates/"*.md >/dev/null 2>&1 ||
    { echo "FAIL $s: writes a document but ships no template"; fail=1; }
done

# --- libra-build: the dispatcher orders the two discipline skills ------------------
for step in 'libra-test-driven-development' 'libra-incremental-implementation'; do
  steps_body "$root/skills/libra-build/SKILL.md" | grep -qiF -- "$step" ||
    { echo "FAIL libra-build: the dispatcher does not route to $step"; fail=1; }
done
steps_body "$root/skills/libra-build/SKILL.md" | grep -qF 'not done, whatever the suite says' ||
  { echo "FAIL libra-build: TDD and incremental are a menu, not a rule"; fail=1; }
has libra-build 'Spike mode**, when the human wants to learn' 'a throwaway would have to pass the tests'
steps_body "$root/skills/libra-build/SKILL.md" | grep -qF 'skip the tests' ||
  { echo "FAIL libra-build: the spike exception does not say the tests are skipped"; fail=1; }
write_body "$root/skills/libra-build/SKILL.md" | grep -q 'none' ||
  { echo "FAIL libra-build: Write must be none, it dispatches"; fail=1; }
steps_body "$root/skills/libra-build/SKILL.md" | grep -qF 'No branch: create it' ||
  { echo "FAIL libra-build: may start a task without a branch"; fail=1; }

# --- libra-incremental-implementation: a commit knows its branch ------------------
steps_body "$root/skills/libra-incremental-implementation/SKILL.md" | grep -qiF 'git rev-parse --abbrev-ref HEAD' ||
  { echo "FAIL libra-incremental-implementation: may commit without knowing the branch"; fail=1; }
has libra-incremental-implementation 'One slice, one commit, in the format' 'a slice is not tied to a commit'
has libra-incremental-implementation 'in the format `docs/GIT.md` names: Conventional Commits' 'the commit convention is gone'
has libra-incremental-implementation 'and never a co-author line or an AI signature'      'an AI signature is allowed'
# The rule reads as concealment unless it says what it is and when it gives way:
# Snyk's build E004 called it hidden authorship. Every skill that states the rule
# carries both halves.
has libra-incremental-implementation 'unless the project or the platform requires one — format, not concealment' 'the no-signature rule reads as hidden authorship'
has libra-git-workflow-and-versioning 'unless the project or the platform requires one — format, not concealment' 'the no-signature rule reads as hidden authorship'
has libra-ship 'unless the project or the platform requires one — format, not concealment' 'the no-signature rule reads as hidden authorship'
has libra-incremental-implementation 'Delete the flag'        'a flag nobody removes'
write_body "$root/skills/libra-incremental-implementation/SKILL.md" | grep -qF 'docs/tasks/' ||
  { echo "FAIL libra-incremental-implementation: Write does not name docs/tasks/"; fail=1; }
steps_body "$root/skills/libra-incremental-implementation/SKILL.md" | grep -qF 'Stopped at:' ||
  { echo "FAIL libra-incremental-implementation: a stop position is a mood, not a line"; fail=1; }
steps_body "$root/skills/libra-incremental-implementation/SKILL.md" | grep -qF 'Tick the box' ||
  { echo "FAIL libra-incremental-implementation: a landed slice is never reported"; fail=1; }

# --- libra-test-driven-development: the order, and the trap ----------------------
has libra-test-driven-development 'A test that passes before any change is a test of nothing' 'a test of nothing is allowed'
has libra-test-driven-development 'Prefer DAMP to DRY in tests'          'tests may hide their data behind a helper'
has libra-test-driven-development 'Keep the pyramid 80/15/5'                               'the test pyramid is gone'
write_body "$root/skills/libra-test-driven-development/SKILL.md" | grep -q 'none' ||
  { echo "FAIL libra-test-driven-development: Write must be none, it writes code"; fail=1; }

# --- libra-doubt-driven-development: the five rungs ------------------------------
for rung in CLAIM EXTRACT DOUBT RECONCILE STOP; do
  steps_body "$root/skills/libra-doubt-driven-development/SKILL.md" | grep -qF -- "**$rung**" ||
    { echo "FAIL libra-doubt-driven-development: missing the $rung rung"; fail=1; }
done
has libra-doubt-driven-development 'Never hand it your conclusion' 'the doubter may be told the answer'

# --- libra-context-engineering: what goes in, and what is data --------------------
write_body "$root/skills/libra-context-engineering/SKILL.md" | grep -qF 'AGENTS.md' ||
  { echo "FAIL libra-context-engineering: a rule cannot outlive the session"; fail=1; }
has libra-context-engineering 'libra-handling-untrusted-content'    'a fetched page may act as an instruction'
has libra-context-engineering 'Write the pack you assembled'  'the next session searches again'
write_body "$root/skills/libra-context-engineering/SKILL.md" | grep -qF 'docs/PROJECT.md' ||
  { echo "FAIL libra-context-engineering: Write does not name docs/PROJECT.md"; fail=1; }

# --- libra-source-driven-development: a claim needs an address ------------------
has libra-source-driven-development 'Pin the version'                'a claim may be for another version'
has libra-source-driven-development 'Go to the primary source'                 'a blog post counts as a source'
has libra-source-driven-development 'libra-handling-untrusted-content'     'a fetched page may act as an instruction'
write_body "$root/skills/libra-source-driven-development/SKILL.md" | grep -q 'none' ||
  { echo "FAIL libra-source-driven-development: Write must be none, decide writes the ADR"; fail=1; }

# --- libra-subagent-driven-development: the parent keeps the commit -------------
has libra-subagent-driven-development 'Build the overlap table: which tasks share a path'      'parallel work is dispatched without checking paths'
has libra-subagent-driven-development 'A subagent never commits, never pushes, and never ticks a box'      'a subagent can commit'
steps_body "$root/skills/libra-subagent-driven-development/SKILL.md" | grep -qF 'Run the suite yourself' ||
  { echo "FAIL libra-subagent-driven-development: the parent may trust a subagent green"; fail=1; }
write_body "$root/skills/libra-subagent-driven-development/SKILL.md" | grep -q 'none' ||
  { echo "FAIL libra-subagent-driven-development: Write must be none, the parent writes"; fail=1; }

# --- libra-frontend-ui-engineering: the system, the widths, the keyboard ---------
has libra-frontend-ui-engineering 'Accessibility, WCAG 2.1 AA: every control' 'accessibility is a preference, not a rule'
has libra-frontend-ui-engineering 'works with the keyboard only and at the narrowest' 'a screen can be done without the keyboard'
has libra-frontend-ui-engineering 'Tokens before literals: colour, spacing' 'a hex value may live in a component'
write_body "$root/skills/libra-frontend-ui-engineering/SKILL.md" | grep -qF 'docs/design-system.md' ||
  { echo "FAIL libra-frontend-ui-engineering: Write does not name docs/design-system.md"; fail=1; }

# --- libra-api-and-interface-design: the contract comes first --------------------
has libra-api-and-interface-design "Hyrum's Law: every observable behaviour is a contract" 'an observable behaviour is not treated as a contract'
has libra-api-and-interface-design 'Validate at the boundary, once'  'validation may be spread through the logic'
has libra-api-and-interface-design 'is idempotent: a key the caller supplies' 'a retryable write may double'
write_body "$root/skills/libra-api-and-interface-design/SKILL.md" | grep -qF 'docs/api/' ||
  { echo "FAIL libra-api-and-interface-design: Write does not name docs/api/"; fail=1; }

# --- libra-git-workflow-and-versioning: the merge rule and the review order ---
steps_body "$root/skills/libra-git-workflow-and-versioning/SKILL.md" | grep -qF 'each one builds and passes the suite' ||
  { echo "FAIL libra-git-workflow-and-versioning: the merge policy lost its first row"; fail=1; }
steps_body "$root/skills/libra-git-workflow-and-versioning/SKILL.md" | grep -qF 'Clean the history before review, never after a verdict' ||
  { echo "FAIL libra-git-workflow-and-versioning: history may be cleaned after a review, voiding it"; fail=1; }
has libra-git-workflow-and-versioning 'may go straight to the default branch only when this file says so' 'a direct commit is allowed without a recorded exception'
write_body "$root/skills/libra-git-workflow-and-versioning/SKILL.md" | grep -qF 'docs/GIT.md' ||
  { echo "FAIL libra-git-workflow-and-versioning: Write does not name docs/GIT.md"; fail=1; }

# --- the pointers: each skill keeps its own rule and names the policy file ---
has libra-ship 'not permission to tag'                 'an unmerged project may be tagged after all'
steps_body "$root/skills/libra-ship/SKILL.md" | grep -qF 'docs/GIT.md` must allow' ||
  { echo "FAIL libra-ship: the direct-commit exception does not name the file that allows it"; fail=1; }
grep -qF 'Read the scheme from `docs/GIT.md` and never infer it' "$root/skills/libra-release/SKILL.md" ||
  { echo "FAIL libra-release: the version scheme is inferred, not read"; fail=1; }
steps_body "$root/skills/libra-incremental-implementation/SKILL.md" | grep -qF 'docs/GIT.md` must allow' ||
  { echo "FAIL libra-incremental-implementation: the default-branch clause is gone"; fail=1; }
steps_body "$root/skills/libra-build/SKILL.md" | grep -qF 'state branch-or-direct before the first commit: which branch' ||
  { echo "FAIL libra-build: the commit destination is never stated"; fail=1; }

# --- bootstrap asks about git before it writes the state file ---------------
grep -qF 'exactly three questions' "$root/skills/libra-bootstrap-project/SKILL.md" ||
  { echo "FAIL libra-bootstrap-project: git is never asked about"; fail=1; }
grep -qF 'libra-git-workflow-and-versioning' "$root/skills/libra-bootstrap-project/SKILL.md" ||
  { echo "FAIL libra-bootstrap-project: no handoff writes docs/GIT.md"; fail=1; }
flat "$root/skills/libra-bootstrap-project/references/old-repo.md" | grep -qF 'Docs` cell stays empty' ||
  { echo "FAIL libra-bootstrap-project: a Docs cell may cite a file that does not cover it"; fail=1; }

# --- libra-release: the gates are commands in the steps, not advice ---------------
for gate in 'git rev-parse --abbrev-ref HEAD' 'git status --short' \
            'git status -sb' 'git tag -l' 'git ls-remote --tags origin'; do
  steps_body "$root/skills/libra-release/SKILL.md" | grep -qiF -- "$gate" ||
    { echo "FAIL libra-release: gate '$gate' is not in the steps"; fail=1; }
done
steps_body "$root/skills/libra-release/SKILL.md" | grep -qiF 'exit 0 and print nothing' ||
  { echo "FAIL libra-release: gate 4 lets an unreachable host look like a free name"; fail=1; }
steps_body "$root/skills/libra-release/SKILL.md" | grep -qiF 'behind' ||
  { echo "FAIL libra-release: gate 3 does not refuse a branch behind its upstream"; fail=1; }
steps_body "$root/skills/libra-release/SKILL.md" | grep -qiF 'gh release view' ||
  { echo "FAIL libra-release: never verifies the release exists"; fail=1; }

# --- libra-release: the note is filled from a template, and claims no more ---------
tpl="$root/skills/libra-release/templates/release-notes.md"
for h in '## Highlights' '## Added' '## Changed' '## Removed' '## Upgrade' \
         '## Full changelog'; do
  grep -qxF -- "$h" "$tpl" 2>/dev/null ||
    { echo "FAIL libra-release: the note template has no '$h' section"; fail=1; }
done
steps_body "$root/skills/libra-release/SKILL.md" | grep -qF 'copy `templates/release-notes.md` to `/tmp/<version>-notes.md`' ||
  { echo "FAIL libra-release: the template is edited in place instead of copied out"; fail=1; }
steps_body "$root/skills/libra-release/SKILL.md" | grep -qF 'drop its frontmatter and comment' ||
  { echo "FAIL libra-release: the template's frontmatter or comment is published in the note"; fail=1; }
steps_body "$root/skills/libra-release/SKILL.md" | grep -qF 'fill every entry from the changelog section' ||
  { echo "FAIL libra-release: an entry the changelog has may be dropped from the note"; fail=1; }
steps_body "$root/skills/libra-release/SKILL.md" | grep -qF 'claiming nothing the changelog does not' ||
  { echo "FAIL libra-release: the note may claim more than the changelog"; fail=1; }
steps_body "$root/skills/libra-release/SKILL.md" | grep -qF -- '--notes-file /tmp/<version>-notes.md' ||
  { echo "FAIL libra-release: publishes a file other than the note that was filled"; fail=1; }
steps_body "$root/skills/libra-release/SKILL.md" | grep -qF '`gh release view v<version>` shows no `<` placeholder' ||
  { echo "FAIL libra-release: a template placeholder can ship inside the published note"; fail=1; }
flat "$tpl" | grep -qF 'The filled note must pass `check-docs.sh`' ||
  { echo "FAIL libra-release: an empty section ships because nothing checks the note"; fail=1; }
flat "$tpl" | grep -qF 'delete this whole section when nothing breaks' ||
  { echo "FAIL libra-release: nothing tells the filler to drop an empty upgrade section"; fail=1; }

# --- a dead skill name is a routing bug -------------------------------------
for f in "$root"/skills/*/SKILL.md; do
  grep -q 'write-spec' "$f" &&
    { echo "FAIL $(basename "$(dirname "$f")"): names a skill that no longer exists"; fail=1; }
done

# --- behavior evals: the grader must tell a right answer from a wrong one -----
for c in "$root"/evals/behavior/cases/*/; do
  n=$(basename "$c")
  out=$(bash "$root/evals/behavior/run.sh" "$n" --self-test 2>&1) ||
    { echo "FAIL behavior eval $n: $out"; fail=1; }
done

# --- routing eval: does a model pick the skill a human would? ----------------
out=$(bash "$root/evals/routing/run.sh" --self-test 2>&1) ||
  { echo "FAIL routing eval: $out"; fail=1; }

# --- every skill carries an Anthropic-style eval file ----------------------
skills=0
cases=0
for d in "$root"/skills/*/; do
  n=$(basename "$d")
  f="$root/evals/skills/$n/evals.json"
  skills=$((skills + 1))
  [ -f "$f" ] || { echo "FAIL $n: no evals/skills/$n/evals.json"; fail=1; continue; }
  grep -q "\"skill_name\": \"$n\"" "$f" ||
    { echo "FAIL $n: eval file names another skill"; fail=1; }
  ncases=$(grep -c '"id":' "$f")
  [ "$ncases" -ge 2 ] ||
    { echo "FAIL $n: fewer than two evals"; fail=1; }
  cases=$((cases + ncases))
done
# The count is derived, not pinned: two per skill is the rule, so adding a skill
# cannot leave the total stale.
[ "$cases" -ge $((skills * 2)) ] ||
  { echo "FAIL evals: $cases cases for $skills skills (need two each)"; fail=1; }
# --- the contract suite must be able to fail --------------------------------
if [ -z "${LIBRA_EVAL_SELF_TEST:-}" ]; then
  out=$(LIBRA_EVAL_SELF_TEST=1 bash "$root/evals/self-test.sh" 2>&1) ||
    { echo "FAIL evals/self-test.sh: $out"; fail=1; }
fi

[ "$fail" -eq 0 ] && echo "evals passed"
exit "$fail"
