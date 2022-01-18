#!/bin/sh

#!/bin/sh

interface=$1

if [ $interface == "wlan2" ];then
      sta_num=`hostapd_cli -i wlan2 status | grep "num_sta\[[1-8]\]" | cut -d "=" -f2 |awk '{sum+=$1} END {print sum}'`
      status=`hostapd_cli -i wlan2.1 status | grep "state=" | cut -d "=" -f2`
      mode=`uci get wireless.radio1.channel`
fi

if [ $interface == "wlan0" ];then
        sta_num=`hostapd_cli -i wlan0 status | grep "num_sta\[[1-8]\]" | cut -d "=" -f2 | awk '{sum+=$1} END {print sum}'`
        status=`hostapd_cli -i wlan0.1 status | grep "state=" | cut -d "=" -f2`
        mode=`uci get wireless.radio0.channel`
fi

if [ "$mode" != "auto"  ];then
        return;
fi

if [ $sta_num != 0 ];then
        return;
fi

if [ "$status" == "ENABLED" ] || [ "$status" == "ACS_DONE" ];then
        iw dev $interface scan ap-force passive > /dev/null &
	if [ "$interface" == "wlan0" ];then
		sleep 15
	fi
fi
