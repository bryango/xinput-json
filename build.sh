#!/bin/bash
# build home configs

set -x
cd "$(dirname "$0")" || exit

nix build .#wingcool-bind "$@"
nix build .# "$@"
## ^ the latter build `result` overwrites the previous one
