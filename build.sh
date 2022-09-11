#!/bin/sh
set -e
./info.sh 0.0.1-1000 noarch >> INFO
tar -cvzf package.tgz package
tar -cvf package.spk INFO LICENSE conf/ package.tgz scripts/pre* scripts/post* scripts/start*
rm package.tgz
mv package.spk nomad.spk
