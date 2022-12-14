#!/bin/sh

source /var/packages/nomad/var/env.sh
/var/packages/nomad/target/package/bin/nomad agent -config "${NOMAD_SHARE_DIR}/etc/nomad.d/nomad.hcl"
