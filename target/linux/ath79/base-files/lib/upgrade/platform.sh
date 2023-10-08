#
# Copyright (C) 2021 Teltonika
#

. /usr/share/libubox/jshn.sh

PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

# return values for validating RUT legacy firmware
lg_valid=0   # firmware is legacy and compatible
lg_invalid=1 # firmware is legacy and incompatible
lg_rutos=2   # firmware is not legacy, manifest validation is needed

# check RUT legacy firmwares
check_rut_legacy() {
	local file="$1"

	# grab and check label in header
	local l_offset=4
	local label="$(dd if="$file" bs=1 skip="$l_offset" count=9 2>/dev/null)"

	# this is not a legacy firmware
	[ "$label" != "Teltonika" ] && return "$lg_rutos"

	# grab and check model in header
	local m_offset=28
	local model="$(dd if="$file" bs=1 skip="$m_offset" count=4 2>/dev/null)"
	local board="$(mnf_info -n | cut -c -4)"

	# incompatible model
	[ "$model" != "$board" ] && return "$lg_invalid"

	# grab and check validation options
	local v_offset=60
	local valops="$(dd if="$file" bs=1 skip="$v_offset" count=4 2>/dev/null)"

	# check for metadata in the firmware
	[ "$(fwtool -q -i /dev/null $file; echo $?)" -ne 0 ] && {
		# all options should be set, otherwise image is incompatible
		[ "$valops" != "1111" ] && return "$lg_invalid"

		# this is firmware is confirmed to be legacy without metadata
		return "$lg_valid"
	}

	return "$lg_rutos"
}

# this hook runs before fwtool validation
platform_pre_check_image() {
	local stat="$(check_rut_legacy "$1"; echo $?)"

	case "$stat" in
	"$lg_valid")
		# skip metadata validation on legacy firmware
		REQUIRE_IMAGE_METADATA=0
		return 0
		;;
	"$lg_invalid")
		return 1
		;;
	"$lg_rutos")
		return 0
		;;
	esac
}

check_trb2_hw_mods() {
	local board="$1"

	[ "$board" != "TRB2" ] && return 0

	local ser_pid="$(cat /sys/bus/usb/devices/usb1/1-1/1-1.3/idProduct)"

	# ignore this validation if no FTDI is detected
	[ "$ser_pid" != "6001" ] && return 0

	local metadata="/tmp/sysupgrade.meta"
	local mod_ftdi_set=0

	[ -e "$metadata" ] || ( fwtool -q -i "$metadata" "$1" ) && {
		json_load_file "$metadata"

		if ( json_select hw_mods 1> /dev/null ); then
			json_select hw_mods
			json_get_values hw_mods

			echo "Mods found: $hw_mods"

			for mod in $hw_mods; do
				case "$mod" in
				"ftdi_new")
					mod_ftdi_set=1
					;;
				esac
			done
		fi
	}

	[ "$mod_ftdi_set" -eq 0 ] && {
		echo "FTDI serial chip detected but fw does not support it"
		return 1
	}

	return 0
}

check_rut_legacy_mg_modem() {
	local board="$1"
	local file="$2"
	local mg_v="05c6" mg_p="f601" # Meiglink SLM750

	[ "$board" != "RUT9" ] && [ "$board" != "RUT2" ] && return 0

	local stat="$(check_rut_legacy "$file"; echo $?)"

	# ignore this validation on RUTOS firmwares
	[ "$stat" -ne "$lg_valid" ] && return 0

	json_init
	json_load_file /etc/board.json
	json_get_keys modems modems
	json_select modems

	local vendor product

	for modem in $modems; do
		json_select "$modem"
		json_get_var builtin builtin

		[ "$builtin" != "1" ] && {
			continue
		}

		json_get_vars vendor product
		break
	done

	[ -z "$vendor" ] || [ -z "$product" ] && {
		echo "Unable to determine current modem model"
		return 1
	}

	# ignore this validation on non Meig modems
	[ "$vendor" != "$mg_v" ] && [ "$vendor" != "$mg_p" ] && return 0

	local m_offset

	case "$board" in
	RUT9)
		m_offset=59
		;;
	RUT2)
		m_offset=60
		;;
	esac

	# Meig support
	[ "$(dd if=$file bs=1 skip=$m_offset count=1 2>/dev/null)" != "1" ] && return 1

	return 0
}

platform_check_hw_support() {
	local board="$(mnf_info -n | cut -c -4)"

	check_trb2_hw_mods "$board" || return 1
	check_rut_legacy_mg_modem "$board" "$1" || return 1

	return 0
}

# this hook runs after fwtool validation
platform_check_image() {
	return 0
}
