#!/bin/sh
# Copyright (C) 2006-2011 OpenWrt.org

if ( ! grep -qsE '^root:[!x]?:' /etc/shadow || \
     ! grep -qsE '^root:[!x]?:' /etc/passwd ) && \
   [ -z "$FAILSAFE" ]
then
#	echo "Login failed."
#	exit 0
  exec /bin/login
else
cat << EOF
 === IMPORTANT ============================
  Use 'passwd' to set your login password!
 ------------------------------------------
EOF
fi

exec /bin/ash --login
