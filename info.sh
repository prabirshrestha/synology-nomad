#!/bin/sh

VERSION=$1
ARCH=$2
DSM_VERSION=$3

TIMESTAMP=$(date -u +%Y%m%d-%H:%M:%S)

if [ "$DSM_VERSION" = "6" ]; then
  os_min_ver="6.0.1-7445"
  os_max_ver="7.0-40000"
else
  os_min_ver="7.0-40000"
  os_max_ver=""
fi

cat <<EOF
package="nomad"
version="${VERSION}"
arch="${ARCH}"
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
