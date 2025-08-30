#!/bin/bash

#!/bin/bash

echo "=== [Remediation] PAM pam_unix.so Configuration ==="

cp -r /etc/pam.d /etc/pam.d.bak

echo
echo "Make sure pam_unix is enabled"
DEBIAN_FRONTEND=noninteractive PAM_AUTOMATIC=yes pam-auth-update --enable unix

echo
# 5.3.3.4.1 - Remove 'nullok' from pam_unix.so
echo "[Fix] Removing 'nullok' from pam_unix.so lines..."
grep -PH -- 'pam_unix\.so.*\bnullok\b' /usr/share/pam-configs/* | cut -d: -f1 | sort -u | while read -r file; do
  sed -i 's/\bnullok\b//g' "$file"
  echo "Edited: $file"
done

echo
# 5.3.3.4.2 - Remove 'remember=<N>' from pam_unix.so
echo "[Fix] Removing 'remember=<N>' from pam_unix.so lines..."
grep -PH -- 'pam_unix\.so.*\bremember=\d+\b' /usr/share/pam-configs/* | cut -d: -f1 | sort -u | while read -r file; do
  sed -i 's/\bremember=[0-9]\+\b//g' "$file"
  echo "Edited: $file"
done

echo
# 5.3.3.4.3 - Ensure strong password hashing algorithm (sha512 or yescrypt)
echo "[Fix] Ensuring strong password hashing algorithm (sha512 or yescrypt)..."
grep -qP 'pam_unix\.so.*\b(sha512|yescrypt)\b' /etc/pam.d/common-password || {
  sed -i '/pam_unix\.so/ s/$/ sha512/' /etc/pam.d/common-password
  echo "Updated hashing algorithm in: /etc/pam.d/common-password"
}

echo
# 5.3.3.4.4 - Ensure 'use_authtok' is present
echo "[Fix] Ensuring 'use_authtok' is present..."
grep -qP 'pam_unix\.so.*\buse_authtok\b' /etc/pam.d/common-password || {
  sed -i '/pam_unix\.so/ s/$/ use_authtok/' /etc/pam.d/common-password
  echo "Added 'use_authtok' to: /etc/pam.d/common-password"
}

echo
echo "update the files in the /etc/pam.d/ directory"
DEBIAN_FRONTEND=noninteractive PAM_AUTOMATIC=yes pam-auth-update --force
echo
echo "=== Remediation Complete ==="

