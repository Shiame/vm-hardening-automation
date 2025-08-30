#!/bin/bash

echo "=== [Audit] root and system accounts configuration ==="

echo
echo "Ensure root is the only UID 0 account"
awk -F: '($3 == 0) { print $1 }' /etc/passwd

echo
echo "==================================="
echo "Ensure root is the only GID 0 account"
awk -F: '($1 !~ /^(sync|shutdown|halt|operator)/ && $4=="0") {print
$1":"$4}' /etc/passwd


echo 
echo "==================================="
echo "Ensure group root is the only GID 0 group"
awk -F: '$3=="0"{print $1":"$3}' /etc/group

echo
echo "==================================="
echo "Ensure root password is set"
passwd -S root | awk '$2 ~ /^P/ {print "User: \"" $1 "\" Password is set"}'
echo "Audit output: $(passwd -S root)"

echo
echo "==================================="
echo "Ensure root path integrity"
{
 l_output2=""
 l_pmask="0022"
 l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"
 l_root_path="$(sudo -Hiu root env | grep '^PATH' | cut -d= -f2)"
 unset a_path_loc && IFS=":" read -ra a_path_loc <<< "$l_root_path"
 grep -q "::" <<< "$l_root_path" && l_output2="$l_output2\n - root's path 
contains a empty directory (::)"
 grep -Pq ":\h*$" <<< "$l_root_path" && l_output2="$l_output2\n - root's 
path contains a trailing (:)"
 grep -Pq '(\h+|:)\.(:|\h*$)' <<< "$l_root_path" && l_output2="$l_output2\n 
- root's path contains current working directory (.)"
 while read -r l_path; do
 if [ -d "$l_path" ]; then
 while read -r l_fmode l_fown; do
 [ "$l_fown" != "root" ] && l_output2="$l_output2\n - Directory: 
\"$l_path\" is owned by: \"$l_fown\" should be owned by \"root\""
 [ $(( $l_fmode & $l_pmask )) -gt 0 ] && l_output2="$l_output2\n -
Directory: \"$l_path\" is mode: \"$l_fmode\" and should be mode: 
\"$l_maxperm\" or more restrictive"
 done <<< "$(stat -Lc '%#a %U' "$l_path")"
 else
 l_output2="$l_output2\n - \"$l_path\" is not a directory"
 fi
 done <<< "$(printf "%s\n" "${a_path_loc[@]}")"
 if [ -z "$l_output2" ]; then
 echo -e "\n- Audit Result:\n *** PASS ***\n - Root's path is correctly 
configured\n"
 else
 echo -e "\n- Audit Result:\n ** FAIL **\n - * Reasons for audit 
failure * :\n$l_output2\n"
 fi
}

echo
echo "==================================="
echo "Ensure root user umask is configured"
output=$(grep -Psi -- '^\h*umask\h+(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b|[0-7][0-7][0-6]\b)|(u=[rwx]{1,3},)?(((g=[rx]?[rx]?w[rx]?[rx]?\b)(,o=[rwx]{1,3})?)|((g=[wrx]{1,3},)?o=[wrx]{1,3}\b)))' /root/.bash_profile /root/.bashrc)
if [ -z "$output" ]; then
	echo "[PASS] good umask is not set to an insecure value"
else
	echo "[WARN] umask is set to an insecure value"
fi


echo
echo "==================================="
echo "Ensure system accounts do not have a valid login shell"

# Build regex pattern of valid shells (excluding nologin)
l_valid_shells="^($(awk -F/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\/,g;p}' | paste -s -d '|' -))$"
# Capture system accounts with valid shells
result=$(awk -v pat="$l_valid_shells" -F: '
($1 !~ /^(root|halt|sync|shutdown|nfsnobody)$/ &&
 ($3 < '"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' || $3 == 65534) &&
 $7 ~ pat) {
    print "Service account: \"" $1 "\" has a valid shell: " $7
}' /etc/passwd)


if [ -z "$result" ]; then
    echo "[PASS] : All system accounts have non-login shells."
else
    echo "[FAIL] : The following system accounts have login shells:"
    echo "$result"
fi


echo
echo
echo "============================================="
echo "Ensure accounts without a valid login shell are locked"

# Build regex of valid shells (excluding nologin)
l_valid_shells="^($(awk -F/ '$NF != \"nologin\" {print}' /etc/shells | sed -rn '/^\//{s,/,\\/,g;p}' | paste -s -d '|' -))$"

# Find users without valid login shells and check if they are locked
awk -v pat="$l_valid_shells" -F: '($1 != "root" && $7 !~ pat) {print $1}' /etc/passwd | while read -r l_user; do
    if passwd -S "$l_user" | awk '$2 !~ /^L/'; then
        echo "Account \"$l_user\" does not have a valid login shell and is not locked"
    fi
done

