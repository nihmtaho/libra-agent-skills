#!/usr/bin/env bash
# Run the plugin package and guardrail tests. Used by scripts/test.sh in T6.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
node scripts/test-plugins.mjs
