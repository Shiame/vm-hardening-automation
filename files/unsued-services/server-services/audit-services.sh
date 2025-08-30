#!/bin/bash

echo "[AUDIT] ==== Configure Server Services ====="

echo 
echo "Proceed to check if all the services recommended to be disabled by CIS benchmarks are disabled : "
echo

server_services_to_disable=(
	autofs
	avahi-daemon
	idc-dhcp-server
	bind9
	dnsmasq
	vsftpd
	slapd
        dovecot-imapd
        dovecot-pop3d
	nfs-kernel-server
	ypserv
	cups
	rpcbind
	rsync
	samba
	snmpd
	tftpd-hpa
	squid
	apache2
	xinedtd
	xserver-common
)
check_server_service() {
	local service=$1

        if dpkg-query -s "$service" &>/dev/null; then
            echo "[INFO] $service is installed"

            if systemctl is-enabled "$service" &>/dev/null; then
               echo "[WARNING] $service is enabled - disable it !"
            fi

            if systemctl is-active "$service" &>/dev/null; then
               echo "[WARNING] $service is active - stop it !"
            fi

       else
            echo "[OK] $service is not installed"
       fi

       echo
}



for service in "${server_services_to_disable[@]}"; do
	check_server_service "$service"
done
