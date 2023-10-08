#!/bin/sh

. /lib/functions.sh

[ -f "/etc/config/upnpd" ] || return 0

fix_secure_mode() {
        local value
        config_get value config secure_mode
        [ -n "$value" ] || uci_set upnpd config secure_mode 1
}

config_load upnpd
config_foreach fix_secure_mode upnpd
uci commit upnpd

exit 0
