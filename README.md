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
ARCH=amd64 NOMAD_VERSION=1.5.0 ./build.sh
ARCH=arm64 NOMAD_VERSION=1.5.0 ./build.sh
```

# Installing the package

Use the package center from Synology DSM to import the nomad spk file.
* A user `nomad` will be created.
* A share `nomad` will be created. For example: `/volume1/nomad` which can be accessed using `/var/packages/nomad/shares/nomad`.
* Default configuration can be found on the share in `/var/packages/nomad/shares/etc/nomad.d/nomad.hcl`.
  Additional files can be added in the directory for other config files related to nomad. Restarting the package is required for any additional changes to the config.
* Data directory for nomad is set as `/var/packages/nomad/shares/nomad/var/lib/nomad`
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

Nomad is accessible via the `http://SynologyIP:4646` port. Since acl is enabled you will need to
login via ssh and run `nomad acl bootstrap` to generate the initial token. You can then use the
`SecretID` as token to authorize the UI portal or generate other tokens.

```bash
$ nomad acl bootstrap
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

# Security

Default nomad configuration uses http instead of https. It is recommended to follow best practices for securing nomad such as using TLS certs or changing firewall rules to disable nomad access.

## TLS certs

Here is a basic example on creating tls certs assuming `192.168.1.5` is an IP address of Synology NAS.
`-cluster-region`, `-additional-domain`, `-additional-ipaddress` and `-additional-dns` and `-days` are optional. Refer to the official nomad documention for details.

```bash
export IP=192.168.1.5
export DOMAIN=nas.example.com
export REGION=global
mkdir -p /var/packages/nomad/shares/nomad/etc/certs
cd /var/packages/nomad/shares/nomad/etc/certs
nomad tls ca create -additional-domain $IP -additional-domain $DOMAIN -days 1825
nomad tls cert create -server -cluster-region $REGION -additional-ipaddress $IP -additional-dnsname $DOMAIN -days 365
nomad tls cert create -cli -cluster-region $REGION -additional-ipaddress $IP -additional-dnsname $DOMAIN -days 365
```

Update `/var/packages/nomad/shares/nomad/etc/nomad.d/nomad.hcl` to use the certificates.

```
export REGION=global
    cat <<EOF >> /var/packages/nomad/shares/nomad/etc/nomad.d/nomad.hcl
region=$REGION
tls {
  http = true
  rpc = true

  ca_file = "/volume1/nomad/etc/certs/nomad-agent-ca.pem"
  cert_file = "/volume1/nomad/etc/certs/$REGION-server-nomad.pem"
  key_file = "/volume1/nomad/etc/certs/$REGION-server-nomad-key.pem"

  verify_server_hostname=true
  verify_https_client=true
}
EOF
```

To access via Chrome browser generate the p12 cert and import by navigating to `chrome://settings/certificates?search=certificate`.

```bash
export REGION=global
openssl pkcs12 -export -legacy -inkey ./$REGION-cli-nomad-key.pem -in ./$REGION-cli-nomad.pem -out ./$REGION-cli-nomad.p12 -passout pass:
```

`-legacy` flag is required when using newer version of openssl to be compatible with MacOS which can be installed by Key Chain.

To easily access via client set the following enviorment variables. You can also save this to a file `env` and call `source env`.

```bash
export REGION=global
export IP=192.168.1.5
export NOMAD_ADDR=https://$IP:4646
export NOMAD_CACERT=nomad-agent-ca.pem
export NOMAD_CACERT=/var/packages/nomad/shares/nomad/etc/certs/nomad-agent-ca.pem
export NOMAD_CLIENT_CERT=/var/packages/nomad/shares/nomad/etc/certs/$REGION-cli-nomad.pem
export NOMAD_CLIENT_KEY=/var/packages/nomad/shares/nomad/etc/certs/$REGION-cli-nomad-key.pem
export NOMAD_TOKEN="BOOTSTRAP_SECRET_ID"
```

# Volumes

To use host volume you can specify the `mount` settings in `config` section for the nomad job.

```
mount {
  type = "bind"
  source = "/volume1/path/in/host"
  target = "/path/inside/container"
  readonly = false
}
```

# Logs

Installation log can be found at `/var/packages/nomad/shares/nomad/var/log/nomad/install.log`.

systemd logs for nomad, can be found by `sudo systemctl status pkgctl-nomad.service` or `sudo journalctl -u pkgctl-nomad.service`.

## Viewing nomad logs

1. Find the process id of nomad.

```bash
$ ps -aux | grep -v grep | grep nomad
nomad    21818  1.0  0.2 2346532 85160 ?       Sl   03:37   0:07 /var/packages/nomad/target/bin/nomad agent -config /var/packages/nomad/shares/nomad/etc/nomad.d/nomad.hcl -config /var/packages/nomad/shares/nomad/etc/nomad.d/
```

Here `21818` is the process id of nomad.

2. Find the systemd unit file for nomad process id.

```bash
$ systemctl status 21818
user@258047.service - User Manager for UID 258047
  Loaded: loaded (/usr/lib/systemd/system/user@.service; static; vendor preset: disabled)
  Active: active (running) since Wed 2024-06-19 03:37:17 PDT; 14min ago
Main PID: 21700 (systemd)
  Status: "Startup finished in 27ms."
  CGroup: /user.slice/user-258047.slice/user@258047.service
          ├─21700 /usr/lib/systemd/systemd --user
          ├─21711 (sd-pam)
          └─nomad.slice
            └─pkguser-nomad.service
              ├─21817 /bin/sh /var/packages/nomad/target/start.sh
              └─21818 /var/packages/nomad/target/bin/nomad agent -config /var/packages/nomad/shares/nomad/etc/nomad.d/nomad.hcl -config /var/packages/n...
```

3. View logs using `journalctl`.

```bash
$ sudo journalctl -u user@258047.service
```

# Uninstalling

* Package can be uninstalled via the package center.
* Due to the nature of how packages work in Synology, `nomad` user and `nomad` share will not be removed during uninstallation of the package.
 Reinstalling the package will reuse exisiting configurations and data. If you want clean installation you can remove the `nomad` share and install the package again.
* To delete `nomad` user run `sudo synogroup --del nomad` after package has been uninstalled.

# LICENSE

MIT.
For nomad binary refer to the Nomad license.
