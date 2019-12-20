#!/bin/bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump | gzip`
set -o pipefail

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

hugo

pushd public
	git add .
	COMMIT_MESSAGE="rebuilding site $(date)"
	if [ -n "$*" ]; then
		COMMIT_MESSAGE="$*"
	fi
	git commit -m "${COMMIT_MESSAGE}"
	git push origin master
popd

printf "\033[0;32mDeployment complete!\033[0m\n"
