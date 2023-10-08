#!/bin/sh

. /usr/share/libubox/jshn.sh

. /lib/functions.sh

[ -f "/etc/config/sim_idle_protection" ] || return 0

# Getting modem id
get_modem_id() {
	json_init
	json_load_file '/etc/board.json'
	json_get_keys modems modems
	json_select modems
	json_select 1
	json_get_vars id
	[ -z $id ] && return 0
}

# Changing sim_idle_protection config structure on RUTOS when upgrading from legacy FW
format_config() {
	uci_get="uci get sim_idle_protection.$1"

	position=$($uci_get | tail -c 2)
	enab=$($uci_get.enable)
	hour=$($uci_get.hour)
	min=$($uci_get.min)
	period=$($uci_get.period)
	host=$($uci_get.host)
	packet_size=$($uci_get.packet_size)
	count=$($uci_get.count)

	if [ "$period" = "month" ]; then
		day=$($uci_get.day)
		create_new_section $enab $hour $min $period $host $packet_size $count $position $day
	elif [ "$period" = "week" ]; then
		weekday=$($uci_get.weekday)
		create_new_section $enab $hour $min $period $host $packet_size $count $position $weekday
	fi

	uci delete sim_idle_protection.$1
}
# Creating new unnamed section
create_new_section() {
	uci_name=$(uci add sim_idle_protection sim_idle_protection)
	uci_set="uci set sim_idle_protection.$uci_name"

	$uci_set.enable=$1
	$uci_set.hour=$2
	$uci_set.min=$3
	$uci_set.period=$4
	$uci_set.host=$5
	$uci_set.packet_size=$6
	$uci_set.count=$7
	$uci_set.position=$8
	$uci_set.ip_type="ipv4"
	$uci_set.modem=$id

	if [ "$period" = "month" ]; then
		$uci_set.day=$9
	elif [ "$period" = "week" ]; then
		$uci_set.weekday=$9
	fi
}

get_modem_id

CARDS="sim1 sim2"

for SIM in $CARDS; do
	format_config $SIM
done

uci commit
return 0