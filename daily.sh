#!/usr/bin/env bash

# build automation for Arch Linux packages

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; cd -P "$(dirname "$(readlink "${BASH_SOURCE[0]}" || echo .)")" || exit; pwd)
readonly script_dir

bash "${script_dir}/factorio-demo.sh"

