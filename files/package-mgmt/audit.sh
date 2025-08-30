#!/bin/bash

echo "1.2 [AUDIT] package management..."

echo 
echo "[AUDIT] 1.2.1.1 Ensure GPG keys are configured ... "

key_list=$(apt-key list 2>/dev/null)

if [[ -z "$key_list" ]]; then
	echo "[FAIL] NO GPG keys found"
	exit 1
else 
	echo "[PASS]"
fi 

#-----------------------------

echo
echo "[AUDIT] 1.2.1.2 Ensure package repositories are configured..."

repos=$(apt-cache policy | grep http)

if [[ -z "$repos" ]]; then
	echo "[FAIL] NO HTTP/HTTPS repos found"
elif echo "$repos" | grep -q -E "cdrom:|file:"; then
	echo "[FAIL] Insecure repo detected"
	echo "$repos"
else
	echo "[PASS] repos are properly configued"
fi 

#-------------------------------

echo 
echo "[AUDIT] 1.2.2.1 Ensure updates, patches ..."

echo "[INFO] updating packages index ..."
apt-get update -qq > /dev/null

echo "[INFO] checking for upgradable packages ..."
upgrade=$(apt-get -s upgrade | grep "^Inst")

if [[ -z "$upgrade" ]]; then
	echo "[PASS] System is up to date"
else 
	echo "[INFO] Pending packages upgrades detected"
	echo "$upgrade"
fi

echo

echo "[AUDIT] Checking if unattended-upgrades is installed..."
if dpkg -l | grep -qw unattended-upgrades; then
	echo "[PASS] the services is installed"
else 
	echo "[FAIL] NOT installed"
fi


echo "[AUDIT] Check if Chrony is well configured"
systemctl is-active chrony.service
systemctl is-enabled chrony.service

./audit-chrony.sh
