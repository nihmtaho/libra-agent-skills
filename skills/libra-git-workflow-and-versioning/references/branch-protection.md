# Branch protection

Protect the default branch so a change lands only after review and CI. This is a
policy decision first and a GitHub setting second.

## Decide

- Required checks: the exact CI job names that must pass.
- Required approvals: at least one, from someone other than the author.
- Dismiss stale approvals when the branch changes.
- Require conversation resolution before merge.
- Require linear history when the project fast-forwards.
- Block force pushes and branch deletion.
- Admin bypass: off. No exception.
- Auto-merge: allowed only when the checks and approvals above are required.

Write the chosen values into `docs/GIT.md`. A setting nobody wrote down is a
setting the next admin will change by accident.

## Apply on GitHub

Read the current state before changing it:

```bash
gh api repos/{owner}/{repo}/rulesets
gh api repos/{owner}/{repo}/branches/{branch}/protection
```

Prefer rulesets when the repository and plan support them; use classic branch
protection otherwise. Put the intended policy in `.github/rulesets/<branch>.json`,
show the file and the diff to the human, and apply it only after approval:

```bash
gh api --method POST repos/{owner}/{repo}/rulesets \
  --input .github/rulesets/<branch>.json
```

Then read it back and report what is actually enforced:

```bash
gh api repos/{owner}/{repo}/rulesets
gh api repos/{owner}/{repo}/branches/{branch}/protection
```

Never use `--admin` to get a merge through. If GitHub refuses, quote the error
and stop. If the plan or visibility does not support rulesets, say which feature
is unavailable and use the classic endpoint the same way.

## Auto-merge

Enable repository auto-merge only after the protection above exists:

```bash
gh api --method PATCH repos/{owner}/{repo} -f allow_auto_merge=true
```

Then a PR can enable auto-merge; GitHub merges it only when every required check
and review is satisfied. Auto-merge is a convenience, not a second gate.
