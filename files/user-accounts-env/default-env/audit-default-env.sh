#!/bin/bash

echo "[AUDIT] ==== Configure user default environment ====="

echo
echo "5.4.3.1 Ensure nologin is not listed in /etc/shells"
output=$(grep '/nologin\b' /etc/shells)

if [ -z "$output" ]; then
    echo "[PASS] nologin is not listed in /etc/shells"
else
    echo "[FAIL] NOLOGIN is listed !!!"
fi

echo
echo "==============================================="
echo "5.4.3.2 Ensure default user shell timeout is configured"
output1=""
output2=""
[ -f /etc/bashrc ] && BRC="/etc/bashrc"
for f in "$BRC" /etc/profile /etc/profile.d/*.sh ; do
    grep -Pq '^\s*([^#]+\s+)?TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$f" &&
    grep -Pq '^\s*([^#]+;\s*)?readonly\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" &&
    grep -Pq '^\s*([^#]+;\s*)?export\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" &&
    output1="$f"
done

grep -Pq '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC" &&
output2=$(grep -Ps '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC")

if [ -n "$output1" ] && [ -z "$output2" ]; then
    echo -e "\nPASSED\n\nTMOUT is configured in: \"$output1\"\n"
else
    [ -z "$output1" ] && echo -e "\nFAILED\n\nTMOUT is not configured\n"
    [ -n "$output2" ] && echo -e "\nFAILED\n\nTMOUT is incorrectly configured in: \"$output2\"\n"
fi

echo
echo "============================================="
echo "5.4.3.3 Ensure default user umask is configured"
l_output=""
l_output2=""

file_umask_chk() {
    if grep -Psiq -- '^\h*umask\h+(0?[0-7][2-7]7|u(=[rwx]{0,3}),g=([rx]{0,2}),o=)(\h*#.*)?$' "$l_file"; then
        l_output="$l_output\n - umask is set correctly in \"$l_file\""
    elif grep -Psiq -- '^\h*umask\h+(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b|[0-7][0-7][0-6]\b)|(u=[rwx]{1,3},)?(((g=[rx]?[rx]?w[rx]?[rx]?\b)(,o=[rwx]{1,3})?)|((g=[wrx]{1,3},)?o=[wrx]{1,3}\b)))' "$l_file"; then
        l_output2="$l_output2\n - umask is incorrectly set in \"$l_file\""
    fi
}

while IFS= read -r -d $'\0' l_file; do
    file_umask_chk
done < <(find /etc/profile.d/ -type f -name '*.sh' -print0)

[ -z "$l_output" ] && l_file="/etc/profile" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/bashrc" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/bash.bashrc" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/pam.d/postlogin"

if [ -z "$l_output" ]; then
    if grep -Psiq -- '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(0?[0-7][2-7]7)\b' "$l_file"; then
        l_output1="$l_output1\n - umask is set correctly in \"$l_file\""
    elif grep -Psiq '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b))' "$l_file"; then
        l_output2="$l_output2\n - umask is incorrectly set in \"$l_file\""
    fi
fi

[ -z "$l_output" ] && l_file="/etc/login.defs" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/default/login" && file_umask_chk

[[ -z "$l_output" && -z "$l_output2" ]] && l_output2="$l_output2\n - umask is not set"

if [ -z "$l_output2" ]; then
    echo -e "\n- Audit Result:\n ** PASS **\n - * Correctly configured * :\n$l_output\n"
else
    echo -e "\n- Audit Result:\n ** FAIL **\n - * Reasons for audit failure * :\n$l_output2"
    [ -n "$l_output" ] && echo -e "\n- * Correctly configured * :\n$l_output\n"
fi

