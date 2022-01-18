#!/bin/sh
. /lib/functions/uci-defaults.sh
. /lib/functions/system.sh
append DRIVERS "mac80211"

lookup_phy() {
	[ -n "$phy" ] && {
		[ -d /sys/class/ieee80211/$phy ] && return
	}

	local devpath
	config_get devpath "$device" path
	[ -n "$devpath" ] && {
		for phy in $(ls /sys/class/ieee80211 2>/dev/null); do
			case "$(readlink -f /sys/class/ieee80211/$phy/device)" in
				*$devpath) return;;
			esac
		done
	}

	local macaddr="$(config_get "$device" macaddr | tr 'A-Z' 'a-z')"
	[ -n "$macaddr" ] && {
		for _phy in /sys/class/ieee80211/*; do
			[ -e "$_phy" ] || continue

			[ "$macaddr" = "$(cat ${_phy}/macaddress)" ] || continue
			phy="${_phy##*/}"
			return
		done
	}
	phy=
	return
}

find_mac80211_phy() {
	local device="$1"

	config_get phy "$device" phy
	lookup_phy
	[ -n "$phy" -a -d "/sys/class/ieee80211/$phy" ] || {
		echo "PHY for wifi device $1 not found"
		return 1
	}
	config_set "$device" phy "$phy"

	config_get macaddr "$device" macaddr
	[ -z "$macaddr" ] && {
		config_set "$device" macaddr "$(cat /sys/class/ieee80211/${phy}/macaddress)"
	}

	return 0
}

check_mac80211_device() {
	config_get phy "$1" phy
	[ -z "$phy" ] && {
		find_mac80211_phy "$1" >/dev/null || return 0
		config_get phy "$1" phy
	}
	[ "$phy" = "$dev" ] && found=1
}

detect_mac80211() {
	devidx=0
	config_load wireless
	while :; do
		config_get type "radio$devidx" type
		[ -n "$type" ] || break
		devidx=$(($devidx + 1))
	done
	
	wps_pin=$(strings /dev/mtdblock2 | sed -n 's/^'"pin_code"'=//p')
	[ -z "$wps_pin" ] &&{
		wps_pin=34090527
	}
	
	lan_mac=$(mtd_get_mac_ascii ubootconfigA ethaddr)
	[ -z "$lan_mac" ] && {
		lan_mac=00:90:4C:88:88:88
	}
	
	SUFFIX=`echo ${lan_mac#*:*:*:} | sed 's/://g' | tr [a-z] [A-Z]`
	macaddr=$(macaddr_add "$lan_mac" 2 )
	for _dev in /sys/class/ieee80211/*; do
		[ -e "$_dev" ] || continue

		dev="${_dev##*/}"

		found=0
		config_foreach check_mac80211_device wifi-device
		[ "$found" -gt 0 ] && continue

		mode_band="bgnax"		
		channel="7"
		htmode=""
		ht_capab=""
		phymac=$macaddr
		#SUFFIX=`echo ${macaddr#*:*:*:} | sed 's/://g'`
		hostmac=$(macaddr_add "$phymac" 1)
		guestmac=$(macaddr_add "$phymac" 2)
		repeatermac=$(macaddr_add "$phymac" 2)
		ifaceidx=0
		ifname=1
		iw phy "$dev" info | grep -q 'Capabilities:' && htmode="HT40+"

		iw phy "$dev" info | grep -q '5180 MHz' && {
			mode_band="anacax"
			channel="149"
			band="5"
			doth="set wireless.radio${devidx}.doth=0"
			acs_fallback_chan='36 40 80'
			ifaceidx=2
			ifname=3
			iw phy "$dev" info | grep -q 'VHT Capabilities' && htmode="VHT80"
			limit_main="set wireless.radio${devidx}_0.maxassoc=32"
		        limit_guest="set wireless.radio${devidx}_1.maxassoc=32"
		}||{
			#obbs_interval="set wireless.radio${devidx}.obss_interval=0"
			#ignore_40mhz="set wireless.radio${devidx}.ignore_40_mhz_intolerant=1"
			acs_fallback_chan='1 5 40'
		}
		
		[ -n "$htmode" ] && ht_capab="set wireless.radio${devidx}.htmode=$htmode"

		if [ -x /usr/bin/readlink -a -h /sys/class/ieee80211/${dev} ]; then
			path="$(readlink -f /sys/class/ieee80211/${dev}/device)"
		else
			path=""
		fi
		if [ -n "$path" ]; then
			path="${path##/sys/devices/}"
			case "$path" in
				platform*/pci*) path="${path##platform/}";;
			esac
			dev_id="set wireless.radio${devidx}.path='$path'"
		else
			dev_id="set wireless.radio${devidx}.macaddr=$(cat /sys/class/ieee80211/${dev}/macaddress)"
		fi
		
		set_uuid="$(uci get wireless.radio0_0.wps_uuid)"
		[ -z "$set_uuid" ] && {
			set_uuid="$(uci get wireless.radio1_0.wps_uuid)"
		}
		[ -z "$set_uuid" ] && {
			set_uuid="87654321-9abc-def0-5678-70f9e65c2508"
			uuid="$(cat /proc/sys/kernel/random/uuid | md5sum | cut -c 1-12)"
			[ -z "$uuid" ] || {
				set_uuid="87654321-9abc-def0-5678-${uuid}"
			}
		}
		
		uci -q batch <<-EOF
			set wireless.radio${devidx}=wifi-device
			set wireless.radio${devidx}.phy=${dev}
			set wireless.radio${devidx}.type=mac80211
			set wireless.radio${devidx}.band=${band:-2.4}GHz
			set wireless.radio${devidx}.channel=${channel:-auto}
			set wireless.radio${devidx}.hwmode=11${mode_band}
			set wireless.radio${devidx}.macaddr=${phymac}
			${ht_capab}
			set wireless.radio${devidx}.disabled=0
			set wireless.radio${devidx}.country=CN
			set wireless.radio${devidx}.acs_fallback_chan="${acs_fallback_chan}"
			set wireless.radio${devidx}.beacon_int=100
			${doth}
			set wireless.radio${devidx}.short_gi_20=1
			set wireless.radio${devidx}.short_gi_40=1
			set wireless.radio${devidx}.txpower=100
			set wireless.radio${devidx}.acs_scan_mode=1
			${obbs_interval}
			${ignore_40mhz}
			set wireless.radio${devidx}.sDisableMasterVap=1
			set wireless.radio${devidx}.full_ch_master_control=0
			set wireless.radio${devidx}.current_rssi=-100
			

			set wireless.default_radio${band:-24}G=wifi-iface
			set wireless.default_radio${band:-24}G.device=radio${devidx}
			set wireless.default_radio${band:-24}G.network=lan
			set wireless.default_radio${band:-24}G.mode=ap
			set wireless.default_radio${band:-24}G.ssid=dump_ssid${band:+_5G}
			set wireless.default_radio${band:-24}G.ifname=wlan${ifaceidx}
			set wireless.default_radio${band:-24}G.encryption=none
			set wireless.default_radio${band:-24}G.macaddr=${phymac}
			set wireless.default_radio${band:-24}G.hidden=0			
			set wireless.default_radio${band:-24}G.max_inactivity=60
			set wireless.default_radio${band:-24}G.wps_pushbutton=0
						
			set wireless.radio${devidx}_0=wifi-iface
			set wireless.radio${devidx}_0.device=radio${devidx}
			set wireless.radio${devidx}_0.network=lan
			set wireless.radio${devidx}_0.mode=ap
			set wireless.radio${devidx}_0.ssid=Tenda_${SUFFIX}${band:+_5G}
			set wireless.radio${devidx}_0.ifname=wlan${ifaceidx}.1
			set wireless.radio${devidx}_0.macaddr=${hostmac}
			set wireless.radio${devidx}_0.hidden=0			
			set wireless.radio${devidx}_0.max_inactivity=60
			set wireless.radio${devidx}_0.wmm=1
			set wireless.radio${devidx}_0.uapsd=1
			set wireless.radio${devidx}_0.maxassoc=128
			set wireless.radio${devidx}_0.isolate=0
			set wireless.radio${devidx}_0.encryption=none
			set wireless.radio${devidx}_0.wpa_group_rekey=43200
			set wireless.radio${devidx}_0.ieee80211w=0
			set wireless.radio${devidx}_0.macfilter=Disabled
			set wireless.radio${devidx}_0.wps_pushbutton=1
			set wireless.radio${devidx}_0.wps_uuid=${set_uuid}
			set wireless.radio${devidx}_0.wps_pin=${wps_pin}
			set wireless.radio${devidx}_0.sreliablemcast=1
			set wireless.radio${devidx}_0.disabled=0
			set wireless.radio${devidx}_0.acs_bg_scan_do_switch=1
			set wireless.radio${devidx}_0.dtim_period=1
			set wireless.radio${devidx}_0.s11nProtection=1
			
			set wireless.radio${devidx}_1=wifi-iface
			set wireless.radio${devidx}_1.device=radio${devidx}
			set wireless.radio${devidx}_1.network=guest
			set wireless.radio${devidx}_1.mode=ap
			set wireless.radio${devidx}_1.ssid=Tenda_VIP${band:+_5G}
			set wireless.radio${devidx}_1.ifname=wlan${ifaceidx}.2
			set wireless.radio${devidx}_1.macaddr=${guestmac}
			set wireless.radio${devidx}_1.hidden=0			
			set wireless.radio${devidx}_1.max_inactivity=60
			set wireless.radio${devidx}_1.wmm=1
			set wireless.radio${devidx}_1.uapsd=1
			set wireless.radio${devidx}_1.maxassoc=128
			set wireless.radio${devidx}_1.isolate=0
			set wireless.radio${devidx}_1.encryption=none
			set wireless.radio${devidx}_1.wpa_group_rekey=43200
			set wireless.radio${devidx}_1.ieee80211w=0
			set wireless.radio${devidx}_1.macfilter=Disabled
			set wireless.radio${devidx}_1.wps_pushbutton=0
			set wireless.radio${devidx}_1.disabled=1
			set wireless.radio${devidx}_1.expire=480
			set wireless.radio${devidx}_1.dtim_period=1
			set wireless.radio${devidx}_1.s11nProtection=1
			${limit_main}
			${limit_guest}
			
			set wireless.radio${devidx}_2=wifi-iface
			set wireless.radio${devidx}_2.device=radio${devidx}
			set wireless.radio${devidx}_2.mode=sta
			set wireless.radio${devidx}_2.ifname=wlan${ifname}
			set wireless.radio${devidx}_2.macaddr=${repeatermac}
			set wireless.radio${devidx}_2.encryption=none
			set wireless.radio${devidx}_2.ieee80211w=0
			set wireless.radio${devidx}_2.disabled=1
			set wireless.radio${devidx}_2.repeater_mode=ap
			
EOF
		uci -q commit wireless

		devidx=$(($devidx + 1))
		macaddr=$(macaddr_add "$phymac" 3)
	done
}
