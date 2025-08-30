#!/bin/bash

echo "[REMEDIATION] ==== Configure Client Services ====="
echo
echo "Proceeding to check and disable unnecessary client services recommended by CIS Benchmarks:"
echo

client_services_to_disable=(
    nis
    rsh-client 
    talk 
    telnet 
    ldap-utils 
    ftp 
)

disable_and_mask_service() {
    local service="$1"

    if dpkg-query -s "$service" &>/dev/null; then
        echo "[INFO] $service is installed"

        echo "[ACTION] Purging $service ..."
        apt purge -y "$service"
        echo "$service is removeed"
    else
        echo "[OK] $service is not installed"
    fi

    echo
}

for service in "${client_services_to_disable[@]}"; do
    disable_and_mask_service "$service"
done
echo "All unnecessary client services have been checked and remediated."

