#!/bin/sh

if [ $1 == 1 ]; then
uci -P /var/state/ set tdsch.wlan.dfs=1
else
uci -P /var/state/ set tdsch.wlan.dfs=0
fi
