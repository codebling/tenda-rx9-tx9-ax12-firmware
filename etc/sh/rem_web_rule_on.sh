#!/bin/sh
d_ip=`uci get network.lan.ipaddr`
rem_ip=`uci get advance.remweb.ip`
rem_port=`uci get advance.remweb.port`
wan_ip=`ubus call network.interface.wan status | jsonfilter -e '@["ipv4-address"][0].address'`
isp_type=`uci get network.wan.ispType`

if [ "$rem_ip" == "0.0.0.0" ]
then
        rem_ip="0.0.0.0/0"
fi

echo $rem_port >/proc/ppa/api/tenda_port_filter
iptables -w 3 -I input_rule -d $d_ip -p tcp --dport 80 -j ACCEPT
iptables -w 3 -t nat -I prerouting_wan_rule -j DNAT -s $rem_ip -d $wan_ip -p tcp --dport $rem_port --to-destination $d_ip:80
iptables -w 3 -t nat -I prerouting_lan_rule -j DNAT -s $rem_ip -d $wan_ip -p tcp --dport $rem_port --to-destination $d_ip:80

if [ "$isp_type" == "5" ]
then
        wan2_ip=`ubus call network.interface.wan2 status | jsonfilter -e '@["ipv4-address"][0].address'`
        iptables -w 3 -t nat -I prerouting_wan_rule -j DNAT -s $rem_ip -d $wan2_ip -p tcp --dport $rem_port --to-destination $d_ip:80
        iptables -w 3 -t nat -I prerouting_lan_rule -j DNAT -s $rem_ip -d $wan2_ip -p tcp --dport $rem_port --to-destination $d_ip:80
fi