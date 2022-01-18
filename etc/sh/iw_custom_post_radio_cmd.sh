#!/bin/sh
. /lib/functions.sh

mac80211_custom_post_radio() {
	local ifname="$1"

	iw dev $ifname iwlwav sFastDrop 0

	phy=`cat /sys/class/net/$ifname/phy80211/name`
	iw phy "$phy" info | grep -q '2412 MHz' && {
		iw dev $ifname iwlwav sCcaTh -50 -50 -50 -50 -50
	}
	iw phy "$phy" info | grep -q '5180 MHz' && {
		iw dev $ifname iwlwav sCcaTh -50 -50 -50 -50 -50
		/etc/init.d/bandsteering restart
	}
	iw dev $ifname iwlwav sBfMode 4
}

iw_ofdma_power_on_set() {

        [ -z `uci get system.@system[0].ofdma`]&& return
                         
        local ofdma=`uci get system.@system[0].ofdma`   

        if [ "$ofdma" == "1" ]                                                              
        then                                                   
          iw wlan2 iwlwav sDynamicMu 1 0 4 4 2                 
        else                                                                                                                 
          iw wlan2 iwlwav sDynamicMu 0 0 4 4 2
        fi
}

#iw_ofdma_power_on_set
mac80211_custom_post_radio $1
