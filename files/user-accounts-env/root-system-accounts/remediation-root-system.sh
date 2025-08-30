#!/bin/bash

echo "=== [Remediation] root and system accounts configuration ==="

echo
echo "Ensure root is the only UID 0 account"
for user in $(awk -F: '($3 == 0) { print $1 }' /etc/passwd); do
	if [ "$user" != "root" ]; then
		echo "Remediating UID 0 for user: $user"
		sudo usermod -u 1001 "$user";
	else 
		sudo usermod -u 0 root
	fi
done 


echo
echo "=============================================="
echo "Ensure root is the only GID 0 account"
sudo usermod -g 0 root
sudo groupmod -g 0 root
awk -F: '($1 !~ /^(root|sync|shutdown|halt|operator)/ && $4=="0") {print $1}' /etc/passwd | while read -r user; do
    echo "Remediating GID 0 for user: $user"
    sudo usermod -g 1001 "$user"
done


echo
echo "==============================================="
echo "Ensure group root is the only GID 0 group"
sudo groupmod -g 0 root

for grp in $(awk -F: '($3 == 0) {print $1}' /etc/group); do
        if [ "$grp" != "root" ]; then
                echo "Remediating GID 0 for root group: $grp"
                sudo groupmod -g 1003 "$grp";
        fi
done

echo
echo "==============================================="
echo "Ensure root user umask is configured"
sed -i '/umask/s/^/# /' /root/.bash_profile
sed -i '/umask/s/^/# /' /root/.bashrc
echo 'umask 0027' >> /root/.bash_profile
echo 'umask 0027' >> /root/.bashrc


echo
echo "==============================================="
echo "Ensure system accounts do not have a valid login shell"
# Get all login shells except "nologin"
l_valid_shells="^($(awk -F/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\/,g;p}' | paste -s -d '|' -))$"

# Loop through accounts and update them
nologin_shell="$(command -v nologin)"
uid_min=$(awk '/^\s*UID_MIN/ {print $2}' /etc/login.defs)

awk -v nologin="$nologin_shell" -v uid_min="$uid_min" -F: '
($1 !~ /^(root|halt|sync|shutdown|nfsnobody)$/ &&
($3 < uid_min || $3 == 65534) &&
$7 != nologin) {
    printf("Changing shell for user %s to %s\n", $1, nologin);
    system("usermod -s " nologin " " $1)
}
' /etc/passwd

echo 
echo "==============================================="
echo "Ensure accounts without a valid login shell are locked"
#l_valid_shells="^($(awk -F/ '$NF != \"nologin\" {print}' /etc/shells | sed -rn '/^\//{s,/,\\/,g;p}' | paste -s -d '|' -))$"

#awk -v pat="$l_valid_shells" -F: '($1 != "root" && $7 !~ pat) {print $1}' /etc/passwd | while read -r l_user; do
    #if passwd -S "$l_user" | awk '$2 !~ /^L/'; then
        #echo "Locking user: $l_user"
        #usermod -L "$l_user"
    #fi
#done

