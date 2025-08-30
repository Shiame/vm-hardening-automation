#!/bin/bash

echo " Verifying if pam_faillock is enabled ...."
result=$(grep -P -- '\bpam_faillock\.so\b' /etc/pam.d/common-{auth,account})
if [[ -z "$result" ]]; then
  echo "pam_faillock is NOT properly configured."
  exit 1
else
  echo "pam_faillock is properly configured:"
fi


echo "=== [Audit] PAM FailLock Configuration ==="

# 5.3.3.1.1 – Check 'deny' setting in faillock.conf
echo "[Check] deny setting in /etc/security/faillock.conf"
grep -Pi -- '^\h*deny\h*=\h*[1-5]\b' /etc/security/faillock.conf >/dev/null && \
  echo "PASS: deny value in faillock.conf is valid (<=5)" || \
  echo "FAIL: deny value in faillock.conf is missing or >5"

echo "[Check] deny setting in /etc/pam.d/common-auth"
grep -Pi -- '^\hauth\h+(requisite|required|sufficient)\h+pam_faillock\.so\h+([^#\n\r]+\h+)?deny\h*=\h*(0|[6-9]|[1-9][0-9]+)\b' /etc/pam.d/common-auth && \
  echo "FAIL: pam_faillock.so line in common-auth has invalid deny value" || \
  echo "PASS: No invalid pam_faillock.so deny value in common-auth"
echo
# 5.3.3.1.2 – Check 'unlock_time' setting
echo "[Check] unlock_time in /etc/security/faillock.conf"
grep -Pi -- '^\h*unlock_time\h*=\h*(0|9[0-9][0-9]|[1-9][0-9]{3,})\b' /etc/security/faillock.conf >/dev/null && \
  echo "PASS: unlock_time is valid in faillock.conf" || \
  echo "FAIL: unlock_time is missing or too low"

echo "[Check] unlock_time hardcoded in common-auth"
grep -Pi -- '^\hauth.*pam_faillock\.so.*unlock_time=' /etc/pam.d/common-auth && \
  echo "FAIL: unlock_time should not be hardcoded in common-auth" || \
  echo "PASS: unlock_time not hardcoded in common-auth"
echo
# 5.3.3.1.3 – Check root lockout settings
echo "[Check] Root lockout settings in faillock.conf"
grep -Pi -- '^\h*(even_deny_root|root_unlock_time\h*=\h*\d+)\b' /etc/security/faillock.conf && \
  echo "PASS: Root lockout settings present" || \
  echo "FAIL: Root lockout settings missing"

echo "[Check] root_unlock_time value safety"
grep -Pi -- '^\hroot_unlock_time\h=\h*([1-9]|[1-5][0-9])\b' /etc/security/faillock.conf && \
  echo "FAIL: root_unlock_time is too low (< 60)" || \
  echo "PASS: root_unlock_time is safe (>=60)"

echo "[Check] root_unlock_time hardcoded in common-auth"
grep -Pi -- '^\hauth.*pam_faillock\.so.*root_unlock_time\h*=\h*([1-9]|[1-5][0-9])\b' /etc/pam.d/common-auth && \
  echo "FAIL: root_unlock_time hardcoded in common-auth" || \
  echo "PASS: root_unlock_time not hardcoded in common-auth"

