#!/bin/sh

source /var/packages/nomad/var/env.sh
/var/packages/nomad/target/bin/nomad agent -config "${NOMAD_SHARE_DIR}/etc/nomad.d/nomad.hcl" -config "${NOMAD_SHARE_DIR}/etc/nomad.d/"
