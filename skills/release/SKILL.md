---
name: release
description: Cut a version from the default branch — changelog, tag, notes — after the work has landed. Use when the default branch already holds the work and a version, tag or publish is wanted.
---

# release

A release is a claim that one specific commit is the product. Everything here
exists so that claim is checkable by someone who was not in the room.

## When to use

Use when the work is already on the default branch and the human asks for a
version, a tag or a publish.
Not for merging a change: that is `ship`. Not for a feature branch, a dirty tree,
or a release with nothing to record.

## Read first

1. `git rev-parse --abbrev-ref HEAD`, `git status --short`, and the remote line of
   `git status -sb`.
2. `CHANGELOG.md` — the unreleased section, and the version that follows it.
3. `docs/PROJECT.md` — the `## Next` list, and any row that is `done` but not yet
   released.
4. The last tag: `git describe --tags --abbrev=0`.

## Steps

1. Four gates, stop at the first that fails:
   - `git rev-parse --abbrev-ref HEAD` prints the default branch, never a feature
     branch.
   - `git status --short` prints nothing.
   - `git status -sb` says neither `ahead of` nor `behind`, and names an upstream:
     a branch that cannot be pushed leaves a tag nothing can delete for you.
   - `git tag -l v<version>` and `git ls-remote --tags origin refs/tags/v<version>`
     both exit 0 and print nothing: an unreachable host must not look like a free
     name.

   A tag cut from a feature branch is public before anyone can review it, and
   moving it afterwards is a lie about what shipped. Ahead means push the branch
   and start again; behind means pull; no upstream means set one.
2. Version gate. Read the scheme from `docs/GIT.md` and never infer it. `none`:
   stop here, before the changelog; a project that does not version does not want
   a tag. `semver`, or no file at all: patch for a fix, minor for a new skill,
   document type or removal before 1.0, major after 1.0, and say in one line that
   SemVer was assumed. Any other scheme: stop and report it. When a rename or
   removal breaks an install, the changelog says so in one line, with the command
   that fixes it.
3. Changelog before the tag: `## [<version>] - <date>` with Added, Changed and
   Removed, one line per skill, never per file. An empty section means there is no
   release: stop.
4. Suite green on this exact commit, run as `## Run & verify` says. Green from
   before the last merge is not green.
5. Tag annotated on the default branch tip, then push the branch, then the tag:
   `git tag -a v<version> -m "<one line>"`, `git push origin <branch>`,
   `git push origin v<version>`.
6. Notes: copy `templates/release-notes.md` to `/tmp/<version>-notes.md`, fill
   every section from the changelog section, and claim nothing the changelog
   does not. Publish with `gh release create v<version> --title "v<version>"
   --notes-file /tmp/<version>-notes.md`. No `gh`, or it errors: stop and say
   the release is tagged but unpublished.
7. Verify by command, not by memory: `git ls-tree --name-only v<version>` and
   `gh release view v<version>`. A tag is not a release.
8. Record the next version's first item in `docs/PROJECT.md` `## Next`, so the
   state file points at work that exists.

## Write

`CHANGELOG.md`, `docs/PROJECT.md` `## Next`, the tag, and the release note.

Run `bash scripts/check-docs.sh <the file you wrote>` and fix every FAIL before
you finish; no script in the project: say so in one line and continue.

## Stop

Stop when the branch is not the default one, has no upstream, or is ahead of or
behind its upstream; when the tree is dirty; when the tag exists locally or on
the remote; when the changelog section is empty; when the scheme is `none` or one
this skill does not know; or when the suite is red. Report which gate failed and
the command output that shows it.
