#!/bin/bash

echo
echo "[AUDIT] ==== Configure Client Services ====="

echo
echo "Proceed to check if all the client services recommended to be disabled by CIS benchmarks are disabled : "
echo

client_services_to_disable=(
    nis
    rsh-client 
    talk 
    telnet 
    ldap-utils 
    ftp 
)

check_client_service() {
        local service=$1

        if dpkg-query -s "$service" &>/dev/null; then
            echo "[INFO] $service is installed, need to be uninstalled !!"
       else
            echo "[OK] $service is not installed"
       fi

       echo
}

for service in "${client_services_to_disable[@]}"; do
        check_client_service "$service"
done
