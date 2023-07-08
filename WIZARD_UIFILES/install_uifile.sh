#!/bin/sh

SYNOLOGY_IP=$(ip route get "$(ip route show 0.0.0.0/0 | grep -oP 'via \K\S+')" | grep -oP 'src \K\S+')

tee "$SYNOPKG_TEMP_LOGFILE" <<EOF
[
  {
    "step_title": "Nomad Configuration",
    "items": [
      {
        "type": "textfield",
        "desc": "Nomad Web UI URL",
        "subitems": [
          {
            "key": "pkgwizard_nomad_web_ui_url",
            "defaultValue": "http://$SYNOLOGY_IP:4646"
          }
        ]
      }
    ]
  }
];
EOF

exit 0
