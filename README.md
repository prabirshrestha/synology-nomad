# HashiCorp Nomad Package for Synology DSM 7+

# Building the .spk package

Requires `curl` and `unzip`.
Nomad binary will be downloaded on demand and bundled with the final .spk pacakge.

```bash
git clone https://github.com/prabirshrestha/synology-nomad.git
cd synology-nomad
./build.sh
```

To change the version to nomad binary or architecture set the environment version.

```bash
ARCH=amd64 NOMAD_VERSION=1.4.0 ./build.sh
ARCH=arm64 NOMAD_VERSION=1.4.0 ./build.sh
```

# Installing the package

Use the package center from Synology DSM to import the nomad spk file.
* A user `nomad` will be created.
* A share `nomad` will be created. For example: `/volume1/nomad`.
* Default configuration can be found on the share in `/path_to_nomad_share/etc/nomad.d/nomad.hcl`.
  Additional files can be added in the directory for other config files related to nomad. Restarting the package is required for any additional changes to the config.
* Data directory for nomad is set as `/path_to_nomad_share/var/lib/nomad`
* `nomad` binary can be found at `/usr/local/bin/nomad`.

# Docker support in Nomad for Synology

Since packages cannot be run as root with DSM7+, additional commands need to be manually executed.

* SSH into the machine and run the following command.

```bash
sudo synogroup --add docker                     # create a group called docker
sudo synogroup --member docker nomad            # add nomad user to docker group
sudo chown root:docker /var/run/docker.sock     # change owner to docker group
```

* A one time restart of the package may be required for nomad to access docker after running the above commands.

Docker access can be verified by navigating to the nomad UI and looking into the driver status for docker.

# Accessing Nomad UI

Nomad is accessiblity via the `https://SynologyIP:4646` port. Since acl is enabled you will need to
loging via ssh and run `nomad acl boostrap` to generate the initial token. You can then use the
`SecretID` as token to authorize the UI portal or generate other tokens.

```bash
$ NOMAD_CACERT=/volume1/nomad/etc/certs/nomad-ca.pem \
  NOMAD_CLIENT_CERT=/volume1/nomad/etc/certs/server.pem \
  NOMAD_CLIENT_KEY=/volume1/nomad/etc/certs/server-key.pem \
  NOMAD_ADDR=https://localhost:4646 \
  nomad acl bootstrap
Accessor ID  = 5325e529-8048-2a6a-711e-8a1110562c93
Secret ID    = fe672cf4-16b0-af1d-3db5-1832a8ec4c7d
Name         = Bootstrap Token
Type         = management
Global       = true
Create Time  = 2022-12-15 03:04:34.932856392 +0000 UTC
Expiry Time  = <none>
Create Index = 24
Modify Index = 24
Policies     = n/a
Roles        = n/a
```

# Volumes

To use host volume you can specific the `mount` settings in `config` section for the nomad job.

```
mount {
  type = "bind"
  source = "/volume1/path/in/host"
  target = "/path/inside/container"
  readonly = false
}
```

# Uninstalling

* Uninstall can be done via the package center.
* Due to the nature of how packages work in Synology, `nomad` user and `nomad` share will not be removed during uninstallation of the package.
 Reinstalling the package will reuse exisiting configurations and data. If you want clean installation you can remove the `nomad` share and install the package again.
* To delete `nomad` user run `sudo synogroup --del nomad` after package has been uninstall.

# LICENSE

MIT.
For nomad binary refer to the Nomad license.
