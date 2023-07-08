#!/bin/sh

/var/packages/nomad/target/bin/nomad agent -config "/var/packages/nomad/shares/nomad/etc/nomad.d/nomad.hcl" -config "/var/packages/nomad/shares/nomad/etc/nomad.d/"
