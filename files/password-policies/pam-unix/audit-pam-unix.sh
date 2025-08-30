#!/bin/bash

echo "=== [Audit] PAM unix Configuration ==="

# Check for pam_unix in common-*
echo "[Check] Is pam_unix.so used in active lines of /etc/pam.d/common-*?"
grep -PH '^\h*[^#\n\r]+\h+pam_unix\.so\b' /etc/pam.d/common-* >/dev/null && \
  echo "PASS: pam_unix is used" || \
  echo "FAIL: pam_unix is missing"

echo 
# 5.3.3.4.1 - Ensure pam_unix does not include nullok
echo "[Check] nullok option presence (should NOT be present)"
grep -PH -- '^\h*[^#\n\r]+\h+pam_unix\.so\b' /etc/pam.d/common-{password,auth,account,session,session-noninteractive} | \
grep -P '\bnullok\b' >/dev/null && \
  echo "FAIL: nullok is present (insecure)" || \
  echo "PASS: nullok is not present"

echo
# 5.3.3.4.2 - Ensure pam_unix does not include remember
echo "[Check] remember option presence (should NOT be present)"
grep -PH -- '^\h*[^#\n\r]+\h+pam_unix\.so\b' /etc/pam.d/common-{password,auth,account,session,session-noninteractive} | \
grep -P '\bremember=\d+\b' >/dev/null && \
  echo "FAIL: remember=<N> is present (misconfigured)" || \
  echo "PASS: remember is not present"

echo
# 5.3.3.4.3 - Ensure pam_unix includes a strong password hashing algorithm
echo "[Check] Strong password hashing algorithm (sha512 or yescrypt)"
grep -P '^\h*password\h+[^#\n\r]+\h+pam_unix\.so\h+.*\b(sha512|yescrypt)\b' /etc/pam.d/common-password >/dev/null && \
  echo "PASS: Strong hashing algorithm is configured" || \
  echo "FAIL: Strong hashing algorithm is missing"

echo
# 5.3.3.4.4 - Ensure pam_unix includes use_authtok
echo "[Check] use_authtok option presence"
grep -P '^\h*password\h+[^#\n\r]+\h+pam_unix\.so\h+.*\buse_authtok\b' /etc/pam.d/common-password >/dev/null && \
  echo "PASS: use_authtok is present" || \
  echo "FAIL: use_authtok is missing"
