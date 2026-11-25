# Rebuild from an old repo

1. List the entry point, test command and run command. Run the cheapest test
   once; if it needs credentials or minutes, record it as unverified. Quote what
   you ran.
2. Read the last twenty commits for vocabulary and for what was worked on lately.
3. Fill `## Module map`, 3-8 lines: path → what it does → where it breaks.
4. Fill `## Features` from evidence: `done` needs code, a passing test, and a
   path from the app into that code; `planned` means only a document mentions
   it. `Stopped at` names the exact stop; a `Docs` cell stays empty rather than
   citing a file that does not cover the feature.
5. Fill `## Decisions` with decisions written down or provable from the code's
   shape, one line each with the reason. None found: write `none yet`.
6. Fill `## Run & verify` with what you actually ran and what green looked like.
7. Fill `## Next` with three items, the first small enough for one session. No
   git history: write that in `## Next` instead of guessing what came first.
