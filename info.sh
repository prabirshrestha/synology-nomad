#!/bin/sh

VERSION=$1

TIMESTAMP=$(date -u +%Y%m%d-%H:%M:%S)

os_min_ver="7.0-40000"
os_max_ver=""

cat <<EOF
package="nomad"
version="${VERSION}"
arch="noarch"
thirdparty="yes"
description="Orchestration Made Easy by HashiCorp Nomad."
displayname="HashiCorp Nomad"
maintainer="prabirshrestha"
maintainer_url="https://github.com/prabirshrestha/synology-nomad-package"
create_time="${TIMESTAMP}"
support_conf_folder="yes"
startstop_restart_services="nginx"
os_min_ver="${os_min_ver}"
os_max_ver="${os_max_ver}"
silent_install="yes"
silent_uninstall="yes"
silent_upgrade="yes"
beta="yes"
EOF
