#!/bin/bash

echo "7.1 [REMEDIATION] System File Permissions..."
echo

remediate_file() {
    local file="$1"
    local expected_perm="$2"
    local expected_owner="$3"
    local expected_group="$4"

    if [ -e "$file" ]; then
        chmod "$expected_perm" "$file"
        chown "$expected_owner:$expected_group" "$file"
        echo "[FIXED] $file set to $expected_perm, owner: $expected_owner, group: $expected_group"
    else
        echo "[SKIPPED] $file does not exist"
    fi
    echo
}

# Core system files
remediate_file /etc/passwd       644 root root
remediate_file /etc/passwd-      644 root root
remediate_file /etc/group        644 root root
remediate_file /etc/group-       644 root root
remediate_file /etc/shadow       640 root shadow
remediate_file /etc/shadow-      640 root shadow
remediate_file /etc/gshadow      640 root shadow
remediate_file /etc/gshadow-     640 root shadow
remediate_file /etc/shells       644 root root
remediate_file /etc/security/opasswd 600 root root

