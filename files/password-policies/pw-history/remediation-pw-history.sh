#!/bin/bash

PROFILE_FILE="/usr/share/pam-configs/pwhistory"
COMMON_PASSWORD="/etc/pam.d/common-password"

# Check if pam_pwhistory profile exists
if ! grep -qP -- '\bpam_pwhistory\.so\b' "$PROFILE_FILE"; then
  echo "[+] Creating pam_pwhistory profile..."
  cat <<EOF > "$PROFILE_FILE"
Name: pwhistory password history checking
Default: yes
Priority: 1024
Password-Type: Primary
Password:
    requisite pam_pwhistory.so remember=24 enforce_for_root use_authtok
EOF
else
  echo "[+] pam_pwhistory profile already exists. Updating options..."
  sed -i 's|^.*pam_pwhistory\.so.*$|    requisite pam_pwhistory.so remember=24 enforce_for_root use_authtok|' "$PROFILE_FILE"
fi

# Enable the pwhistory module using pam-auth-update
echo "[+] Enabling pam_pwhistory profile with pam-auth-update..."
DEBIAN_FRONTEND=noninteractive pam-auth-update --enable pwhistory --force

# Confirm the line is now present in common-password
if grep -qP '^\s*password\s+requisite\s+pam_pwhistory\.so\b' "$COMMON_PASSWORD"; then
  echo "[✓] pam_pwhistory module successfully enabled and configured in $COMMON_PASSWORD"
else
  echo "[✗] Something went wrong: pam_pwhistory not found in $COMMON_PASSWORD"
  exit 1
fi

