#!/usr/bin/env bash

set -euo pipefail
set -x

die() {
	>&2 printf "$1"
	exit "${2:-1}"
}
BUG() {
	die "BUG: $1"
}

test "$0" = "${BASH_SOURCE[0]}" && {
	BUG "util.sh should be sourced, not ran.\n"
}

UTILS_DIRNAME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

. "$UTILS_DIRNAME/vars.sh"

# replace_vars FILE VAR1 VAR2 VAR...
replace_vars() {
	FILE="$1"
	shift

	# replace all given by caller, and all from /vars.sh, and some extras
	for var in "$@" \
		"PERSON_NAME" "GITHUB_USERNAME" "INFRA_REPO_URL" \
		"USER"
	do
		echo "${!var}" | grep "@" >/dev/null \
			&& BUG "variable $var contains sed special char '@' (${!var}).\n"

		sed -i "s@\$${var}@${!var}@g" "$FILE"
	done
}

require_root() {
	test "$(id -u)" -eq 0 || die "script must be run as root.\n"
}

clone_forked_repo() {
	test -n "$REPO" || {
		BUG "clone_forked_repo: \$REPO not defined\n"
	}

	# we suffix $REPO with '.git'
	# to be automatically git-ignored in the infra repo.
	REPO_ROOT="${DIRNAME}/${REPO}.git"

	if test -d "$REPO_ROOT"; then
		>&2 printf "warn: not cloning repo - directory already exists ($REPO_ROOT).\n"
	else
		git clone --depth=1 $* "https://github.com/$GITHUB_USERNAME/$REPO" "$REPO_ROOT"
	fi

	(
		cd "$REPO_ROOT"
		local BRANCH="${BRANCH:-""}"

		test -z "$BRANCH" || {
			local remote="origin"
			git fetch origin "+refs/heads/$BRANCH:refs/remotes/$remote/$BRANCH"

			local curr_branch="$(git branch --show-current)"
			test "$curr_branch" = "$BRANCH" \
				|| git checkout -b "$BRANCH" "$remote/$BRANCH"
		}
	)
}

