#!/usr/bin/env bash

set -e
set -u

folder=$1
commit_SHA="f4c6d9689be9dac99462b4dba5764633cfc9c89f"
repository="https://github.com/invizbox/openwrt.git"

if [[ -d ${folder} ]]; then
    echo "A ${folder} repository already exists, checking if it is the correct one"
    cd "${folder}"
    local_repo=$(git remote -v | grep origin | grep fetch | awk '{print $2}')
    if [[ "${repository}" == "${local_repo}" ]]; then
        echo "The repo is the correct one, updating it"
        git fetch --all -p
        git checkout --force "${commit_SHA}" 2>/dev/null
        exit 0
    else
        echo "The repo wasn't the correct one. Expected [${repository}] but got [${local_repo}] removing it"
        cd ..
        rm -rf "${folder}"
    fi
fi
# now we either removed a repo that wasn't the correct one or none existed.
echo "Cloning ${repository}"
git clone "${repository}" "${folder}" 2>/dev/null
cd "${folder}"
git checkout "${commit_SHA}" 2>/dev/null
echo "Successful update/clone of repo ${repository}"
