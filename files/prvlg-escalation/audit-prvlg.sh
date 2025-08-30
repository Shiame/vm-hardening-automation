#!/bin/bash

echo "5.2 [AUDIT] Configure Privilege Escalation..."
echo

echo "[AUDIT] 5.2.1 Ensure sudo is installed"
if dpkg -l | grep -qw sudo; then
    echo "[PASS] sudo is installed"
else
    echo "[FAIL] sudo is NOT installed"
fi
echo

echo "[AUDIT] 5.2.2 Ensure sudo commands use PTY"
if grep -E '^Defaults\s+use_pty' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
    echo "[PASS] Defaults use_pty is set"
else
    echo "[FAIL] Defaults use_pty is NOT set"
fi
echo

echo "[AUDIT] 5.2.3 Ensure sudo log file exists"
if grep -E '^Defaults\s+logfile=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
    logfile=$(grep -E '^Defaults\s+logfile=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | head -n 1 | awk -F= '{gsub(/"/, "", $2); print $2}' | xargs)
    if [[ -f "$logfile" ]]; then
        echo "[PASS] sudo log file exists: $logfile"
    else
        echo "[FAIL] sudo log file path is set but file does not exist: $logfile"
    fi
else
    echo "[FAIL] sudo log file is NOT configured"
fi
echo

echo "[AUDIT] 5.2.4 Ensure users must provide password for sudo"
if grep -r NOPASSWD /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    echo "[FAIL] NOPASSWD entries found"
else
    echo "[PASS] All sudo commands require password"
fi
echo

echo "[AUDIT] 5.2.5 Ensure re-authentication is not disabled globally"
if grep -r '!authenticate' /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    echo "[FAIL] !authenticate found — re-authentication disabled"
else
    echo "[PASS] Re-authentication is enforced"
fi
echo

echo "[AUDIT] 5.2.6 Ensure sudo authentication timeout is configured"
if grep -E '^Defaults\s+timestamp_timeout=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
    timeout=$(grep -E '^Defaults\s+timestamp_timeout=' /etc/sudoers /etc/sudoers.d/* | awk -F= '{print $2}' | tr -d ' ')
    echo "[PASS] timestamp_timeout is set to $timeout minutes"
else
    echo "[WARN] timestamp_timeout is not explicitly set"
fi
echo

echo "[AUDIT] 5.2.7 Ensure access to su is restricted"
if grep -q pam_wheel.so /etc/pam.d/su; then
    echo "[PASS] su access is restricted via pam_wheel.so"
else
    echo "[FAIL] su access is NOT restricted"
fi
echo

