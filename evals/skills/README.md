# Per-skill evals

Each `<skill>/evals.json` follows the Anthropic `evals.json` schema: a
`skill_name`, and evals with an `id`, a realistic `prompt`, an
`expected_output`, optional `files`, and verifiable `expectations`.

These files are data, and `run.sh` prepares a reproducible sandbox for each case:

```bash
bash evals/skills/run.sh <skill> <eval-id> with
# ... an agent session works in the printed sandbox ...
bash evals/skills/verify.sh <skill> <eval-id> <sandbox>
```

`run.sh --inventory` builds every case's sandbox and proves the set is runnable
without calling a model. `fixtures.sh` creates the starting project. In `with`
mode the whole skill set is installed into `.claude/skills` (and ignored by git),
so `using-libra` can actually route to `interview-me`, `idea-refine` and the
others; the baseline has no skills. `verify.sh` grades a written `grading.json`
against the case expectations, or prints the grader task when none exists.

The repository's existing `evals/run.sh`, `evals/behavior/` and
`evals/routing/` still cover the contract, artifact and routing layers.

## Full run
1. `bash evals/skills/run.sh --inventory` — every case must print `OK`.
2. For each case, run `run.sh` twice: `with` and `without`, in separate
   sandboxes. Give the prompt to an agent session, save its reply and artifacts,
   and grade with `verify.sh`.
3. A live case counts only after three consecutive `with` runs pass. The runner
   is manual on purpose: the repository's automated suite never calls a model.

The first three skills chosen for the pilot are `using-libra`,
`spec-driven-development` and `change-review`.

## Pilot 2026-11-22
Three consecutive runs of each case, with the skill and once without it, in
separate sandboxes built by `run.sh`.

| Skill | With skill (3 runs) | Baseline | Finding |
|---|---|---|---|
| `using-libra` | 4/4 every run | 3/4 | The skill classifies, routes through interview/spec/plan, and names `feat/dark-mode`; the baseline names a branch but no task. |
| `spec-driven-development` | 6/6 every run | 3/6 | The skill blocks Structure and Test plan; the baseline invents a 7-day lifetime, roles and seams. The case now requires the stop and forbids invention. |
| `change-review` | 5/5 every run | 5/5 | Both catch the lowered bar and the skip. Keep this case as a regression guard, not a differentiator. |

The baseline numbers for `spec-driven-development` are the old output regraded
against the tightened case, not a fresh run. The other 60 cases have one sample
or none; they do not yet meet the three-run rule.

## Screening 2026-11-22
The first 54-run pass found mostly fixture and case errors, not skill failures:
API had no endpoint, subagent had one runnable task, release had a dirty tree
and no upstream, office had a prompt injection in the summary fixture, build's
task was already done, and interview-me forbade the read its own skill requires.
Those cases and fixtures were fixed.

The targeted rerun now scores `source-driven-development` 4/4 and `release`
5/5, with `build`, `api-and-interface-design`, `root-cause`,
`simplify-change` and `subagent-driven-development` at 3/4. The one release
failure was a same-second push-order check, so the case now checks that both
the branch and the tag are pushed. The remaining with-skill failures name skill
rules rather than fixture gaps: `build` does not commit the slice,
`api-and-interface-design` misses boundary validation, `root-cause` proposes
but does not apply the shared fix, `simplify-change` batches changes, and
`subagent-driven-development` does not pass the Touches limit to a subagent.
These are findings for the full run, not eval blockers.

## Full run 2026-11-25
63 cases, 126 runs. With-skill: 44 of 63 fully pass, average 0.90. Baseline:
6 of 63 fully pass, average 0.52. The skill set adds a large, measurable margin.
The remaining with-skill failures are mostly model adherence (branch statement,
self-review, refactor step, Touches brief, colour meaning, network approval,
interview routing). Three were case gaps and are now fixed: `bootstrap-project` id 1 uses the
answers already in the prompt, `using-libra` id 3 has a README to fix, and
`verify-work` id 2 has a deterministically failing test. All three pass with the skill.
