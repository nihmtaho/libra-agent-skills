#!/usr/bin/env bash
# Everything the repo claims about itself, in one command.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
bash "$here/check.sh"
bash "$here/test-install.sh"
