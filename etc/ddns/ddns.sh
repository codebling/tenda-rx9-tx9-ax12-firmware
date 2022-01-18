#!/bin/sh

ddns_start() {
    ddns_stop
    #ap模式ddns退出不启动
    if [ `uci get network.lan.proto` == "dhcp" ] 
    then
        return
    fi

    if [ "$enable" == "0" ]
    then
        return;
    fi

    if [ "$srv_name" == "oray.com" ]
    then
        echo "szHost=phddns60.oray.net" >/tmp/phlinux_wan.conf
        echo "szUserID=$username" >>/tmp/phlinux_wan.conf
        echo "szUserPWD=$password">>/tmp/phlinux_wan.conf
        echo "nicName=$wan_name">>/tmp/phlinux_wan.conf
        echo "szLog=/var/log/phddns.log">>/tmp/phlinux_wan.conf
        
        /usr/bin/phddns -c /tmp/phlinux_wan.conf -d
        usleep 100;
        rm /var/log/phddns.log;
        return;
    fi

    if [ "$srv_name" == "88ip.cn" ]
    then
        /usr/bin/88ip $username $password $wan_name 1 1 &
        return;
    fi

    if [ "$srv_name" == "no-ip.com" ]
    then
        /usr/bin/inadyn -u $username -p $password -a $domain -I $wan_name -W 1 --dyndns_system  default@no-ip.com &
        return;
    fi

    if [ "$srv_name" == "dyn.com/dns" ]
    then
        /usr/bin/inadyn -u $username -p $password -a $domain -I $wan_name -W 1 --dyndns_system  dyndns@dyndns.org &
        return;
    fi
}

ddns_stop(){
    echo '0' >/etc/ddns_$wan_name
    if [ "$srv_name" == "oray.com" ]
    then
        ddns_pid=`cat /var/run/phddns_$wan_name.pid`
        if [ -n "$ddns_pid" ]
        then
            kill -9 $ddns_pid
            rm /tmp/phlinux_wan.conf /var/run/phddns_$wan_name.pid;
        fi
    else
        ddns_pid=`cat /etc/ddnspid1`
        if [ -n "$ddns_pid" ]
        then
            kill -9 $ddns_pid
            rm /etc/ddnspid1;
        fi
    fi
}

enable=`uci get advance.ddns.enable`
username=`uci get advance.ddns.username`
password=`uci get advance.ddns.password`
srv_name=`uci get advance.ddns.srv_name`
domain=`uci get advance.ddns.domain`
proto=`uci get network.wan.proto`

wan_name="eth1"
if [ "$proto" == "pppoe" ]
then 
wan_name="pppoe-wan"
fi

if [ "$1" == "start" ]
then
    ddns_start;
elif [ "$1" == "stop" ]
then
    ddns_stop;
elif [ "$1" == "restart" ]
then
    ddns_stop;
    ddns_start;
else
    echo "please input 'start' 'stop' or 'restart' "
fi