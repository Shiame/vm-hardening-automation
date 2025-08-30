#!/bin/bash

echo "5.2 [REMEDIATION] Configure Privilege Escalation..."
echo

echo "[REMEDIATE] 5.2.1 Ensure sudo is installed"
if ! dpkg -l | grep -qw sudo; then
    apt install -y sudo
    echo "[INFO] sudo installed"
else
    echo "[INFO] sudo already installed"
fi
echo

echo "[REMEDIATE] 5.2.2 Ensure sudo commands use PTY"
if ! grep -qE '^Defaults\s+use_pty' /etc/sudoers; then
    echo "Defaults use_pty" >> /etc/sudoers
    echo "[INFO] Added 'Defaults use_pty' to /etc/sudoers"
else
    echo "[INFO] 'Defaults use_pty' already set"
fi
echo

echo "[REMEDIATE] 5.2.3 Ensure sudo log file exists"
if ! grep -qE '^Defaults\s+logfile=' /etc/sudoers; then
    echo "Defaults logfile=\"/var/log/sudo.log\"" >> /etc/sudoers
    touch /var/log/sudo.log
    chmod 0600 /var/log/sudo.log
    chown root:root /var/log/sudo.log
    echo "[INFO] Configured sudo logfile at /var/log/sudo.log"
else
    echo "[INFO] Sudo logfile already configured"
fi
echo

echo "[REMEDIATE] 5.2.4 Ensure users must provide password for sudo"
if grep -r NOPASSWD /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    sed -i 's/NOPASSWD:/PASSWD:/g' /etc/sudoers /etc/sudoers.d/*
    echo "[INFO] Removed NOPASSWD entries"
else
    echo "[INFO] No NOPASSWD entries found"
fi
echo

echo "[REMEDIATE] 5.2.5 Ensure re-authentication is not disabled globally"
if grep -r '!authenticate' /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    sed -i 's/!authenticate//g' /etc/sudoers /etc/sudoers.d/*
    echo "[INFO] Removed '!authenticate' entries"
else
    echo "[INFO] No '!authenticate' entries found"
fi
echo

echo "[REMEDIATE] 5.2.6 Configure sudo authentication timeout"
if ! grep -qE '^Defaults\s+timestamp_timeout=' /etc/sudoers; then
    echo "Defaults timestamp_timeout=15" >> /etc/sudoers
    echo "[INFO] Set sudo authentication timeout to 15 minutes"
else
    echo "[INFO] timestamp_timeout already configured"
fi
echo

echo "[REMEDIATE] 5.2.7 Restrict access to su command"
if ! grep -q pam_wheel.so /etc/pam.d/su; then
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su
    echo "[INFO] Added pam_wheel.so to /etc/pam.d/su"
fi

if ! getent group wheel >/dev/null; then
    groupadd wheel
    echo "[INFO] Created 'wheel' group"
fi

usermod -aG wheel root
echo "[INFO] Added root to wheel group"
echo

