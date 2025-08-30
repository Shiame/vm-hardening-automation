#!/bin/bash

echo "3.1 [REMEDIATION] Configure Network Devices..."
echo

echo "[REMEDIATE] 3.1.1 Disable IPv6 (if not required)"
#sysctl_conf="/etc/sysctl.d/99-disable-ipv6.conf"
#echo "net.ipv6.conf.all.disable_ipv6 = 1" > "$sysctl_conf"
#echo "net.ipv6.conf.default.disable_ipv6 = 1" >> "$sysctl_conf"
#sysctl -p "$sysctl_conf"
#echo "[INFO] IPv6 disabled via $sysctl_conf"
echo

echo "[REMEDIATE] 3.1.2 Disable wireless interfaces"
for iface in $(ls /sys/class/net/ | grep -E '^wlan'); do
    ip link set "$iface" down
    echo "[INFO] Wireless interface $iface disabled"
done
echo

echo "[REMEDIATE] 3.1.3 Remove and disable Bluetooth"
sudo apt purge -y bluez-cups libbluetooth3 gnome-bluetooth-common libgnome-bluetooth-3.0-13 libgnome-bluetooth13 gir1.2-gnomebluetooth-3.0
echo "[INFO] Bluetooth package removed"
systemctl stop bluetooth 2>/dev/null
systemctl disable bluetooth 2>/dev/null
echo "[INFO] Bluetooth service stopped and disabled"
echo

echo "3.2 [REMEDIATION] Disable Network Kernel Modules..."
echo

for module in dccp tipc rds sctp; do
    modprobe_conf="/etc/modprobe.d/disable-${module}.conf"
    echo "install $module /bin/false" > "$modprobe_conf"
    echo "blacklist $module" >> "$modprobe_conf"
    echo "[INFO] Module $module blocked via $modprobe_conf"

    if lsmod | grep -q "$module"; then
        rmmod "$module"
        echo "[INFO] Module $module unloaded"
    fi
    echo
done

