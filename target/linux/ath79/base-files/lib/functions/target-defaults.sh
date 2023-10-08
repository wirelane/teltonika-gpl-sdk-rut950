#!/bin/ash

boot_target_post_uci_defaults() {
	[ -f "/etc/config/teltonika" ] && rm /etc/config/teltonika
}
