. /lib/functions/network.sh
if [ -f /lib/netifd/debug_infrastructure.sh ]; then
	. /lib/netifd/debug_infrastructure.sh
fi

wpa_supplicant_add_rate() {
	local var="$1"
	local val="$(($2 / 1000))"
	local sub="$((($2 / 100) % 10))"
	append $var "$val" ","
	[ $sub -gt 0 ] && append $var "."
}

hostapd_add_rate() {
	local var="$1"
	local val="$(($2 / 100))"
	append $var "$val" " "
}

hostapd_append_wep_key() {
	local var="$1"

	wep_keyidx=0
	set_default key 1
	case "$key" in
		[1234])
			for idx in 1 2 3 4; do
				local zidx
				zidx=$(($idx - 1))
				json_get_var ckey "key${idx}"
				[ -n "$ckey" ] && \
					append $var "wep_key${zidx}=$(prepare_key_wep "$ckey")" "$N$T"
			done
			wep_keyidx=$((key - 1))
		;;
		*)
			append $var "wep_key0=$(prepare_key_wep "$key")" "$N$T"
		;;
	esac
}

hostapd_append_wpa_key_mgmt() {
	local auth_type_l="$(echo $auth_type | tr 'a-z' 'A-Z')"

	case "$auth_type" in
		psk|eap)
			[ "${ieee80211w:-0}" -ne 2 ] && append wpa_key_mgmt "WPA-$auth_type_l"
			[ "${ieee80211r:-0}" -gt 0 ] && append wpa_key_mgmt "FT-${auth_type_l}"
			[ "${ieee80211w:-0}" -gt 1 ] && append wpa_key_mgmt "WPA-${auth_type_l}-SHA256"
		;;
		eap192)
			append wpa_key_mgmt "WPA-EAP-SUITE-B-192"
		;;
		eap-eap192)
			append wpa_key_mgmt "WPA-EAP-SUITE-B-192"
			append wpa_key_mgmt "WPA-EAP"
			[ "${ieee80211r:-0}" -gt 0 ] && append wpa_key_mgmt "FT-EAP"
			[ "${ieee80211w:-0}" -gt 1 ] && append wpa_key_mgmt "WPA-EAP-SHA256"
		;;
		sae)
			append wpa_key_mgmt "SAE"
			[ "${ieee80211r:-0}" -gt 0 ] && append wpa_key_mgmt "FT-SAE"
		;;
		psk-sae)
			append wpa_key_mgmt "WPA-PSK"
			[ "${ieee80211r:-0}" -gt 0 ] && append wpa_key_mgmt "FT-PSK"
			[ "${ieee80211w:-0}" -gt 1 ] && append wpa_key_mgmt "WPA-PSK-SHA256"
			append wpa_key_mgmt "SAE"
			[ "${ieee80211r:-0}" -gt 0 ] && append wpa_key_mgmt "FT-SAE"
		;;
		owe)
			append wpa_key_mgmt "OWE"
		;;
	esac
}

hostapd_append_wmm_params() {
	local var="$1"

	[ -n "$wmm_ac_bk_cwmin" ] && append $var "wmm_ac_bk_cwmin=$wmm_ac_bk_cwmin" "$N"
	[ -n "$wmm_ac_bk_cwmax" ] && append $var "wmm_ac_bk_cwmax=$wmm_ac_bk_cwmax" "$N"
	[ -n "$wmm_ac_bk_aifs"  ] && append $var "wmm_ac_bk_aifs=$wmm_ac_bk_aifs" "$N"
	[ -n "$wmm_ac_bk_txop_limit" ] && append $var "wmm_ac_bk_txop_limit=$wmm_ac_bk_txop_limit" "$N"
	[ -n "$wmm_ac_bk_acm"  ] && append $var "wmm_ac_bk_acm=$wmm_ac_bk_acm" "$N"

	[ -n "$wmm_ac_be_cwmin" ] && append $var "wmm_ac_be_cwmin=$wmm_ac_be_cwmin" "$N"
	[ -n "$wmm_ac_be_cwmax" ] && append $var "wmm_ac_be_cwmax=$wmm_ac_be_cwmax" "$N"
	[ -n "$wmm_ac_be_aifs"  ] && append $var "wmm_ac_be_aifs=$wmm_ac_be_aifs" "$N"
	[ -n "$wmm_ac_be_txop_limit" ] && append $var "wmm_ac_be_txop_limit=$wmm_ac_be_txop_limit" "$N"
	[ -n "$wmm_ac_be_acm"  ] && append $var "wmm_ac_be_acm=$wmm_ac_be_acm" "$N"

	[ -n "$wmm_ac_vi_cwmin" ] && append $var "wmm_ac_vi_cwmin=$wmm_ac_vi_cwmin" "$N"
	[ -n "$wmm_ac_vi_cwmax" ] && append $var "wmm_ac_vi_cwmax=$wmm_ac_vi_cwmax" "$N"
	[ -n "$wmm_ac_vi_aifs"  ] && append $var "wmm_ac_vi_aifs=$wmm_ac_vi_aifs" "$N"
	[ -n "$wmm_ac_vi_txop_limit" ] && append $var "wmm_ac_vi_txop_limit=$wmm_ac_vi_txop_limit" "$N"
	[ -n "$wmm_ac_vi_acm"  ] && append $var "wmm_ac_vi_acm=$wmm_ac_vi_acm" "$N"

	[ -n "$wmm_ac_vo_cwmin" ] && append $var "wmm_ac_vo_cwmin=$wmm_ac_vo_cwmin" "$N"
	[ -n "$wmm_ac_vo_cwmax" ] && append $var "wmm_ac_vo_cwmax=$wmm_ac_vo_cwmax" "$N"
	[ -n "$wmm_ac_vo_aifs"  ] && append $var "wmm_ac_vo_aifs=$wmm_ac_vo_aifs" "$N"
	[ -n "$wmm_ac_vo_txop_limit" ] && append $var "wmm_ac_vo_txop_limit=$wmm_ac_vo_txop_limit" "$N"
	[ -n "$wmm_ac_vo_acm"  ] && append $var "wmm_ac_vo_acm=$wmm_ac_vo_acm" "$N"

	[ -n "$tx_queue_data0_cwmin" ] && append $var "tx_queue_data0_cwmin=$tx_queue_data0_cwmin" "$N"
	[ -n "$tx_queue_data0_cwmax" ] && append $var "tx_queue_data0_cwmax=$tx_queue_data0_cwmax" "$N"
	[ -n "$tx_queue_data0_aifs"  ] && append $var "tx_queue_data0_aifs=$tx_queue_data0_aifs" "$N"
	[ -n "$tx_queue_data0_burst" ] && append $var "tx_queue_data0_burst=$tx_queue_data0_burst" "$N"

	[ -n "$tx_queue_data1_cwmin" ] && append $var "tx_queue_data1_cwmin=$tx_queue_data1_cwmin" "$N"
	[ -n "$tx_queue_data1_cwmax" ] && append $var "tx_queue_data1_cwmax=$tx_queue_data1_cwmax" "$N"
	[ -n "$tx_queue_data1_aifs"  ] && append $var "tx_queue_data1_aifs=$tx_queue_data1_aifs" "$N"
	[ -n "$tx_queue_data1_burst" ] && append $var "tx_queue_data1_burst=$tx_queue_data1_burst" "$N"

	[ -n "$tx_queue_data2_cwmin" ] && append $var "tx_queue_data2_cwmin=$tx_queue_data2_cwmin" "$N"
	[ -n "$tx_queue_data2_cwmax" ] && append $var "tx_queue_data2_cwmax=$tx_queue_data2_cwmax" "$N"
	[ -n "$tx_queue_data2_aifs"  ] && append $var "tx_queue_data2_aifs=$tx_queue_data2_aifs" "$N"
	[ -n "$tx_queue_data2_burst" ] && append $var "tx_queue_data2_burst=$tx_queue_data2_burst" "$N"

	[ -n "$tx_queue_data3_cwmin" ] && append $var "tx_queue_data3_cwmin=$tx_queue_data3_cwmin" "$N"
	[ -n "$tx_queue_data3_cwmax" ] && append $var "tx_queue_data3_cwmax=$tx_queue_data3_cwmax" "$N"
	[ -n "$tx_queue_data3_aifs"  ] && append $var "tx_queue_data3_aifs=$tx_queue_data3_aifs" "$N"
	[ -n "$tx_queue_data3_burst" ] && append $var "tx_queue_data3_burst=$tx_queue_data3_burst" "$N"
}

hostapd_add_log_config() {
	config_add_boolean \
		log_80211 \
		log_8021x \
		log_radius \
		log_wpa \
		log_driver \
		log_iapp \
		log_mlme

	config_add_int log_level
}

hostapd_common_add_device_config() {
	config_add_array basic_rate
	config_add_array supported_rates

	config_add_string country
	config_add_boolean country_ie doth
	config_add_string require_mode
	config_add_string dfs_ch_state_file
	config_add_boolean legacy_rates
	config_add_int sub_band_dfs
	config_add_int sRadarRssiTh
	config_add_int sta_statistics
	config_add_string sCoCPower
	config_add_string sCoCAutoCfg
	config_add_string sErpSet
	config_add_string sFWRecovery
	config_add_string sFixedRateCfg
	config_add_int num_antennas
	config_add_int owl
	config_add_int notify_action_frame
	config_add_int rts_threshold
	config_add_boolean allow_scan_during_cac
	config_add_string colocated_6g_radio_info
	config_add_string colocated_6g_vap_info
    	config_add_int acs_bg_scan_do_switch

	if [ -f /lib/netifd/debug_infrastructure.sh ]; then
		debug_infrastructure_config_add_string debug_hostap_conf_
	fi

	hostapd_add_log_config
}

hostapd_prepare_device_config() {
	local config="$1"
	local driver="$2"

	local base="${config%%.conf}"
	local base_cfg=

	json_get_vars country country_ie beacon_int:100 doth require_mode legacy_rates \
					dfs_debug_chan externally_managed testbed_mode \
					sub_band_dfs sCoCPower sCoCAutoCfg sErpSet sFWRecovery sFixedRateCfg \
					sRadarRssiTh band num_antennas owl \
					sta_statistics notify_action_frame rts_threshold
					sRadarRssiTh band num_antennas owl \
					sta_statistics notify_action_frame rts_threshold \
					allow_scan_during_cac dfs_ch_state_file \
					colocated_6g_radio_info colocated_6g_vap_info \
					dfs_ch_state_file  acs_bg_scan_do_switch

        json_get_var sPowerSelection txpower

	hostapd_set_log_options base_cfg

	set_default country_ie 1
	set_default doth 1
	set_default legacy_rates 1
	set_default testbed_mode 0
	set_default sPowerSelection "$txpower"
	set_default acs_bg_scan_do_switch 1

	case "$sPowerSelection" in
		"12") sPowerSelection=15 ;;
		"25") sPowerSelection=6 ;;
		"50") sPowerSelection=3 ;;
		"100") sPowerSelection=0 ;;
		*) sPowerSelection= ;;
	esac

	[ -n "$sCoCPower" ] && append base_cfg "sCoCPower=$sCoCPower" "$N"
	[ -n "$sCoCAutoCfg" ] && append base_cfg "sCoCAutoCfg=$sCoCAutoCfg" "$N"
	[ -n "$sErpSet" ] && append base_cfg "sErpSet=$sErpSet" "$N"
	[ -n "$sPowerSelection" ] && append base_cfg "sPowerSelection=$sPowerSelection" "$N"
	[ -n "$sFWRecovery" ] && append base_cfg "sFWRecovery=$sFWRecovery" "$N"
	[ -n "$sFixedRateCfg" ] && append base_cfg "sFixedRateCfg=$sFixedRateCfg" "$N"
	[ -n "$sta_statistics" ] && append base_cfg "sStationsStat=$sta_statistics" "$N"
	[ -n "$owl" ] && append base_cfg "owl=$owl" "$N"
	[ -n "$notify_action_frame" ] && append base_cfg "notify_action_frame=$notify_action_frame" "$N"
	[ -n "$rts_threshold" ] && append base_cfg "rts_threshold=$rts_threshold" "$N"
	[ -n "$allow_scan_during_cac" ] && append base_cfg "allow_scan_during_cac=$allow_scan_during_cac" "$N"
	[ -n "$colocated_6g_radio_info" ] && append base_cfg "colocated_6g_radio_info=$colocated_6g_radio_info" "$N"
	[ -n "$colocated_6g_vap_info" ] && append base_cfg "colocated_6g_vap_info=$colocated_6g_vap_info" "$N"
	[ -n "$dfs_ch_state_file" ] && append base_cfg "dfs_channels_state_file_location=$dfs_ch_state_file" "$N"
	[ -n "$acs_bg_scan_do_switch" ] && append base_cfg "acs_bg_scan_do_switch=$acs_bg_scan_do_switch" "$N"

	[ "$testbed_mode" -gt 0 ] && append base_cfg "testbed_mode=1" "$N"

	append base_cfg "atf_config_file=$hostapd_atf_conf_file" "$N"

	[ "$hwmode" = "b" ] && legacy_rates=1

	[ -n "$country" ] && {
		append base_cfg "country_code=$country" "$N"

		[ "$country_ie" -gt 0 ] && append base_cfg "ieee80211d=1" "$N"
		[ "$band" = "5GHz" -a "$doth" -gt 0 ] && {
			append base_cfg "ieee80211h=1" "$N"
			[ -n "$sub_band_dfs" ] && append base_cfg "sub_band_dfs=$sub_band_dfs" "$N"
			[ -n "$sRadarRssiTh" ] && append base_cfg "sRadarRssiTh=$sRadarRssiTh" "$N"
		}
	}

	local brlist= br
	json_get_values basic_rate_list basic_rate
	local rlist= r
	json_get_values rate_list supported_rates

	[ -n "$hwmode" ] && append base_cfg "hw_mode=$hwmode" "$N"
	[ "$legacy_rates" -eq 0 ] && set_default require_mode g

	[ "$hwmode" = "g" ] && { # TODO: Remove? not done in FAPI
		[ "$legacy_rates" -eq 0 ] && set_default rate_list "6000 9000 12000 18000 24000 36000 48000 54000"
		[ -n "$require_mode" ] && set_default basic_rate_list "6000 12000 24000"
	}

	case "$require_mode" in
		n) append base_cfg "require_ht=1" "$N";;
		ac) append base_cfg "require_vht=1" "$N";;
		ax) append base_cfg "require_he=1" "$N";;
	esac

	for r in $rate_list; do
		hostapd_add_rate rlist "$r"
	done

	for br in $basic_rate_list; do
		hostapd_add_rate brlist "$br"
	done

	[ -n "$rlist" ] && append base_cfg "supported_rates=$rlist" "$N"
	[ -n "$brlist" ] && append base_cfg "basic_rates=$brlist" "$N"
	append base_cfg "beacon_int=$beacon_int" "$N"

	[ -n "$dfs_debug_chan" ] && append base_cfg "dfs_debug_chan=$dfs_debug_chan" "$N"

	[ "$externally_managed" = "1" ] && append base_cfg "acs_scan_mode=1" "$N"

	cat > "$config" <<EOF
driver=$driver
$base_cfg
EOF
}

hostapd_common_add_bss_config() {
	config_add_string 'bssid:macaddr' 'ssid:string'
	config_add_boolean wds wmm uapsd hidden

	config_add_int maxassoc max_inactivity
	config_add_boolean disassoc_low_ack isolate short_preamble

	config_add_int sFourAddrMode sBridgeMode

	config_add_string sAddPeerAP

	config_add_int \
		wep_rekey eap_reauth_period \
		wpa_group_rekey wpa_pair_rekey wpa_master_rekey
	config_add_boolean wpa_disable_eapol_key_retries

	config_add_boolean rsn_preauth auth_cache
	config_add_int ieee80211w
	config_add_int eapol_version

	config_add_string 'auth_server:host' 'server:host'
	config_add_string auth_secret
	config_add_int 'auth_port:port' 'port:port'

	config_add_string sec_auth_server
	config_add_string sec_auth_secret
	config_add_int sec_auth_port

	config_add_string acct_server
	config_add_string acct_secret
	config_add_int acct_port
	config_add_int acct_interim_interval

	config_add_string sec_acct_server
	config_add_string sec_acct_secret
	config_add_int sec_acct_port

	config_add_int eap_aaa_req_retries eap_aaa_req_timeout pmksa_life_time pmksa_interval \
		max_eap_failure auth_fail_blacklist_duration eap_req_id_retry_interval \
		failed_authentication_quiet_period

	config_add_string dae_client
	config_add_string dae_secret
	config_add_int dae_port

	config_add_string nasid
	config_add_string ownip
	config_add_string iapp_interface
	config_add_string eap_type ca_cert client_cert identity anonymous_identity auth priv_key priv_key_pwd

	config_add_int dynamic_vlan vlan_naming
	config_add_string vlan_tagged_interface vlan_bridge
	config_add_string vlan_file

	config_add_string 'key1:wepkey' 'key2:wepkey' 'key3:wepkey' 'key4:wepkey' 'password:wpakey'

	config_add_string wpa_psk_file
	config_add_string sae_key

	config_add_boolean wps_pushbutton wps_keypad wps_label ext_registrar wps_pbc_in_m1
	config_add_int wps_ap_setup_locked wps_independent wps_state
	config_add_int wps_cred_processing
	config_add_string wps_device_type wps_device_name wps_manufacturer wps_pin
	config_add_string wps_uuid wps_pin_requests wps_os_version wps_rf_bands
	config_add_string wps_manufacturer_url wps_model_description upnp_bridge
	config_add_string wps_model_number wps_serial_number wps_skip_cred_build
	config_add_string wps_extra_cred wps_ap_settings wps_friendly_name
	config_add_string wps_model_url wps_upc wps_model_name

	config_add_boolean ieee80211r pmk_r1_push ft_over_ds
	config_add_int r0_key_lifetime reassociation_deadline
	config_add_string mobility_domain r1_key_holder
	config_add_array r0kh r1kh

	config_add_int ieee80211w_max_timeout ieee80211w_retry_timeout

#	config_add_string macfilter 'macfile:file'
#	config_add_array 'maclist:list(macaddr)'

	config_add_array bssid_blacklist
	config_add_array bssid_whitelist

	config_add_int mcast_rate
	config_add_array basic_rate
	config_add_array supported_rates

	config_add_boolean sae_require_mfp

	config_add_string 'owe_transition_bssid:macaddr' 'owe_transition_ssid:string'

	config_add_int num_res_sta
	config_add_int proxy_arp
	config_add_int mbo
	config_add_int mbo_cell_aware
	config_add_int rrm_neighbor_report
	config_add_int bss_transition
	config_add_int interworking
	config_add_int access_network_type
	config_add_int gas_comeback_delay
	config_add_string authresp_elements
	config_add_string vendor_elements
	config_add_string assocresp_elements
	config_add_string mesh_mode
	config_add_string ctrl_interface_group
	config_add_string qos_map_set
	config_add_int s11nProtection
	config_add_string sAggrConfig
	config_add_string wav_bridge
	config_add_boolean sUdmaEnabled
	config_add_int sUdmaVlanId
	config_add_boolean vendor_vht
	config_add_boolean internet_available
	config_add_boolean asra
	config_add_boolean esr
	config_add_boolean uesa
	config_add_int venue_type
	config_add_int venue_group
	config_add_string hessid
	config_add_int management_frames_rate
	config_add_int bss_beacon_int

	config_add_int \
		wmm_ac_bk_cwmin wmm_ac_bk_cwmax wmm_ac_bk_aifs wmm_ac_bk_txop_limit wmm_ac_bk_acm \
		wmm_ac_be_cwmin wmm_ac_be_cwmax wmm_ac_be_aifs wmm_ac_be_txop_limit wmm_ac_be_acm \
		wmm_ac_vi_cwmin wmm_ac_vi_cwmax wmm_ac_vi_aifs wmm_ac_vi_txop_limit wmm_ac_vi_acm \
		wmm_ac_vo_cwmin wmm_ac_vo_cwmax wmm_ac_vo_aifs wmm_ac_vo_txop_limit wmm_ac_vo_acm \
		tx_queue_data0_cwmin tx_queue_data0_cwmax tx_queue_data0_aifs \
		tx_queue_data1_cwmin tx_queue_data1_cwmax tx_queue_data1_aifs \
		tx_queue_data2_cwmin tx_queue_data2_cwmax tx_queue_data2_aifs \
		tx_queue_data3_cwmin tx_queue_data3_cwmax tx_queue_data3_aifs

	config_add_string \
		tx_queue_data0_burst tx_queue_data1_burst tx_queue_data2_burst tx_queue_data3_burst

	if [ -f /lib/netifd/debug_infrastructure.sh ]; then
		debug_infrastructure_config_add_string debug_hostap_conf_
	fi
}

hostapd_set_bss_options() {
	local var="$1"
	local phy="$2"
	local vif="$3"

	wireless_vif_parse_encryption

	local bss_conf
	local wep_rekey wpa_group_rekey wpa_pair_rekey wpa_master_rekey wpa_key_mgmt
	local legacy_vendor_elements="dd050009860100"

	json_get_vars \
		wep_rekey wpa_group_rekey wpa_pair_rekey wpa_master_rekey \
		wpa_disable_eapol_key_retries \
		maxassoc max_inactivity disassoc_low_ack isolate auth_cache \
		wps_pushbutton wps_keypad wps_label ext_registrar wps_pbc_in_m1 wps_ap_setup_locked \
		wps_independent wps_device_type wps_device_name wps_manufacturer wps_pin \
		ssid wmm uapsd hidden short_preamble rsn_preauth \
		iapp_interface eapol_version acct_server acct_secret acct_port \
		dynamic_vlan ieee80211w sec_acct_server sec_acct_secret sec_acct_port \
		acct_interim_interval wps_state wps_rf_bands wps_uuid qos_map_set \
		wmm_ac_bk_cwmin wmm_ac_bk_cwmax wmm_ac_bk_aifs wmm_ac_bk_txop_limit wmm_ac_bk_acm \
		wmm_ac_be_cwmin wmm_ac_be_cwmax wmm_ac_be_aifs wmm_ac_be_txop_limit wmm_ac_be_acm \
		wmm_ac_vi_cwmin wmm_ac_vi_cwmax wmm_ac_vi_aifs wmm_ac_vi_txop_limit wmm_ac_vi_acm \
		wmm_ac_vo_cwmin wmm_ac_vo_cwmax wmm_ac_vo_aifs wmm_ac_vo_txop_limit wmm_ac_vo_acm \
		tx_queue_data0_cwmin tx_queue_data0_cwmax tx_queue_data0_aifs tx_queue_data0_burst \
		tx_queue_data1_cwmin tx_queue_data1_cwmax tx_queue_data1_aifs tx_queue_data1_burst \
		tx_queue_data2_cwmin tx_queue_data2_cwmax tx_queue_data2_aifs tx_queue_data2_burst \
		tx_queue_data3_cwmin tx_queue_data3_cwmax tx_queue_data3_aifs tx_queue_data3_burst \
		mbo mbo_cell_aware rrm_neighbor_report num_res_sta mesh_mode ctrl_interface_group proxy_arp \
		authresp_elements vendor_elements assocresp_elements gas_comeback_delay \
		wps_pin_requests wps_os_version wps_cred_processing wps_manufacturer_url \
		wps_model_description interworking access_network_type bss_transition \
		s11nProtection sAggrConfig wav_bridge upnp_bridge \
		wps_model_number wps_serial_number wps_skip_cred_build wps_extra_cred \
		wps_ap_settings wps_friendly_name wps_model_url wps_upc wps_model_name \
		sUdmaEnabled sUdmaVlanId vendor_vht internet_available asra esr uesa \
		venue_type venue_group hessid sae_require_mfp management_frames_rate \
		sFourAddrMode sBridgeMode sAddPeerAP bss_beacon_int

	if [ -f /lib/netifd/debug_infrastructure.sh ]; then
		debug_infrastructure_json_get_vars debug_hostap_conf_
	fi

	set_default isolate 0
	set_default max_inactivity 0
	set_default proxy_arp 0
	set_default num_res_sta 0
	set_default gas_comeback_delay 0
	set_default short_preamble 1
	set_default disassoc_low_ack 1
	set_default hidden 0
	set_default wmm 1
	set_default uapsd 1
	set_default wpa_disable_eapol_key_retries 0
	set_default eapol_version 0
	set_default acct_port 1813
	set_default sec_acct_port 1813
	set_default mbo 1
	set_default bss_transition 1
	set_default interworking 1
	set_default access_network_type 0
	set_default vendor_vht 1

	append bss_conf "ctrl_interface=/var/run/hostapd" "$N"
	[ -n "$ctrl_interface_group" ] && {
		append bss_conf "ctrl_interface_group=$ctrl_interface_group" "$N"
	}
	[ -n "$mesh_mode" ] && {
		append bss_conf "mesh_mode=$mesh_mode" "$N"
		[ "$mesh_mode" = "bAP" ] && {
			maxassoc=1
			num_res_sta=0
		}
	}
	if [ "$isolate" -gt 0 ]; then
		append bss_conf "ap_isolate=$isolate" "$N"
	fi

	[ -n "$maxassoc" ] && append bss_conf "max_num_sta=$maxassoc" "$N"

	[ -n "$sFourAddrMode" ] && append bss_conf "sFourAddrMode=$sFourAddrMode" "$N"

	[ -n "$sBridgeMode" ] && append bss_conf "sBridgeMode=$sBridgeMode" "$N"

	[ -n "$sAddPeerAP" ] && append bss_conf "sAddPeerAP=$sAddPeerAP" "$N"

	if [ "$max_inactivity" -gt 0 ]; then
		append bss_conf "ap_max_inactivity=$max_inactivity" "$N"
	fi
	if [ "$proxy_arp" -gt 0 ]; then
		append bss_conf "proxy_arp=$proxy_arp" "$N"
	fi
	if [ "$num_res_sta" -gt 0 ]; then
		append bss_conf "num_res_sta=$num_res_sta" "$N"
	fi
	if [ "$gas_comeback_delay" -gt 0 ]; then
		append bss_conf "gas_comeback_delay=$gas_comeback_delay" "$N"
	fi
	if [ "$rrm_neighbor_report" -gt 0 ]; then
		append bss_conf "rrm_neighbor_report=$rrm_neighbor_report" "$N"
	fi
	if [ "$bss_transition" -gt 0 ]; then
		append bss_conf "bss_transition=$bss_transition" "$N"
	fi

	[ -n "$bss_beacon_int" ] && append bss_conf "bss_beacon_int=$bss_beacon_int" "$N"

	if [ "$interworking" -gt 0 ]; then
		append bss_conf "interworking=$interworking" "$N"
		
		if [ "$access_network_type" -gt 0 ]; then
			append bss_conf "access_network_type=$access_network_type" "$N"
		fi

		if [ -n "$internet_available" ]; then
			append bss_conf "internet=$internet_available" "$N"
		fi
		if [ -n "$asra" ]; then
			append bss_conf "asra=$asra" "$N"
		fi
		if [ -n "$esr" ]; then
			append bss_conf "esr=$esr" "$N"
		fi
		if [ -n "$uesa" ]; then
			append bss_conf "uesa=$uesa" "$N"
		fi
		if [ -n "$venue_type" ]; then
			append bss_conf "venue_type=$venue_type" "$N"
		fi
		if [ -n "$venue_group" ]; then
			append bss_conf "venue_group=$venue_group" "$N"
		fi
		if [ -n "$hessid" ]; then
			append bss_conf "hessid=$hessid" "$N"
		fi
	fi

	[ -n "$management_frames_rate"  ] && append bss_conf "management_frames_rate=$management_frames_rate" "$N"

	append bss_conf "disassoc_low_ack=$disassoc_low_ack" "$N"
	append bss_conf "preamble=$short_preamble" "$N"
	append bss_conf "wmm_enabled=$wmm" "$N"
	append bss_conf "ignore_broadcast_ssid=$hidden" "$N"
	append bss_conf "uapsd_advertisement_enabled=$uapsd" "$N"

	[ "$mbo" -gt 0 ] && {
		append bss_conf "mbo=$mbo" "$N"
		[ -n "$mbo_cell_aware" ] && append bss_conf "mbo_cell_aware=$mbo_cell_aware" "$N"
	}

	[ "$wmm" -gt 0 ] && {
		hostapd_append_wmm_params bss_conf
	}

	[ "$wpa" -gt 0 ] && {
		[ -n "$wpa_group_rekey"  ] && append bss_conf "wpa_group_rekey=$wpa_group_rekey" "$N"
		[ -n "$wpa_pair_rekey"   ] && append bss_conf "wpa_ptk_rekey=$wpa_pair_rekey"    "$N"
		[ -n "$wpa_master_rekey" ] && append bss_conf "wpa_gmk_rekey=$wpa_master_rekey"  "$N"
	}

	append bss_conf "vendor_elements=${legacy_vendor_elements}${vendor_elements}" "$N"
	[ -n "$authresp_elements" ] && append bss_conf "authresp_elements=$authresp_elements" "$N"
	[ -n "$assocresp_elements" ] && append bss_conf "assocresp_elements=$assocresp_elements" "$N"

	[ -n "$qos_map_set" ] && append bss_conf "qos_map_set=$qos_map_set" "$N"
	[ -n "$s11nProtection" ] && append bss_conf "s11nProtection=$s11nProtection" "$N"
	[ -n "$sAggrConfig" ] && append bss_conf "sAggrConfig=$sAggrConfig" "$N"
	[ -n "$sUdmaEnabled" ] && {
		append bss_conf "sUdmaEnabled=$sUdmaEnabled" "$N"
		[ -n "$sUdmaVlanId" ] && append bss_conf "sUdmaVlanId=$sUdmaVlanId" "$N"
	}

	if [ "$hwmode" = "g" ]; then
		[ -n "$ieee80211n" ] && append bss_conf "vendor_vht=$vendor_vht" "$N"
	fi

	[ -n "$acct_server" ] && {
		append bss_conf "acct_server_addr=$acct_server" "$N"
		append bss_conf "acct_server_port=$acct_port" "$N"
		[ -n "$acct_secret" ] && \
			append bss_conf "acct_server_shared_secret=$acct_secret" "$N"
	}

	[ -n "$sec_acct_server" ] && {
		append bss_conf "acct_server_addr=$sec_acct_server" "$N"
		append bss_conf "acct_server_port=$sec_acct_port" "$N"
		[ -n "$sec_acct_secret" ] && \
			append bss_conf "acct_server_shared_secret=$sec_acct_secret" "$N"
	}

	[ -n "$acct_server" -o -n "$sec_acct_server" ] && {
		[ -n "$acct_interim_interval" ] && \
		append bss_conf "radius_acct_interim_interval=$acct_interim_interval" "$N"
	}

	case "$auth_type" in
		sae|owe|eap192|eap-eap192)
			set_default ieee80211w 2
			set_default sae_require_mfp 1
		;;
		psk-sae)
			set_default ieee80211w 1
			set_default sae_require_mfp 1
		;;
	esac
	[ -n "$sae_require_mfp" ] && append bss_conf "sae_require_mfp=$sae_require_mfp" "$N"

	local vlan_possible=""

	case "$auth_type" in
		none|owe)
			json_get_vars owe_transition_bssid owe_transition_ssid

			[ -n "$owe_transition_ssid" ] && append bss_conf "owe_transition_ssid=\"$owe_transition_ssid\"" "$N"
			[ -n "$owe_transition_bssid" ] && append bss_conf "owe_transition_bssid=$owe_transition_bssid" "$N"

			wps_possible=1
			# Here we make the assumption that if we're in open mode
			# with WPS enabled, we got to be in unconfigured state.
			wps_not_configured=1
		;;
		psk)
			json_get_vars key wpa_psk_file
			if [ ${#key} -lt 8 ]; then
				wireless_setup_vif_failed INVALID_WPA_PSK
				return 1
			elif [ ${#key} -eq 64 ]; then
				append bss_conf "wpa_psk=$key" "$N"
			else
				append bss_conf "wpa_passphrase=$key" "$N"
			fi
			[ -n "$wpa_psk_file" ] && {
				[ -e "$wpa_psk_file" ] || touch "$wpa_psk_file"
				append bss_conf "wpa_psk_file=$wpa_psk_file" "$N"
			}
			[ "$eapol_version" -ge "1" -a "$eapol_version" -le "2" ] && append bss_conf "eapol_version=$eapol_version" "$N"

			wps_possible=1
		;;
		psk-sae)
			json_get_vars key sae_key
			if [[ ${#key} -lt 8 || ${#key} -gt 63 ]]; then
				wireless_setup_vif_failed INVALID_WPA_PSK
				return 1
			fi

			if [[ "$key" != "" && "$sae_key" != "" ]]; then
				append bss_conf "wpa_passphrase=$key" "$N"
				append bss_conf "sae_password=$sae_key" "$N"
			elif [ "$key" != "" ]; then
				append bss_conf "wpa_passphrase=$key" "$N"
				append bss_conf "sae_password=$key" "$N"
			else
				wireless_setup_vif_failed INVALID_WPA_PSK
				return 1
			fi

			wps_possible=1
		;;
		sae)
			json_get_vars key sae_key
			if [ "$sae_key" != "" ]; then
				append bss_conf "sae_password=$sae_key" "$N"
			elif [ "$key" != "" ]; then
				append bss_conf "sae_password=$key" "$N"
			else
				wireless_setup_vif_failed INVALID_WPA_PSK
				return 1
			fi
		;;
		eap|eap192|eap-eap192)
			json_get_vars \
				auth_server auth_secret auth_port \
				sec_auth_server sec_auth_secret sec_auth_port \
				dae_client dae_secret dae_port \
				ownip \
				eap_reauth_period
				venue_type venue_group hessid sae_require_mfp \
				eap_aaa_req_retries eap_aaa_req_timeout pmksa_life_time pmksa_interval \
				max_eap_failure auth_fail_blacklist_duration eap_req_id_retry_interval \
				failed_authentication_quiet_period

			# radius can provide VLAN ID for clients
			vlan_possible=1

			# legacy compatibility
			[ -n "$auth_server" ] || json_get_var auth_server server
			[ -n "$auth_port" ] || json_get_var auth_port port
			[ -n "$auth_secret" ] || json_get_var auth_secret key

			set_default auth_port 1812
			set_default sec_auth_port 1812
			set_default dae_port 3799

			append bss_conf "auth_server_addr=$auth_server" "$N"
			append bss_conf "auth_server_port=$auth_port" "$N"
			append bss_conf "auth_server_shared_secret=$auth_secret" "$N"

			[ -n "$eap_aaa_req_retries" ] && append bss_conf "eap_aaa_req_retries=$eap_aaa_req_retries" "$N"
			[ -n "$eap_aaa_req_timeout" ] && append bss_conf "eap_aaa_req_timeout=$eap_aaa_req_timeout" "$N"
			[ -n "$pmksa_life_time" ] && append bss_conf "pmksa_life_time=$pmksa_life_time" "$N"
			[ -n "$pmksa_interval" ] && append bss_conf "pmksa_interval=$pmksa_interval" "$N"
			[ -n "$max_eap_failure" ] && append bss_conf "max_eap_failure=$max_eap_failure" "$N"
			[ -n "$auth_fail_blacklist_duration" ] && append bss_conf "auth_fail_blacklist_duration=$auth_fail_blacklist_duration" "$N"
			[ -n "$eap_req_id_retry_interval" ] && append bss_conf "eap_req_id_retry_interval=$eap_req_id_retry_interval" "$N"
			[ -n "$failed_authentication_quiet_period" ] && append bss_conf "failed_authentication_quiet_period=$failed_authentication_quiet_period" "$N"

			[ -n "$sec_auth_server" ] && {
				append bss_conf "auth_server_addr=$sec_auth_server" "$N"
				append bss_conf "auth_server_port=$sec_auth_port" "$N"
				append bss_conf "auth_server_shared_secret=$sec_auth_secret" "$N"
			}

			[ -n "$eap_reauth_period" ] && append bss_conf "eap_reauth_period=$eap_reauth_period" "$N"

			[ -n "$dae_client" -a -n "$dae_secret" ] && {
				append bss_conf "radius_das_port=$dae_port" "$N"
				append bss_conf "radius_das_client=$dae_client $dae_secret" "$N"
			}

			[ -n "$ownip" ] && append bss_conf "own_ip_addr=$ownip" "$N"
			append bss_conf "eapol_key_index_workaround=1" "$N"
			append bss_conf "ieee8021x=1" "$N"

			[ "$eapol_version" -ge "1" -a "$eapol_version" -le "2" ] && append bss_conf "eapol_version=$eapol_version" "$N"
		;;
		wep)
			local wep_keyidx=0
			json_get_vars key
			hostapd_append_wep_key bss_conf
			append bss_conf "wep_default_key=$wep_keyidx" "$N"
			[ -n "$wep_rekey" ] && append bss_conf "wep_rekey_period=$wep_rekey" "$N"
		;;
	esac

	local auth_algs=$((($auth_mode_shared << 1) | $auth_mode_open))
	append bss_conf "auth_algs=${auth_algs:-1}" "$N"
	append bss_conf "wpa=$wpa" "$N"
	[ -n "$wpa_pairwise" ] && append bss_conf "wpa_pairwise=$wpa_pairwise" "$N"
	[ -n "$rsn_pairwise" ] && append bss_conf "rsn_pairwise=$rsn_pairwise" "$N"

	set_default wps_pushbutton 0
	set_default wps_keypad 0
	set_default wps_label 0
	set_default wps_pbc_in_m1 0

	config_methods=
	[ "$wps_pushbutton" -gt 0 ] && append config_methods push_button
	[ "$wps_label" -gt 0 ] && append config_methods label
	[ "$wps_keypad" -gt 0 ] && append config_methods keypad

	[ -n "$wps_possible" -a -n "$config_methods" ] && {
		set_default ext_registrar 0
		set_default wps_device_type "6-0050F204-1"
		set_default wps_device_name "WLAN-ROUTER"
		set_default wps_manufacturer "Intel Corporation"
		set_default wps_manufacturer_url "http://www.intel.com"
		set_default wps_model_description "TR069 Gateway"
		set_default wps_os_version "01020300"
		set_default wps_cred_processing 1
		set_default wps_independent 1
		set_default wps_state 2

		if [ "$ext_registrar" -gt 0 -a -n "$network_bridge" ]; then
			append bss_conf "upnp_iface=$network_bridge" "$N"
		elif [ -n "$upnp_bridge" ]; then
			append bss_conf "upnp_iface=$upnp_bridge" "$N"
		fi

		append bss_conf "eap_server=1" "$N"
		[ -n "$wps_pin" ] && append bss_conf "ap_pin=$wps_pin" "$N"
		[ -n "$wps_uuid" ] && append bss_conf "uuid=$wps_uuid" "$N"
		[ -n "$wps_pin_requests" ] && append bss_conf "wps_pin_requests=$wps_pin_requests" "$N"
		append bss_conf "wps_state=$wps_state" "$N"
		append bss_conf "device_type=$wps_device_type" "$N"
		append bss_conf "device_name=$wps_device_name" "$N"
		append bss_conf "manufacturer=$wps_manufacturer" "$N"
		append bss_conf "config_methods=$config_methods" "$N"
		append bss_conf "wps_independent=$wps_independent" "$N"
		append bss_conf "wps_cred_processing=$wps_cred_processing" "$N"
		[ -n "$wps_ap_setup_locked" ] && append bss_conf "ap_setup_locked=$wps_ap_setup_locked" "$N"
		[ "$wps_pbc_in_m1" -gt 0 ] && append bss_conf "pbc_in_m1=$wps_pbc_in_m1" "$N"

		append bss_conf "os_version=$wps_os_version" "$N"
		append bss_conf "manufacturer_url=$wps_manufacturer_url" "$N"
		append bss_conf "model_description=$wps_model_description" "$N"

		[ -n "$wps_rf_bands" ] && append bss_conf "wps_rf_bands=$wps_rf_bands" "$N"
		[ -n "$wps_model_name" ] && append bss_conf "model_name=$wps_model_name" "$N"
		[ -n "$wps_model_number" ] && append bss_conf "model_number=$wps_model_number" "$N"
		[ -n "$wps_serial_number" ] && append bss_conf "serial_number=$wps_serial_number" "$N"
		[ -n "$wps_skip_cred_build" ] && append bss_conf "skip_cred_build=$wps_skip_cred_build" "$N"
		[ -n "$wps_extra_cred" ] && append bss_conf "extra_cred=$wps_extra_cred" "$N"
		[ -n "$wps_ap_settings" ] && append bss_conf "ap_settings=$wps_ap_settings" "$N"
		[ -n "$wps_friendly_name" ] && append bss_conf "friendly_name=$wps_friendly_name" "$N"
		[ -n "$wps_model_url" ] && append bss_conf "model_url=$wps_model_url" "$N"
		[ -n "$wps_upc" ] && append bss_conf "upc=$wps_upc" "$N"
	}

	append bss_conf "ssid=$ssid" "$N"
	if [ -n "$network_bridge" ]; then
		 append bss_conf "bridge=$network_bridge" "$N"
	else
		if [ -n "$wav_bridge" ]; then
			append bss_conf "bridge=$wav_bridge" "$N"
		fi
	fi
	[ -n "$iapp_interface" ] && {
		local ifname
		network_get_device ifname "$iapp_interface" || ifname="$iapp_interface"
		append bss_conf "iapp_interface=$ifname" "$N"
	}

	if [ "$wpa" -ge "1" ]; then
		json_get_vars nasid ieee80211r
		set_default ieee80211r 0
		[ -n "$nasid" ] && append bss_conf "nas_identifier=$nasid" "$N"

		if [ "$ieee80211r" -gt "0" ]; then
			json_get_vars mobility_domain r0_key_lifetime r1_key_holder \
			reassociation_deadline pmk_r1_push ft_over_ds
			json_get_values r0kh r0kh
			json_get_values r1kh r1kh

			set_default mobility_domain "4f57"
			set_default r0_key_lifetime 10000
			set_default r1_key_holder "00004f577274"
			set_default reassociation_deadline 1000
			set_default pmk_r1_push 0
			set_default ft_over_ds 1

			append bss_conf "mobility_domain=$mobility_domain" "$N"
			append bss_conf "r0_key_lifetime=$r0_key_lifetime" "$N"
			append bss_conf "r1_key_holder=$r1_key_holder" "$N"
			append bss_conf "reassociation_deadline=$reassociation_deadline" "$N"
			append bss_conf "pmk_r1_push=$pmk_r1_push" "$N"
			append bss_conf "ft_over_ds=$ft_over_ds" "$N"

			for kh in $r0kh; do
				append bss_conf "r0kh=${kh//,/ }" "$N"
			done
			for kh in $r1kh; do
				append bss_conf "r1kh=${kh//,/ }" "$N"
			done
		fi

		append bss_conf "wpa_disable_eapol_key_retries=$wpa_disable_eapol_key_retries" "$N"

		hostapd_append_wpa_key_mgmt
		[ -n "$wpa_key_mgmt" ] && append bss_conf "wpa_key_mgmt=$wpa_key_mgmt" "$N"
	fi

	if [ "$wpa" -ge "2" ]; then
		if [ -n "$network_bridge" -a "$rsn_preauth" = 1 ]; then
			set_default auth_cache 1
			append bss_conf "rsn_preauth=1" "$N"
			append bss_conf "rsn_preauth_interfaces=$network_bridge" "$N"
		else
			set_default auth_cache 1
		fi

		append bss_conf "okc=$auth_cache" "$N"
		[ "$auth_cache" = 0 ] && append bss_conf "disable_pmksa_caching=1" "$N"

		# RSN -> allow management frame protection
		case "$ieee80211w" in
			[012])
				json_get_vars ieee80211w_max_timeout ieee80211w_retry_timeout
				append bss_conf "ieee80211w=$ieee80211w" "$N"
				[ "$ieee80211w" -gt "0" ] && {
					[ -n "$ieee80211w_max_timeout" ] && \
						append bss_conf "assoc_sa_query_max_timeout=$ieee80211w_max_timeout" "$N"
					[ -n "$ieee80211w_retry_timeout" ] && \
						append bss_conf "assoc_sa_query_retry_timeout=$ieee80211w_retry_timeout" "$N"
				}
			;;
		esac
	fi

	macfile="/tmp/maclist"
	_macfile="/var/run/hostapd-$ifname.maclist"
	mf_type=`uci get macfilter.macfilter.type`
	if [ "$ifname" = "wlan0.1" -o "$ifname" = "wlan2.1" ]; then
		case "$mf_type" in
			white)
				append bss_conf "macaddr_acl=1" "$N"
				append bss_conf "accept_mac_file=$_macfile" "$N"
				# accept_mac_file can be used to set MAC to VLAN ID mapping
				vlan_possible=1
			;;
			black)
				append bss_conf "macaddr_acl=0" "$N"
				append bss_conf "deny_mac_file=$_macfile" "$N"
			;;
			*)
				_macfile=""
			;;
		esac

		if [ ! -f "$maclile" ]; then
			touch $macfile
		fi
		
		[ -f "$macfile" ] && {
			cp $macfile $_macfile
		}
	fi

	[ -n "$vlan_possible" -a -n "$dynamic_vlan" ] && {
		json_get_vars vlan_naming vlan_tagged_interface vlan_bridge vlan_file
		set_default vlan_naming 1
		append bss_conf "dynamic_vlan=$dynamic_vlan" "$N"
		append bss_conf "vlan_naming=$vlan_naming" "$N"
		[ -n "$vlan_bridge" ] && \
			append bss_conf "vlan_bridge=$vlan_bridge" "$N"
		[ -n "$vlan_tagged_interface" ] && \
			append bss_conf "vlan_tagged_interface=$vlan_tagged_interface" "$N"
		[ -n "$vlan_file" ] && {
			[ -e "$vlan_file" ] || touch "$vlan_file"
			append bss_conf "vlan_file=$vlan_file" "$N"
		}
	}

	if [ -f /lib/netifd/debug_infrastructure.sh ]; then
		debug_infrastructure_append debug_hostap_conf_ bss_conf
	fi

	append "$var" "$bss_conf" "$N"
	return 0
}

hostapd_set_log_options() {
	local var="$1"

	local log_level log_80211 log_8021x log_radius log_wpa log_driver log_iapp log_mlme
	json_get_vars log_level log_80211 log_8021x log_radius log_wpa log_driver log_iapp log_mlme

	set_default log_level 2
	set_default log_80211  1
	set_default log_8021x  1
	set_default log_radius 1
	set_default log_wpa    1
	set_default log_driver 1
	set_default log_iapp   1
	set_default log_mlme   1

	local log_mask=$(( \
		($log_80211  << 0) | \
		($log_8021x  << 1) | \
		($log_radius << 2) | \
		($log_wpa    << 3) | \
		($log_driver << 4) | \
		($log_iapp   << 5) | \
		($log_mlme   << 6)   \
	))

	append "$var" "logger_syslog=$log_mask" "$N"
	append "$var" "logger_syslog_level=$log_level" "$N"
	append "$var" "logger_stdout=$log_mask" "$N"
	append "$var" "logger_stdout_level=$log_level" "$N"

	return 0
}

_wpa_supplicant_common() {
	local ifname="$1"

	_rpath="/var/run/wpa_supplicant"
	_config="${_rpath}-$ifname.conf"
}

wpa_supplicant_teardown_interface() {
	_wpa_supplicant_common "$1"
	rm -rf "$_rpath/$1" "$_config"
}

wpa_supplicant_prepare_interface() {
	local ifname="$1"
	_w_driver="$2"

	_wpa_supplicant_common "$1"

	json_get_vars mode wds vendor_elems

	[ -n "$network_bridge" ] && {
		fail=
		case "$mode" in
			adhoc)
				fail=1
			;;
			sta)
				[ "$wds" = 1 ] || fail=1
			;;
		esac

		[ -n "$fail" ] && {
			wireless_setup_vif_failed BRIDGE_NOT_ALLOWED
			return 1
		}
	}

	local ap_scan=

	_w_mode="$mode"
	_w_modestr=

	[[ "$mode" = adhoc ]] && {
		ap_scan="ap_scan=2"

		_w_modestr="mode=1"
	}

	local country_str=
	[ -n "$country" ] && {
		country_str="country=$country"
	}

	local vendor_elems_str=
	[ -n "$vendor_elems" ] && {
		vendor_elems_str="vendor_elems=$vendor_elems"
	}

	local wds_str=
	[ -n "$wds" ] && {
		wds_str="wds=$wds"
	}

	wpa_supplicant_teardown_interface "$ifname"
	cat > "$_config" <<EOF
$ap_scan
$country_str
$vendor_elems_str
$wds_str
EOF
	return 0
}

wpa_supplicant_add_network() {
	local ifname="$1"

	_wpa_supplicant_common "$1"
	wireless_vif_parse_encryption

	json_get_vars \
		ssid bssid key \
		basic_rate mcast_rate \
		ieee80211w ieee80211r

	set_default ieee80211r 0

	local key_mgmt='NONE'
	local enc_str=
	local network_data=
	local T="	"

	local scan_ssid="scan_ssid=1"
	local freq wpa_key_mgmt

	[[ "$_w_mode" = "adhoc" ]] && {
		append network_data "mode=1" "$N$T"
		[ -n "$channel" ] && {
			freq="$(get_freq "$phy" "$channel")"
			append network_data "fixed_freq=1" "$N$T"
			append network_data "frequency=$freq" "$N$T"
		}

		scan_ssid="scan_ssid=0"

		[ "$_w_driver" = "nl80211" ] ||	append wpa_key_mgmt "WPA-NONE"
	}

	[[ "$_w_mode" = "mesh" ]] && {
		json_get_vars mesh_id
		ssid="${mesh_id}"

		append network_data "mode=5" "$N$T"
		[ -n "$channel" ] && {
			freq="$(get_freq "$phy" "$channel")"
			append network_data "frequency=$freq" "$N$T"
		}
		append wpa_key_mgmt "SAE"
		scan_ssid=""
	}

	[ "$_w_mode" = "adhoc" -o "$_w_mode" = "mesh" ] && append network_data "$_w_modestr" "$N$T"

	case "$auth_type" in
		none) ;;
		owe)
			hostapd_append_wpa_key_mgmt
		;;
		wep)
			local wep_keyidx=0
			hostapd_append_wep_key network_data
			append network_data "wep_tx_keyidx=$wep_keyidx" "$N$T"
		;;
		psk|sae|psk-sae)
			local passphrase

			if [ "$_w_mode" != "mesh" ]; then
				hostapd_append_wpa_key_mgmt
			fi

			key_mgmt="$wpa_key_mgmt"

			if [ ${#key} -eq 64 ]; then
				passphrase="psk=${key}"
			else
				passphrase="psk=\"${key}\""
			fi
			append network_data "$passphrase" "$N$T"
		;;
		eap|eap192|eap-eap192)
			hostapd_append_wpa_key_mgmt
			key_mgmt="$wpa_key_mgmt"

			json_get_vars eap_type identity anonymous_identity ca_cert
			[ -n "$ca_cert" ] && append network_data "ca_cert=\"$ca_cert\"" "$N$T"
			[ -n "$identity" ] && append network_data "identity=\"$identity\"" "$N$T"
			[ -n "$anonymous_identity" ] && append network_data "anonymous_identity=\"$anonymous_identity\"" "$N$T"
			case "$eap_type" in
				tls)
					json_get_vars client_cert priv_key priv_key_pwd
					append network_data "client_cert=\"$client_cert\"" "$N$T"
					append network_data "private_key=\"$priv_key\"" "$N$T"
					append network_data "private_key_passwd=\"$priv_key_pwd\"" "$N$T"
				;;
				fast|peap|ttls)
					json_get_vars auth password ca_cert2 client_cert2 priv_key2 priv_key2_pwd
					set_default auth MSCHAPV2

					if [ "$auth" = "EAP-TLS" ]; then
						[ -n "$ca_cert2" ] &&
							append network_data "ca_cert2=\"$ca_cert2\"" "$N$T"
						append network_data "client_cert2=\"$client_cert2\"" "$N$T"
						append network_data "private_key2=\"$priv_key2\"" "$N$T"
						append network_data "private_key2_passwd=\"$priv_key2_pwd\"" "$N$T"
					else
						append network_data "password=\"$password\"" "$N$T"
					fi

					phase2proto="auth="
					case "$auth" in
						"auth"*)
							phase2proto=""
						;;
						"EAP-"*)
							auth="$(echo $auth | cut -b 5- )"
							[ "$eap_type" = "ttls" ] &&
								phase2proto="autheap="
						;;
					esac
					append network_data "phase2=\"$phase2proto$auth\"" "$N$T"
				;;
			esac
			append network_data "eap=$(echo $eap_type | tr 'a-z' 'A-Z')" "$N$T"
		;;
	esac

	[ "$mode" = mesh ] || {
		case "$wpa" in
			1)
				append network_data "proto=WPA" "$N$T"
			;;
			2)
				append network_data "proto=RSN" "$N$T"
			;;
		esac

		case "$ieee80211w" in
			[012])
				[ "$wpa" -ge 2 ] && append network_data "ieee80211w=$ieee80211w" "$N$T"
			;;
		esac
	}
	local beacon_int brates mrate
	[ -n "$bssid" ] && append network_data "bssid=$bssid" "$N$T"

	local bssid_blacklist bssid_whitelist
	json_get_values bssid_blacklist bssid_blacklist
	json_get_values bssid_whitelist bssid_whitelist

	[ -n "$bssid_blacklist" ] && append network_data "bssid_blacklist=$bssid_blacklist" "$N$T"
	[ -n "$bssid_whitelist" ] && append network_data "bssid_whitelist=$bssid_whitelist" "$N$T"

	[ -n "$basic_rate" ] && {
		local br rate_list=
		for br in $basic_rate; do
			wpa_supplicant_add_rate rate_list "$br"
		done
		[ -n "$rate_list" ] && append network_data "rates=$rate_list" "$N$T"
	}

	[ -n "$mcast_rate" ] && {
		local mc_rate=
		wpa_supplicant_add_rate mc_rate "$mcast_rate"
		append network_data "mcast_rate=$mc_rate" "$N$T"
	}

	local ht_str
	[[ "$_w_mode" = adhoc ]] || ibss_htmode=
	[ -n "$ibss_htmode" ] && append network_data "htmode=$ibss_htmode" "$N$T"

	[ -n "$ssid" ] && {
		cat >> "$_config" <<EOF
network={
	$scan_ssid
	ssid="$ssid"
	key_mgmt=$key_mgmt
	$network_data
}
EOF
	}
	return 0
}

wpa_supplicant_run() {
	local ifname="$1"; shift

	_wpa_supplicant_common "$ifname"

	[ -f "/var/run/wpa_supplicant-${ifname}.pid" ] && [ kill `cat "/var/run/wpa_supplicant-${ifname}.pid"` >/dev/null 2>&1 ]
	kill `ps -w | grep wpa_supplicant | grep ${ifname} | awk '{print $1;}' ` >/dev/null 2>&1

	/usr/sbin/wpa_supplicant -B \
		${network_bridge:+-b $network_bridge} \
		-P "/var/run/wpa_supplicant-${ifname}.pid" \
		-D ${_w_driver:-wext} \
		-i "$ifname" \
		-c "$_config" \
		-C "$_rpath" \
		"$@"

	ret="$?"
	wireless_add_process "$(cat "/var/run/wpa_supplicant-${ifname}.pid")" /usr/sbin/wpa_supplicant 1

	[ "$ret" != 0 ] && wireless_setup_vif_failed WPA_SUPPLICANT_FAILED

	return $ret
}

hostapd_common_cleanup() {
	killall hostapd wpa_supplicant meshd-nl80211
}
