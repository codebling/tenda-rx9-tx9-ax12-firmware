#!/bin/sh

. /lib/functions.sh

get_wan_ip() {
        wanip=`ubus call network.interface.wan status | jsonfilter -e '@["ipv4-address"][0].address'`
}

set_redirect_wanip_firewall() {
#config_set only save in memory, so use uci set to save date
        uci set firewall.$1.src_dip="$wanip"
}

set_firewall_wan_ip() {
        config_load firewall
        config_foreach set_redirect_wanip_firewall "redirect"
        uci commit
}

get_wan_ip
uci set firewall.rem_web.reload='1'
iptables -t nat -F prerouting_wan_rule
iptables -t nat -F prerouting_lan_rule
set_firewall_wan_ip
