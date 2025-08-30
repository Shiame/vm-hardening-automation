#!/bin/bash
echo "[AUDIT] Ensure password quality and requirements are configured ..."
echo

echo "[AUDIT] Ensure latest version of pam is installed..."
dpkg-query -s libpam-runtime | grep -P -- '^(Status|Version)\b'

echo "[AUDIT] Ensure latest version of libpam-modules is installed..."
dpkg-query -s libpam-pwquality | grep -P -- '^(Status|Version)\b'

echo "-----------------------------------------------------------"
echo
echo "[AUDIT] Check pam_pwquality is enabled ..."
grep -P -- '\bpam_pwquality\.so\b' /etc/pam.d/common-password >/dev/null
if [ $? -eq 0 ]; then
    echo "pam_pwquality.so is configured"
else
    echo "pam_pwquality is NOT found /etc/pam.d/common-password"
fi

echo
echo -e "\n====== [AUDIT] 5.3.3.2 Password Quality Policies ======"
echo

grep -Psi -- '^\h*difok\h*=\h*([2-9]|[1-9][0-9]+)\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf
[ $? -eq 0 ] && echo "difok => 2 found" || echo "difok => 2 not found, proceed to remediation"
echo

grep -Psi -- '^\h*minlen\h*=\h*(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,})\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf
[ $? -eq 0 ] && echo "minlen >=14 found" || echo "minlen >=14 not found, proceed to remediation"
echo

grep -Psi -- '^\h*dcredit\h*=\h*-1\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf
[ $? -eq 0 ] && echo "dcredit = -1 found" || echo "dcredit=-1 not found, proceed to remediation"
echo

grep -Psi -- '^\h*ucredit\h*=\h*-1\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf
[ $? -eq 0 ] && echo "ucredit = -1 found" || echo "ucredit = -1 not found, proceed to remediation"
echo

grep -Psi -- '^\h*ocredit\h*=\h*-1\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf
[ $? -eq 0 ] && echo "ocredit = -1 found" || echo "ocredit = -1 not found, proceed to remediation"
echo

grep -Psi -- '^\h*lcredit\h*=\h*-1\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf
[ $? -eq 0 ] && echo "lcredit = -1 found" || echo "lcredit = -1 not found, proceed to remediation"
echo

grep -E '^(dictcheck|enforcing|enforce_for_root)' /etc/security/pwquality.conf
grep -Psi -- '^\h*dictcheck\h*=\h*1\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf

