#!/bin/sh

attempts=3

echo " CE $1 ..." > /dev/console

FinishTestFlag=`uboot_env --get --name FinishTestFlag | sed -n 1p`
while [ "$FinishTestFlag" == "For enviornment CRC32 is not OK" ] && [ $attempts -gt 0 ] 
do
	rnd=`cat /proc/sys/kernel/random/uuid | md5sum | tr "[a-z]" "[0-9]" |cut -c 1 | tr -d '\n'`
	if [ $rnd -lt 2 ] ; then
		let rnd+=2
	fi
	echo " CE $1 uboot_env sleep $rnd" > /dev/console
	sleep $rnd
	FinishTestFlag=`uboot_env --get --name FinishTestFlag | sed -n 1p`
	let attempts-=1
	echo " CE $1 attempts=$attempts ..." > /dev/console
done
echo " CE $1 FinishTestFlag=$FinishTestFlag" > /dev/console


country_2_4=`cat /var/run/hostapd-phy0.conf | grep country_code | cut -d "=" -f2`
country_5=`cat /var/run/hostapd-phy1.conf | grep country_code | cut -d "=" -f2`
channel_5G=`uci get wireless.radio1.channel`
channel_5G_flag=`uci get advance.safety.channel_5G_flag`
htmode_5G=`uci get wireless.radio1.htmode`
htmode_normal_flag=`uci get advance.safety.htmode_normal_flag`
fastboot_flag=`uci get advance.safety.fast`
CE_mode=`uci get advance.safety.CE_mode`

if [ "$country_2_4" != "$country_5" ];then
    return
fi

if [ "$FinishTestFlag" == "parameter FinishTestFlag is not existed" ];then
    return
fi

echo " CE $1 go on" > /dev/console

case "$country_2_4" in  CN|US|MX|MY|HK|TW|TH|GB|DE|RO|PL|FR|ES|IT|RU|AU|AR|BR|IN|UZ|ZA|GE|CL|IQ|UY|CA)
    echo "CE country" ;;
    *)
    echo "other country" ;;
esac


wait_5G_ready()
{
    status=`hostapd_cli -i wlan2 status | grep "state=" | cut -d "=" -f2`
    while [ "$status" != "ENABLED" -a "$status" != "ACS_DONE" ]
    do
        status=`hostapd_cli -i wlan2 status | grep "state=" | cut -d "=" -f2`
        sleep 1
    done
}
wait_fastboot_finish()
{
    while [ "$fastboot_flag" == 1 ]
    do
        sleep 1
	fastboot_flag=`uci get advance.safety.fast`
    done 
}

if [ $1 == 1 ]; then

    [ "$CE_mode" == 0 ] && {
            return
    }
    
    wait_fastboot_finish
    echo "[CE 1]:finish fastboot" > /dev/console

    uci set advance.safety.CE_mode='0'
    uci commit advance

    if [ -z $(uci get advance.safety.txpower_2) ];then
      uci set wireless.radio0.txpower=100
      uci set wireless.radio1.txpower=100
    else
      uci set wireless.radio0.txpower=$(uci get advance.safety.txpower_2)
      uci set wireless.radio1.txpower=$(uci get advance.safety.txpower_5)
    fi   

    if [ "$channel_5G_flag" == 1 ];then
      uci set wireless.radio1.channel='auto'
    elif [ "$channel_5G_flag" == 0 ];then
      uci set wireless.radio1.channel=$(uci get advance.safety.channel)
    fi

    if [ "$htmode_normal_flag" == 1 ];then
        uci set wireless.radio1.htmode='VHT160'
    elif [ "$htmode_normal_flag" == 2 ];then
        uci set wireless.radio1.htmode='auto'
    else
        uci set wireless.radio1.htmode=$(uci get advance.safety.htmode)
            echo "not  auto or 160M bandwidth"
    fi

    uci commit

    wifi reload

elif [ $1 == 0 ];then

    [ "$fastboot_flag" == 1 ] && {
        uci set advance.safety.txpower_2=100
        uci set advance.safety.txpower_5=100
    }
    [ "$CE_mode" == 0 ] && {
        uci set advance.safety.txpower_2=$(uci get wireless.radio0.txpower)
        uci set advance.safety.txpower_5=$(uci get wireless.radio1.txpower)
    }

    uci set wireless.radio0.txpower='12'
    uci set wireless.radio1.txpower='12'

    [ "$fastboot_flag" == 1 ] && {
        uci set advance.safety.channel_5G_flag='1'
    } 

    [ "$CE_mode" == 0 ] && {
    if [ "$channel_5G" == "auto" ];then
        uci set advance.safety.channel_5G_flag='1'
        uci set wireless.radio1.channel='36'
    else
	uci set advance.safety.channel_5G_flag='0'
	uci set advance.safety.channel=$(uci get wireless.radio1.channel) 

    fi
    }	

    [ "$fastboot_flag" == 1 ] && {
        uci set advance.safety.htmode_normal_flag=2
    }

    [ "$CE_mode" == 0 ] && {
    if [ "$htmode_5G" == "VHT160" ];then
        uci set wireless.radio1.htmode='VHT80'
        uci set advance.safety.htmode_normal_flag=1
    elif [ "$htmode_5G" == "auto" ];then
          uci set wireless.radio1.htmode='VHT80'
          uci set advance.safety.htmode_normal_flag=2
        else
            uci set advance.safety.htmode_normal_flag=0
            uci set advance.safety.htmode=$(uci get wireless.radio1.htmode)
            echo "not  auto or 160M bandwidth"
    fi
    }
    uci set advance.safety.CE_mode='1'
    uci commit
else
	uci set advance.safety.channel_5G_flag='0'
	uci set advance.safety.channel=$(uci get wireless.radio1.channel)
	uci set advance.safety.htmode_normal_flag=0
	uci set advance.safety.htmode=$(uci get wireless.radio1.htmode)
	uci commit
fi
