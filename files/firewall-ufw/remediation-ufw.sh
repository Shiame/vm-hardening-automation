#!/bin/bash

echo "[REMEDIATE] ==== Apply Firewall Configuration - UFW ====="

# ---------------------------------------
# 4.1.1 Install UFW if not present
# ---------------------------------------
if ! dpkg-query -s ufw &>/dev/null; then
    echo "UFW not found. Installing..."
    apt update && apt install -y ufw
    echo "UFW installed."
else
    echo "UFW already installed."
fi

# ---------------------------------------
# 4.1.2 Remove iptables-persistent if installed
# ---------------------------------------
if dpkg-query -s iptables-persistent &>/dev/null; then
    echo "Removing iptables-persistent..."
    apt purge -y iptables-persistent
    echo "iptables-persistent removed."
else
    echo "iptables-persistent not installed."
fi

# ---------------------------------------
# 4.1.3 Enable and start UFW service
# ---------------------------------------
echo "Enabling UFW service..."
systemctl unmask ufw.service
systemctl enable --now ufw.service
ufw --force enable
echo "UFW service enabled and started."

# ---------------------------------------
# 4.1.4 Apply default-deny policies
# ---------------------------------------
echo "Applying default-deny policies..."
ufw default deny incoming
ufw default deny outgoing
ufw default deny routed

# ---------------------------------------
# 4.1.5 Allow essential traffic
# ---------------------------------------
echo "Allowing SSH (port 22)..."
ufw allow 22/tcp
ufw allow out to any port 53 proto udp   # DNS
ufw allow out to any port 80 proto tcp   # HTTP
ufw allow out to any port 443 proto tcp  # HTTPS
echo "Allowing loopback traffic..."
ufw allow in on lo
ufw allow out on lo
ufw deny in from 127.0.0.0/8
ufw deny in from ::1


# ---------------------------------------
# 4.1.6 Reload UFW and display status
# ---------------------------------------
echo "Reloading UFW to apply changes..."
ufw reload

echo
echo "UFW configuration complete. Current status:"
ufw status verbose
