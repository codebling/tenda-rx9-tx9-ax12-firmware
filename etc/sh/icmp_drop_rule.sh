#!/bin/sh
uptime=`cat /proc/uptime | cut -d \. -f 1`
LOCKFILE=/tmp/icmp.lock
echo $uptime >>/tmp/test.tmp

rm_lock( )
{
   if [ -e $LOCKFILE ]
   then
       rm -f $LOCKFILE
   fi
}

do_icmp_dorp() {
	if [ $uptime -lt 50 ]; then
		if [ ! -f "/etc/config/wireless" ] ; then
			echo "icmp_drop_rule /etc/config/wireless is null"  >>/tmp/test.tmp
		fi
		
		local flag_2="0"
		local flag_5="0"
		local enable_2=`uci get wireless.radio0_0.disabled`
		local enable_5=`uci get wireless.radio1_0.disabled`
		local wlan0=`ifconfig | grep wlan0.1`
		local wlan1=`ifconfig | grep wlan2.1`
		[ "$enable_2" == "0" ] && {
			if [ -z "$wlan0" ]; then
				flag_2="1"
			fi
		}
		[ "$enable_5" == "0" ] && {
			if [ -z "$wlan1" ]; then
				flag_5="1"
			fi
		}
	
		([ "$flag_2" == "1" ] || [ "$flag_5" == "1" ]) && {
			iptables -w 3 -C input_rule -p icmp --icmp-type echo-request -j DROP || iptables -w 3 -A input_rule -p icmp --icmp-type echo-request -j DROP
		}
	fi
	rm_lock
}

while true
do
	if [ -e $LOCKFILE ] 
	then
		sleep 2
	else
		touch $LOCKFILE
		chmod 600 $LOCKFILE
		do_icmp_dorp
		exit 0
	fi
done
