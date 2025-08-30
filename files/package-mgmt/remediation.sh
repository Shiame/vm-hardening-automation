#!/bin/bash
echo "[REMEDIATION] 1.2.2.1 Install updates and security patches"
echo 

echo "[+] Updating package list ..."
apt update -y
echo

echo "[+] Upgrading installed packages ..."
apt upgrade -y
echo

echo "[+] Isntalling unattended-upgrades ..."
apt-get install -y unattended-upgrades
echo

echo "[+] Enabling unattended-upgrades services..."
#dpkg-reconfigure -plow unattended-upgrades
echo

echo "[+] remove unused packages ..."
apt-get autoremove -y

echo
echo "[DONE] The system is UP TO DATE"
echo
echo "[REMEDIATION] 1.2.3.X Ensure time synchronization is in use"
echo
if ! dpkg -s chrony >/dev/null 2>&1; then
  echo "[+] Installing chrony..."
  apt install -y chrony
fi
NTP_SERVERS=(
  "time-a-g.nist.gov iburst"
  "132.163.97.3 iburst"
  "time-d-b.nist.gov iburst"
)

CHRONY_CONF_FILE="/etc/chrony/chrony.conf"

#remove_any_existing_config
sed -i '/^\s*\(server\|pool\)\s\+/d' "$CHRONY_CONF_FILE"  

systemctl unmask chrony.service
systemctl --now enable chrony.service

echo "user _chrony" >> "$CHRONY_CONF_FILE"
for server in "${NTP_SERVERS[@]}"; do
	echo "server $server" >> "$CHRONY_CONF_FILE"
done

systemctl restart chronyd

echo "[INFO] Chrony configuration updated and service restarted."
