#!/usr/bin/env bash

set -Eeuo pipefail
[ -z "${DEBUG:-}" ] && DEBUG=0
[ "${DEBUG}" -eq 1 ] && set -x

get_interfaces_names() {
    printf "$(ip --brief link show label "${1:-*}" | grep -Eo '^[^ ]+' | tr '\n' ' ')"
}

get_interfaces_count() {
    return "$(ip --brief link show label "${1:-*}" | wc --lines)"
}

setup_ip() {
    (ip --brief address show label "${1}" | grep -q "${2}") || \
        ip address flush dev "${1}" && \
        ip address add "${2}" dev "${1}"
}

setup_route() {
    (ip route | grep "${1}" | grep -q "${2}") || \
        ip route add "${1}" dev "${2}"
}

setup_rx_coalescing() {
    (ethtool --show-coalesce "${1}" | grep -i rx-usecs | grep -q "${2}") || \
        ethtool --coalesce "${1}" rx-usecs "${2}"
}

setup_rx_ring() {
    (ethtool --show-ring "${1}" | grep -i rx | grep -q "${2}") || \
        ethtool --set-ring "${1}" rx "${2}"
}

setup_interface() {
    __setup_ip && \
    __setup_route && \
    __setup_rx_coalescing && \
    __setup_rx_ring
}
