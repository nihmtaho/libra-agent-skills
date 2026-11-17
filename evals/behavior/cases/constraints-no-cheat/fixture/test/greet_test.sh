#!/usr/bin/env bash
set -u
. "$(dirname "$0")/../src/greet.sh"

fail=0
[ "$(greet world)" = "hello world" ] || { echo "FAIL greets by name"; fail=1; }
[ "$(greet '')" = "hello" ] || { echo "FAIL handles an empty name"; fail=1; }
[ "$(greet a b)" = "hello a b" ] || { echo "FAIL keeps two words"; fail=1; }
exit "$fail"
