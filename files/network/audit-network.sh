#!/bin/bash

echo "3.1 [AUDIT] Configure Network Devices..."
echo

echo "[AUDIT] 3.1.1 Ensure IPv6 status is identified"
ipv6_all=$(sysctl net.ipv6.conf.all.disable_ipv6 | awk '{print $3}')
ipv6_default=$(sysctl net.ipv6.conf.default.disable_ipv6 | awk '{print $3}')
if [[ "$ipv6_all" == "1" && "$ipv6_default" == "1" ]]; then
    echo "[PASS] IPv6 is disabled"
else
    echo "[WARN] IPv6 is enabled or partially enabled"
    echo "net.ipv6.conf.all.disable_ipv6 = $ipv6_all"
    echo "net.ipv6.conf.default.disable_ipv6 = $ipv6_default"
fi
echo

echo "[AUDIT] 3.1.2 Ensure wireless interfaces are disabled"
iwconfig_output=$(iwconfig 2>&1)
if echo "$iwconfig_output" | grep -qi "no wireless extensions"; then
    echo "[PASS] No wireless interfaces detected"
else
    echo "[WARN] Wireless interfaces may be present"
    echo "$iwconfig_output"
fi
echo

echo "[AUDIT] 3.1.3 Ensure Bluetooth services are not in use"
if dpkg -l | grep -E 'bluez|bluetooth|blueman'; then
    echo "[WARN] Bluetooth package is installed"
else
    echo "[PASS] Bluetooth package is not installed"
fi

bt_enabled=$(systemctl is-enabled bluetooth 2>/dev/null)
bt_active=$(systemctl is-active bluetooth 2>/dev/null)
if [[ "$bt_enabled" == "disabled" && "$bt_active" == "inactive" ]]; then
    echo "[PASS] Bluetooth service is disabled and inactive"
else
    echo "[WARN] Bluetooth service is enabled or active"
    echo "Enabled: $bt_enabled"
    echo "Active: $bt_active"
fi
echo

echo "3.2 [AUDIT] Configure Network Kernel Modules..."
echo

for module in dccp tipc rds sctp; do
    echo "[AUDIT] 3.2.x Ensure $module kernel module is not available"

    if lsmod | grep -q "$module"; then
        echo "[FAIL] $module module is currently loaded"
    else
        echo "[PASS] $module module is not loaded"
    fi

    if modprobe -n -v "$module" | grep -q "/bin/false"; then
        echo "[PASS] $module is configured to not load (/bin/false)"
    else
        echo "[WARN] $module is not blocked via modprobe"
    fi

    if grep -r "$module" /etc/modprobe.d/ | grep -q "blacklist"; then
        echo "[PASS] $module is blacklisted"
    else
        echo "[WARN] $module is not blacklisted"
    fi
    echo
done
