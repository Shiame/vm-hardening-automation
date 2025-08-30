#!/bin/bash

echo "[REMEDIATION] ==== Configure Server Services ====="
echo
echo "Proceeding to check and disable unnecessary services recommended by CIS Benchmarks:"
echo

# List of unnecessary server/client services according to CIS
server_services_to_disable=(
    autofs
    avahi-daemon
    isc-dhcp-server
    bind9
    dnsmasq
    vsftpd
    slapd
    dovecot
    nfs-kernel-server
    ypserv
    cups
    rpcbind
    rsync
    smbd
    snmpd
    tftpd-hpa
    squid
    apache2
    xinetd
)

disable_and_mask_service() {
    local service="$1"
    
    if dpkg-query -s "$service" &>/dev/null; then
        echo "[INFO] $service is installed"

        if systemctl is-enabled "$service" &>/dev/null; then
		systemctl stop "$service".service
                systemctl stop "$service".socket 2>/dev/null
		systemctl mask "$service".service
                systemctl mask "$service".socket 2>/dev/null
        fi

        if systemctl is-active "$service" &>/dev/null; then
            systemctl stop "$service"
        fi

        echo "[ACTION] Purging $service to reduce attack surface..."
        apt purge -y "$service"
	echo "$service is removeed"
    else
        echo "[OK] $service is not installed"
    fi

    echo
}

for service in "${server_services_to_disable[@]}"; do
    disable_and_mask_service "$service"
done

apt purge xserver-common
echo "xserver-commen service is removed"
echo "All unnecessary server services have been checked and remediated."
