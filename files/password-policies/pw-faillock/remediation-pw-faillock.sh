#!/bin/bash

echo "Remediation: Enabling pam_faillock module for brute-force protection"
# Step 1: Create /usr/share/pam-configs/faillock
echo "[+] Creating profile: faillock (deny after failed attempts)"
{
  arr=('Name: Enable pam_faillock to deny access'
       'Default: yes'
       'Priority: 0'
       'Auth-Type: Primary'
       'Auth:'
       ' [default=die] pam_faillock.so authfail')
  printf '%s\n' "${arr[@]}" > /usr/share/pam-configs/faillock
}

# Step 2: Create /usr/share/pam-configs/faillock_notify
echo "[+] Creating profile: faillock_notify (notify and reset on success)"
{
  arr=('Name: Notify of failed login attempts and reset count upon success'
       'Default: yes'
       'Priority: 1024'
       'Auth-Type: Primary'
       'Auth:'
       ' requisite pam_faillock.so preauth'
       'Account-Type: Primary'
       'Account:'
       ' required pam_faillock.so')
  printf '%s\n' "${arr[@]}" > /usr/share/pam-configs/faillock_notify
}

# Step 3: Enable both profiles
echo "[+] Enabling faillock profiles using pam-auth-update"
DEBIAN_FRONTEND=noninteractive PAM_AUTOMATIC=yes pam-auth-update --enable faillock --enable faillock_notify --force

# Step 4: Configure faillock options in /etc/security/faillock.conf
echo "[+] Setting faillock parameters in /etc/security/faillock.conf"

{
  echo "deny = 5"              # Maximum failed attempts before lock
  echo "unlock_time = 900"     # Lock time in seconds (15 minutes)
  echo "fail_interval = 900"   # Time window for counting failed attempts
  echo "root_unlock_time = 900" # Same protection for root
} > /etc/security/faillock.conf
echo
echo
echo "[+] Removing hardcoded faillock options from pam-config profiles..."
# Remove deny option
for file in $(grep -Pl -- '\bpam_faillock\.so\h+([^#\n\r]+\h+)?deny\b' /usr/share/pam-configs/*); do
    sed -i 's/\(\bpam_faillock\.so[^\n\r#]*\)deny=[^ \t]*/\1/g' "$file"
done

# Remove unlock_time option
for file in $(grep -Pl -- '\bpam_faillock\.so.*unlock_time\b' /usr/share/pam-configs/*); do
    sed -i 's/\(\bpam_faillock\.so[^\n\r#]*\)unlock_time=[^ \t]*/\1/g' "$file"
done

# Remove even_deny_root and root_unlock_time
for file in $(grep -Pl '\bpam_faillock\.so\h+([^#\n\r]+\h+)?(even_deny_root|root_unlock_time)' /usr/share/pam-configs/*); do
    sed -i 's/\(\bpam_faillock\.so[^\n\r#]*\)\(even_deny_root\|root_unlock_time=[^ \t]*\)//g' "$file"
done

echo
echo "[+] Regenerating PAM configuration..."
DEBIAN_FRONTEND=noninteractive PAM_AUTOMATIC=yes pam-auth-update --force

echo "pam_faillock remediation fully complete."


