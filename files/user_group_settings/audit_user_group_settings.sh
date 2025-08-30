#!/bin/bash

echo "7.2 [AUDIT] Local User and Group Settings..."
echo

# 7.2.1 Ensure accounts in /etc/passwd use shadowed passwords
echo "[AUDIT] 7.2.1 Shadowed passwords"
if awk -F: '($2 != "x") {print $1}' /etc/passwd | grep -q .; then
    echo "[FAIL] Some accounts in /etc/passwd do not use shadowed passwords"
else
    echo "[PASS] All accounts use shadowed passwords"
fi
echo

# 7.2.2 Ensure /etc/shadow password fields are not empty
echo "[AUDIT] 7.2.2 Empty password fields"
if awk -F: '($2 == "" ) {print $1}' /etc/shadow | grep -q .; then
    echo "[FAIL] Some accounts have empty password fields"
else
    echo "[PASS] No empty password fields in /etc/shadow"
fi
echo

# 7.2.3 Ensure all groups in /etc/passwd exist in /etc/group
echo "[AUDIT] 7.2.3 Group consistency"
missing_gid=0
awk -F: '{print $4}' /etc/passwd | sort -u | while read -r gid; do
    if ! getent group "$gid" > /dev/null; then
        echo "[FAIL] GID $gid from /etc/passwd not found in /etc/group"
        missing_gid=1
    fi
done

# Wait for the while loop to finish in subshell
wait
if [ "$missing_gid" -eq 0 ]; then
    echo "[PASS] All groups referenced in /etc/passwd exist in /etc/group"
fi
echo

# 7.2.4 Ensure shadow group is empty
echo "[AUDIT] 7.2.4 Shadow group membership"
shadow_members=$(grep ^shadow /etc/group | awk -F: '{print $4}')
if [ -z "$shadow_members" ]; then
    echo "[PASS] Shadow group is empty"
else
    echo "[FAIL] Shadow group has members: $shadow_members"
fi
echo

# 7.2.5–7.2.8 Ensure no duplicate UIDs, GIDs, usernames, or group names
echo "[AUDIT] 7.2.5–7.2.8 Duplicate checks"
awk -F: '{print $3}' /etc/passwd | sort | uniq -d | grep -q . && echo "[FAIL] Duplicate UIDs found" || echo "[PASS] No duplicate UIDs"
awk -F: '{print $3}' /etc/group | sort | uniq -d | grep -q . && echo "[FAIL] Duplicate GIDs found" || echo "[PASS] No duplicate GIDs"
awk -F: '{print $1}' /etc/passwd | sort | uniq -d | grep -q . && echo "[FAIL] Duplicate usernames found" || echo "[PASS] No duplicate usernames"
awk -F: '{print $1}' /etc/group | sort | uniq -d | grep -q . && echo "[FAIL] Duplicate group names found" || echo "[PASS] No duplicate group names"
echo

