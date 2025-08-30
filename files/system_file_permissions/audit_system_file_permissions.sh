#!/bin/bash

echo "7.1 [AUDIT] System File Permissions..."
echo

audit_file() {
    local file="$1"
    local expected_perm="$2"
    local expected_owner="$3"
    local expected_group="$4"

    if [ -e "$file" ]; then
        actual_perm=$(stat -c "%a" "$file")
        actual_owner=$(stat -c "%U" "$file")
        actual_group=$(stat -c "%G" "$file")

        if [[ "$actual_perm" == "$expected_perm" && "$actual_owner" == "$expected_owner" && "$actual_group" == "$expected_group" ]]; then
            echo "[PASS] $file has correct permissions: $expected_perm, owner: $expected_owner, group: $expected_group"
        else
            echo "[FAIL] $file has permissions: $actual_perm, owner: $actual_owner, group: $actual_group (expected: $expected_perm/$expected_owner/$expected_group)"
        fi
    else
        echo "[WARN] $file does not exist"
    fi
    echo
}

# Core system files
audit_file /etc/passwd       644 root root
audit_file /etc/passwd-      644 root root
audit_file /etc/group        644 root root
audit_file /etc/group-       644 root root
audit_file /etc/shadow       640 root shadow
audit_file /etc/shadow-      640 root shadow
audit_file /etc/gshadow      640 root shadow
audit_file /etc/gshadow-     640 root shadow
audit_file /etc/shells       644 root root
audit_file /etc/security/opasswd 600 root root

