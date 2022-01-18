#!/bin/sh

country_2_4=`cat /var/run/hostapd-phy0.conf | grep country_code | cut -d "=" -f2`
country_5=`cat /var/run/hostapd-phy1.conf | grep country_code | cut -d "=" -f2`

if [ "$country_2_4" != "$country_5" ];then
return
fi

case "$country_2_4" in  CN|US|MX|HK|TW|TH|UK|DE|RO|PL|FR|ES|IT|RU|BR)
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

if [ $1 == 1 ]; then
        uci set wireless.radio0.txpower='100'
        uci set wireless.radio1.channel='auto'
        uci set wireless.radio1.txpower='100'
        wifi reload
else
        uci set wireless.radio0.txpower='12'
        uci set wireless.radio1.txpower='12'
        uci set wireless.radio1.channel='149'
        uci set advance.safety.CE_mode='1'
        uci commit
fi

