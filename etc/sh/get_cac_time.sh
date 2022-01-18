#!/bin/sh

if [ $1 == -1 ];then
	uci -P /var/state/ set tdsch.wlan.cac_time=0
else
	uci -P /var/state/ set tdsch.wlan.cac_time=$1	
fi
