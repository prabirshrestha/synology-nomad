#!/bin/sh
set -e

export OS="${OS:-linux}"
export ARCH="${ARCH:-amd64}"
export NOMAD_VERSION="${NOMAD_VERSION:-1.4.3}"
nomad_zip_file="nomad_${NOMAD_VERSION}_${OS}_${ARCH}.zip"
export NOMAD_URL="${NOMAD_URL:-https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${nomad_zip_file}}"

mkdir -p package

if [[ ! -f "./tmp/${nomad_zip_file}" ]]; then
    curl --create-dirs -Lo "./tmp/$nomad_zip_file" "${NOMAD_URL}"
fi

if [[ ! -f "./package/bin/nomad" ]]; then
    unzip -o -d "./package/bin/" "./tmp/${nomad_zip_file}"
fi

./info.sh 1.4.3-1000 >> INFO
tar -cvzf package.tgz package
tar -cvf package.spk INFO LICENSE conf/ package.tgz scripts/pre* scripts/post* scripts/start*
rm package.tgz
mv package.spk "nomad_${NOMAD_VERSION}_${OS}_${ARCH}.spk"
