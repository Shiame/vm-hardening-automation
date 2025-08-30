#!/bin/bash
echo "===================[REMEDIATION 5.3.3.2 - Password Quality Policies]==================="

FILE="/etc/security/pwquality.conf"
cp "$FILE" "${FILE}.bak_$(date +%F_%T)"

[ ! -d /etc/security/pwquality.conf.d/ ] && mkdir -p /etc/security/pwquality.conf.d/

# Consolidated single file
PWQ_FILE="/etc/security/pwquality.conf.d/99-pwquality.conf"
cat <<EOF > "$PWQ_FILE"
difok = 2
minlen = 14
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
dictcheck = 1
enforcing = 1
enforce_for_root
EOF

echo "All Password Quality parameters written to $PWQ_FILE"

# Update login.defs and user shadow settings as before
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 365/' /etc/login.defs || echo 'PASS_MAX_DAYS 365' >> /etc/login.defs
awk -F: '($2~/^\$.+\$/) {if($5 > 365 || $5 < 1) system("chage --maxdays 365 " $1)}' /etc/shadow
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/' /etc/login.defs || echo 'PASS_MIN_DAYS 1' >> /etc/login.defs
awk -F: '($2~/^\$.+\$/) {if($4 < 1) system("chage --mindays 1 " $1)}' /etc/shadow
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs || echo 'PASS_WARN_AGE 7' >> /etc/login.defs
awk -F: '($2~/^\$.+\$/) {if($6 < 7) system("chage --warndays 7 " $1)}' /etc/shadow
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD YESCRYPT/' /etc/login.defs || echo 'ENCRYPT_METHOD YESCRYPT' >> /etc/login.defs
useradd -D -f 45
awk -F: '($2~/^\$.+\$/) {if($7 > 45 || $7 < 0) system("chage --inactive 45 " $1)}' /etc/shadow

echo "Password quality and shadow policy remediations applied."

