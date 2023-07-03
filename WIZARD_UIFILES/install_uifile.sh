#!/bin/sh

SYNOLOGY_IP=$(ip route get "$(ip route show 0.0.0.0/0 | grep -oP 'via \K\S+')" | grep -oP 'src \K\S+')

tee "$SYNOPKG_TEMP_LOGFILE" <<EOF
[
    {
	"step_title": "Nomad Configuration",
	"items": [
	    {
		"type": "textfield",
		"desc": "IP address of Nomad Server (Default: Synology primary ip)",
		"subitems": [
		    {
			"key": "pkgwizard_ip",
			"desc": "IP of your synology device",
			"defaultValue": "$SYNOLOGY_IP",
			"validator": {
			    "allowBlank": false
			}
		    }
		]
	    },
	    {
		"type": "textfield",
		"desc": "Port for Nomad Web UI",
		"subitems": [
		    {
			"key": "pkgwizard_nomad_web_ui_port",
			"desc": "Port for Nomad Web UI",
			"defaultValue": "4646",
			"validator": {
			    "allowBlank": false,
			    "regex": {
				"expr": "/^[1-9]\\\\d{0,4}$/"
			    }
			}
		    }
		]
	    },
	    {
		"type": "textfield",
		"desc": "Nomad Region",
		"subitems": [
		    {
			"key": "pkgwizard_nomad_region",
			"desc": "Nomad Region",
			"defaultValue": "global",
			"validator": {
			    "allowBlank": false
			}
		    }
		]
	    },
	    {
		"type": "textfield",
		"desc": "Nomad Datacenter",
		"subitems": [
		    {
			"key": "pkgwizard_nomad_datacenter",
			"desc": "Nomad Datacenter",
			"defaultValue": "dc1",
			"validator": {
			    "allowBlank": false
			}
		    }
		]
	    },
	    {
		"type": "textfield",
		"desc": "Nomad Region",
		"subitems": [
		    {
			"key": "pkgwizard_nomad_region",
			"desc": "Nomad region",
			"defaultValue": "global",
			"validator": {
			    "allowBlank": false
			}
		    }
		]
	    }
	]
    }
];
EOF

exit 0
