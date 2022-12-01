#!/bin/sh
. /lib/functions.sh
LOCKFILE=/tmp/icmp.lock

wireless_iptv_cmd () {
	local section="$1"
	local ifname
	local sreliablemcast
	config_get ifname "$section" "ifname"
	[ -z "$ifname" ] && return
	config_get sreliablemcast "$section" "sreliablemcast"
	[ -z "$sreliablemcast" ] && return

	if [ "$2" = "$ifname" ];then
			iw $ifname iwlwav sReliableMcast $sreliablemcast
	fi
}

tc_ifb_add_wlan() {
	local ifname="$1"
	local guest_qos=`uci get qos.param.guest_enable`
	local list=`cat /etc/config/qos | grep device_rule`
	local workmode=`uci get network.lan.proto`
	 
	#guest
	[ "$ifname" == "wlan0.2" ] || [ "$ifname" == "wlan2.2" ] && [ "$guest_qos" == "1" ] && [ "$workmode" == "static" ]  && {
		tc qdisc del dev $ifname root handle 1: htb
		tc qdisc add dev $ifname root handle 1: htb
		tc filter add dev $ifname parent 1: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
	}
	#wireless
	[ "$ifname" == "wlan0.1" ] || [ "$ifname" == "wlan2.1" ] &&  [ "$workmode" == "static" ]  && {
		if [ -n "$list" ]; then
			tc qdisc del dev $ifname root handle 1: htb
			tc qdisc add dev $ifname root handle 1: htb
			tc filter add dev $ifname parent 1: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb1
		fi
	}
}


mac80211_custom_post_vif() {
	local ifname="$1"
		
	config_load wireless
	config_foreach wireless_iptv_cmd "wifi-iface" "$ifname"
}

rm_lock( )
{
   if [ -e $LOCKFILE ]
   then
       rm -f $LOCKFILE
   fi
}

ate_icmp_accept_opt() {
	local ifname="$1"
	local enable_2=`uci get wireless.radio0_0.disabled`
	local enable_5=`uci get wireless.radio1_0.disabled`
	local wlan0=`ifconfig | grep wlan0.1`
	local wlan1=`ifconfig | grep wlan2.1`
	
	[ "$ifname" == "wlan0.1" ] && [ "$enable_5" == "1" ] && {
		iptables -w 3 -D input_rule -p icmp --icmp-type echo-request -j DROP
		rm_lock
		return
	}	
	[ "$ifname" == "wlan0.1" ] && [ -n "$wlan1" ] && {
		iptables -w 3 -D input_rule -p icmp --icmp-type echo-request -j DROP
		rm_lock
		return
	}	
	[ "$ifname" == "wlan2.1" ] && [ "$enable_2" == "1" ] && {
		iptables -w 3 -D input_rule -p icmp --icmp-type echo-request -j DROP
		rm_lock
		return
	}	
	[ "$ifname" == "wlan2.1" ] && [ -n "$wlan0" ] && {
		iptables -w 3 -D input_rule -p icmp --icmp-type echo-request -j DROP
		rm_lock
		return
	}
	rm_lock
}

ate_icmp_accept() {
	while true
	do
		if [ -e $LOCKFILE ] 
		then
			sleep 2
		else
			touch $LOCKFILE
			chmod 600 $LOCKFILE
			ate_icmp_accept_opt $1
			exit 0	
		fi
	done	
}

add_wlan_interface(){
	radio0_2_disabled=`uci get wireless.radio0_2.disabled`
	radio1_2_disabled=`uci get wireless.radio1_2.disabled`
	 [ "$radio0_2_disabled" == "0" ] && {
		echo add wlan1 >/proc/l2nat/dev
	 }
	 [ "$radio1_2_disabled" == "0" ] && {
		echo add wlan3 >/proc/l2nat/dev
	 }
}
tc_ifb_add_wlan $1
mac80211_custom_post_vif $1
#add_wlan_interface
#ate_icmp_accept $1
