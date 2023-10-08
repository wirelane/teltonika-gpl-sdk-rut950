#!/bin/sh

. /lib/functions.sh

[ -f "/etc/config/teltonika" ] || return 0

add_forwarding() {
	local name
	config_get name "$1" name
	[ "$name" = "lan" ] && return
	[ "$name" = "wan" ] && {
		uci_set firewall "$1" helper "pptp";
	}

	uci_add firewall forwarding
	uci_set firewall "$CONFIG_SECTION" src lan
	uci_set firewall "$CONFIG_SECTION" dest "$name"
}

add_missing_zone_options() {
	local network name
	config_get network "$1" network
	config_get name "$1" name

	list_contains network ppp && {
		network="${network/ppp/mob1s1a1}"
		uci_set firewall "$1" network "$network"
	}

	list_contains network wan2 && {
		network="${network/wan2/wwan}"
		uci_set firewall "$1" network "$network"
	}

	list_contains name wan && {
		list_contains network wan6 && return 0
		if [ -n "$(uci_get network wan6)" ]; then
			network="$network wan6"
			uci_set firewall "$1" network "$network"
		fi
	}

	if [ -z $(uci_get network tun) ]; then
		network="${network/tun/}"
		network="${network/  / }"
		uci_set firewall "$1" network "$network"
	fi
}

unique=""
remove_duplicates() {
	section="$1"
	config_get name "$1" name

	remove_by_name() {
		[ "$section" = "$2" ] && return
		for i in $unique; do
			[ "$i" = "$section" ] || [ "$i" = "$2" ] && return
		done
		config_get sname "$1" name
		[ "$sname" = "$3" ] && unique="$unique $2" && uci_remove firewall "$section"
	}

	config_foreach remove_by_name rule "$section" "$name"
}

rename_zone_openvpn() {
	local section="$1"
	local name
	local device

	config_get name "$section" name
	config_get device "$section" device

	[ "$name" = "vpn" ] && [ "$device" = "tun_+" ] || return

	uci_set "firewall" "$section" "name" "openvpn"
	uci_remove "firewall" "$section" "network"
}

rename_openvpn() {
	local section="$1"
	local src
	local dest

	config_get src "$section" src
	config_get dest "$section" dest

	[ "$src" = "vpn" ] && uci_set "firewall" "$section" "src" "openvpn"
	[ "$dest" = "vpn" ] && uci_set "firewall" "$section" "dest" "openvpn"
}


config_load firewall
config_foreach rename_zone_openvpn zone
config_foreach rename_openvpn redirect
config_foreach rename_openvpn forwarding
config_foreach add_forwarding zone
config_foreach add_missing_zone_options zone
config_foreach remove_duplicates rule
uci_commit firewall
