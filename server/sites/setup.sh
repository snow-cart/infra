#!/usr/bin/env bash

set -euo pipefail
set -x

DIRNAME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$DIRNAME"
. "../../util.sh"
. "./vars.sh"

# (
# 	REPO="bonk.lt"
# 	install_nginx_site_with_replace "$REPO" "USER"
# )

