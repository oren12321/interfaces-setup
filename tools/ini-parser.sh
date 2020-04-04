#!/usr/bin/env bash

[ -z "${DEBUG:-}" ] && DEBUG=0

set -Eeuo pipefail
[ "${DEBUG}" -eq 1 ] && set -x

[ "${#}" -ne 1 ] && printf "usage: ini-parser.sh <ini-file-path>"

declare_from_ini() {
    while IFS= read -r line; do
        (printf "${line}" | grep -Eq "^\[(.+)\]$") && \
            { section=${line:1:-1}; printf "declare -A ${section}\n"; }
        ([ ! -z "${section:-}" ] && printf "${line}" | grep -Eq ".+=.+") && \
            IFS="=" read key value <<< "${line}" && \
            printf "${section}[${key}]=${value}\n"
    done < "${1}"
}

eval "$(declare_from_ini "${1}")"
