#!/usr/bin/env bash

set -euo pipefail
set -x

DIRNAME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cd "$DIRNAME"
. "../../util.sh"
. "./vars.sh"

REPO="turbo-schedule"
REPO_AUTHOR="basedschool"
PRIVATE=1
BRANCH="school-kvg"
PORT="7000"
IMAGE_USER=mykolasspu
clone_repo

(
	cd "$REPO_ROOT"
	./run-docker.sh
)

install_nginx_site_with_replace "kvg.tvarkarastis.com" "PORT" "CONFIG_URL"
install_nginx_site_with_replace "plain"

>&2 printf "\ndeployed turbo-schedule. though, for full deployment, re-deploy yourself thru turbo-schedule/deploy.sh\n\n"
