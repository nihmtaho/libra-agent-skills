#!/usr/bin/env bash
set -u
exec bash "$(dirname "$0")/test/greet_test.sh"
