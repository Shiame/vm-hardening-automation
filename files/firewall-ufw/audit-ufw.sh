#!/bin/bash

echo "[AUDIT] ==== Configure UncomplicatedFirewall - FIREWALL ====="

echo
echo "4.1.1 Ensure ufw is installed"
if dpkg-query -s ufw &>/dev/null; then
    echo "ufw is installed"
else
    echo "[FAIL] ufw is not installed"
fi

echo
echo "================================================="
echo "4.1.2 Ensure iptables-persistent is not installed with ufw"
if dpkg-query -s iptables-persistent &>/dev/null; then
    echo "[FAIL] iptables-persistent is installed, make sure you remove it."
else
    echo "iptables-persistent is not installed"
fi

echo
echo "================================================="
echo "4.1.3 Ensure ufw service is enabled"
echo "Enabled at boot:"
systemctl is-enabled ufw.service

echo "Currently active:"
systemctl is-active ufw

echo "UFW status:"
ufw status

echo
echo "================================================="
echo "4.1.4 Ensure ufw loopback traffic is configured"
ufw status verbose

echo
echo "================================================="
echo "4.1.5 Ensure ufw outbound connections are configured"
ufw status numbered

echo
echo "================================================="
echo "4.1.6 Ensure ufw firewall rules exist for all open ports"

# Collect UFW rule ports
unset a_ufwout a_openports a_diff
while read -r l_ufwport; do
    [ -n "$l_ufwport" ] && a_ufwout+=("$l_ufwport")
done < <(ufw status verbose | grep -Po '^\h*\d+\b' | sort -u)

# Collect open ports from system
while read -r l_openport; do
    [ -n "$l_openport" ] && a_openports+=("$l_openport")
done < <(ss -tuln | awk '($5!~/%lo:/ && $5!~/127.0.0.1:/ && $5!~/

\[?::1\]

?:/) {split($5, a, ":"); print a[2]}' | sort -u)

# Compare open ports vs UFW rules
a_diff=($(comm -23 <(printf '%s\n' "${a_openports[@]}" | sort) <(printf '%s\n' "${a_ufwout[@]}" | sort)))

echo
echo "Open ports detected on the system:"
printf '%s\n' "${a_openports[@]}"

echo
echo "UFW rule ports:"
printf '%s\n' "${a_ufwout[@]}"
echo

if [ ${#a_diff[@]} -gt 0 ]; then
    echo "[WARN] These open ports are not covered by UFW rules:"
    printf '%s\n' "${a_diff[@]}"
else
    echo "All open ports are covered by UFW rules."
fi


