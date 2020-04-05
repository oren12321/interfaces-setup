#!/usr/bin/env bash

set -Eeuo pipefail
[ -z "${DEBUG:-}" ] && DEBUG=0
[ "${DEBUG}" -eq 1 ] && set -x

# parameters
#   (optional) regex
get_interfaces_names() {
    printf "$(ip --brief link show label "${1:-*}" | grep -Eo '^[^ ]+' | tr '\n' ' ')"
}

# parameters
#   (optional) regex
get_interfaces_count() {
    return "$(ip --brief link show label "${1:-*}" | wc --lines)"
}

# parameters
#   interface
#   ip/netmask
setup_ip() {
    ip address flush dev "${1}" && \
    ip address add "${2}" dev "${1}"
}

# parameters
#   interface
#   ip/netmask
setup_route() {
    ip route add "${1}" dev "${2}"
}

# parameters
#   interface
#   delay [us]
setup_rx_coalescing() {
    set +Ee
    ethtool --coalesce "${1}" rx-usecs "${2}"
    set -Ee
}

# parameters
#   interface
#   size [bytes]
setup_rx_ring() {
    set +Ee
    ethtool --set-ring "${1}" rx "${2}"
    set -Ee
}
