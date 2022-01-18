#!/bin/sh

PBC_TIME=121
count=0

last_led_trigger=`cat /sys/class/leds/green_led/trigger  | cut -d "]" -f1 | cut -d "[" -f2-`
last_led_brightness=`cat /sys/class/leds/green_led/brightness`
[ "$last_led_trigger" == "timer" ] && {
	last_delay_off=`cat /sys/class/leds/green_led/delay_off`
	last_delay_on=`cat /sys/class/leds/green_led/delay_on`
}

start_led()
{
	echo "timer" > /sys/class/leds/green_led/trigger
	echo "200" > /sys/class/leds/green_led/delay_off
	echo "200" > /sys/class/leds/green_led/delay_on
}

stop_led()
{
	echo "$last_led_trigger" > /sys/class/leds/green_led/trigger
	case "$last_led_trigger" in
		"none")
			echo "$last_led_brightness" > /sys/class/leds/green_led/brightness
		;;
		"timer")
			echo "$last_delay_off" > /sys/class/leds/green_led/delay_off
			echo "$last_delay_on" > /sys/class/leds/green_led/delay_on
		;;
	esac
}

get_pbc_stats()
{
	pbc_status0=`hostapd_cli -i wlan0.1 wps_get_status | grep "PBC Status" | cut -d ":" -f2-`
	pbc_status1=`hostapd_cli -i wlan2.1 wps_get_status | grep "PBC Status" | cut -d ":" -f2-`
	last_result0=`hostapd_cli -i wlan0.1 wps_get_status | grep "Last WPS result" | cut -d ":" -f2-`
	last_result1=`hostapd_cli -i wlan2.1 wps_get_status | grep "Last WPS result" | cut -d ":" -f2-`

	pbc_status0=${pbc_status0// /}
	pbc_status1=${pbc_status1// /}
	last_result0=${last_result0// /}
	last_result1=${last_result1// /}

	if [ "$pbc_status0" == "Disabled" -a "$last_result0" == "Success" ];then
		echo "ok"
		return 1
	fi
	if [ "$pbc_status1" == "Disabled" -a "$last_result1" == "Success" ];then
		echo "ok"
		return 1
	fi

	echo "none"
	return 0
}

check_wps_onoff()
{
	status=`uci get wireless.radio0_0.wps_pushbutton`
	[ "$status" == "1" ] && return

	uci set wireless.radio0_0.wps_pushbutton=1
	uci set wireless.radio1_0.wps_pushbutton=1
	uci commit

	# replace wifi reload
	/etc/sh/restart_wifi
	sleep 10
}

start_wps()
{
	hostapd_cli -i wlan0.1 wps_pbc wlan0.1		
	hostapd_cli -i wlan2.1 wps_pbc wlan2.1
}

############################################################
[ -f "/tmp/start_wps_led" ] && exit 0

touch /tmp/start_wps_led

start_led
check_wps_onoff
start_wps

while [ $count -le $PBC_TIME ]
do
	sleep 1
	
	pbc_status=`get_pbc_stats`
	if [ "$pbc_status" == "ok" ];then
		break
	fi
	
	status0=`uci get wireless.radio0_0.wps_pushbutton`
	status1=`uci get wireless.radio1_0.wps_pushbutton`
	[ "$status0" == "0" -a "$status1" == "0" ] && break
	
	count=$(($count + 1))
done

stop_led
rm -fr /tmp/start_wps_led
