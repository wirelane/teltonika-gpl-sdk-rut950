#!/bin/sh

# Process Reaper for Firmware Flashing (PRFF)
# This script provides utilities to manage services during the firmware flashing process.
# It can stop running services (excluding certain specified ones) and restore previously stopped services.

DIR="/etc/init.d"
OUTPUT_FILE="/tmp/killed_services"

# List of services to exclude from killing
EXCLUDE_SERVICES="\
boot \
dnsmasq \
done \
dropbear \
firewall \
gre_tunnel \
gsmd \
ipsec \
log \
mdcollectd \
mobifd \
multi_wifi \
mwan3 \
network \
odhcpd \
openvpn \
pptpd \
quota_limit \
rms_mqtt \
rpcd \
rut_fota \
sysctl \
sysfixtime \
sysntpd \
system \
uhttpd \
umount \
wpad \
xl2tpd \
tinc \
zerotier \
frr \
"

transform_excluded() {
    echo "$EXCLUDE_SERVICES" | tr '\n' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "    help      Show this help message."
    echo "    kill      Stop running services excluding those in EXCLUDE_SERVICES."
    echo "    restore   Restore previously killed services."
    echo "    stage2    Stop running services without any excludes."
}

kill_services() {
    local stage="$1"
    # Empty the OUTPUT_FILE to start fresh
    : > "$OUTPUT_FILE"

    # Transform excluded services list
    TRANSFORMED_EXCLUDE=$(transform_excluded)

    # Loop through the services in the directory
    for SERVICE_PATH in "$DIR"/*; do
        # Extract just the service name from the path
        SERVICE_NAME=$(basename "$SERVICE_PATH")

        # Check if the service is in the exclude list
        case " $TRANSFORMED_EXCLUDE " in
            *" $SERVICE_NAME "*)
                # Service is in the exclude list; skip it
                [ -n "$stage" ] || continue
                ;;
        esac

        # Check the status of the service
        STATUS=$("$DIR/$SERVICE_NAME" status)

        # If the service is running, kill it
        case "$STATUS" in
            *running*)
                "$DIR/$SERVICE_NAME" stop
                echo "Killed $SERVICE_NAME"

                # Save the killed service to the file
                echo "$SERVICE_NAME" >> "$OUTPUT_FILE"
                ;;
        esac
    done
}

# For restoration, loop through the killed services from the file and start them
restore_services() {
    while read -r SERVICE_NAME; do
        "$DIR/$SERVICE_NAME" start
        echo "Restored $SERVICE_NAME"
    done < "$OUTPUT_FILE"
}

# Check for script commands
case "$1" in
    "help")
        show_help
        ;;
    "kill")
        kill_services
        ;;
    "restore")
        restore_services
        ;;
    "stage2")
        kill_services stage2
        ;;
    *)
        show_help
        ;;
esac
