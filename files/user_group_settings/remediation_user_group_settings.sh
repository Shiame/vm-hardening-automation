#!/bin/bash

echo "7.2 [REMEDIATION] Local User and Group Settings..."
echo

# 7.2.1 Ensure accounts use shadowed passwords
echo "[REMEDIATE] 7.2.1 Shadowed passwords"
awk -F: '($2 != "x") {print $1}' /etc/passwd | while read user; do
    echo "[FIX] Setting shadowed password for $user"
    usermod -p 'x' "$user"
done
echo

# 7.2.2 Ensure /etc/shadow password fields are not empty
echo "[REMEDIATE] 7.2.2 Empty password fields"
awk -F: '($2 == "") {print $1}' /etc/shadow | while read user; do
    echo "[FIX] Locking account with empty password: $user"
    passwd -l "$user"
done
echo

# 7.2.3 Ensure all groups in /etc/passwd exist in /etc/group
echo "[REMEDIATE] 7.2.3 Group consistency"
awk -F: '{print $4}' /etc/passwd | sort -u | while read gid; do
    if ! getent group "$gid" > /dev/null; then
        echo "[FIX] Creating missing group for GID $gid"
        groupadd -g "$gid" "group_$gid"
    fi
done
echo

# 7.2.4 Ensure shadow group is empty
echo "[REMEDIATE] 7.2.4 Shadow group membership"
members=$(grep ^shadow /etc/group | awk -F: '{print $4}')
if [ -n "$members" ]; then
    for user in $(echo "$members" | tr ',' ' '); do
        gpasswd -d "$user" shadow
        echo "[FIX] Removed $user from shadow group"
    done
else
    echo "[INFO] Shadow group already empty"
fi
echo
