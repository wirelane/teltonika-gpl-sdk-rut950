#!/usr/bin/env bash
set -euo pipefail
SCRIPT_PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

BOOTLOADERS=(
"mips|rut2xx"
"mips|rut2xx-vboot"
"mips|rut2xx-vboot-64k"
"mips|rut300"
"mips|rut360"
"mips|rut9xx"
"mips|rut9xx-vboot"
"mips|rut9xx-vboot-64k"
"mips|rut952"
"mips|rut952-vboot"
"mips|rut952-vboot-64k"
"mips|tcr1xx"
"mips|trb24x"
"mipsel|rut14x"
"mipsel|rut2m"
"mipsel|rut301"
"mipsel|rut361"
"mipsel|rut9m"
"mipsel|tap100"
"mipsel|otd140"
)

for BOOTLOADER in "${BOOTLOADERS[@]}"; do
	export TMPL_ARCH="${BOOTLOADER%%|*}"
	export TMPL_BOOTLOADER="${BOOTLOADER##*|}"

	perl -p -e 's/\$\{\@([A-Z0-9_]+)\@\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < "${SCRIPT_PWD}/bootloader_ci_template.yml" > "${SCRIPT_PWD}/${TMPL_BOOTLOADER}.yml"
done
