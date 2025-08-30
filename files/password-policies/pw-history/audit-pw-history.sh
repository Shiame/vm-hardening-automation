#!/bin/bash

echo "=== [Audit] PAM pwhistory Configuration ==="

# Check for pam_pwhistory in common-password
echo "[Check] Is pam_pwhistory.so used in /etc/pam.d/common-password?"
grep -P '^\h*password\h+(requisite|required|sufficient)\h+pam_pwhistory\.so' /etc/pam.d/common-password >/dev/null && \
  echo "PASS: pam_pwhistory is used" || \
  echo "FAIL: pam_pwhistory is missing"

echo
# Check remember value (should be >= 5)
echo "[Check] remember value in pam_pwhistory line (>=5)"
grep -P 'pam_pwhistory\.so.*remember=\s*([5-9]|[1-9][0-9]+)' /etc/pam.d/common-password >/dev/null && \
  echo "PASS: remember value is compliant (>=5)" || \
  echo "FAIL: remember value is missing or <5"

echo
# Check if enforce_for_root is included
echo "[Check] enforce_for_root option presence"
grep -P 'pam_pwhistory\.so.*enforce_for_root' /etc/pam.d/common-password >/dev/null && \
  echo "PASS: enforce_for_root is present" || \
  echo "FAIL: enforce_for_root is missing"

echo
# Check if use_authtok is enabled 	
echo "[Audit] Check if pam_pwhistory includes use_authtok"
grep -Psi -- '^\h*password\h+[^#\n\r]+\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?use_authtok\b' /etc/pam.d/common-password \
    && echo "Pass: use_authtok is present " \
    || echo "WARN: use_authtok not present "

