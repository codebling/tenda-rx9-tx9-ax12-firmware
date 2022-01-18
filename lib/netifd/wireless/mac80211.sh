#!/bin/sh
. /lib/netifd/netifd-wireless.sh
. /lib/netifd/hostapd.sh

init_wireless_driver "$@"

MP_CONFIG_INT="mesh_retry_timeout mesh_confirm_timeout mesh_holding_timeout mesh_max_peer_links
	       mesh_max_retries mesh_ttl mesh_element_ttl mesh_hwmp_max_preq_retries
	       mesh_path_refresh_time mesh_min_discovery_timeout mesh_hwmp_active_path_timeout
	       mesh_hwmp_preq_min_interval mesh_hwmp_net_diameter_traversal_time mesh_hwmp_rootmode
	       mesh_hwmp_rann_interval mesh_gate_announcements mesh_sync_offset_max_neighor
	       mesh_rssi_threshold mesh_hwmp_active_path_to_root_timeout mesh_hwmp_root_interval
	       mesh_hwmp_confirmation_interval mesh_awake_window mesh_plink_timeout"
MP_CONFIG_BOOL="mesh_auto_open_plinks mesh_fwding"
MP_CONFIG_STRING="mesh_power_mode"

drv_mac80211_init_ax_config() {
	config_add_int sDynamicMuTypeDownLink
	config_add_int sDynamicMuTypeUpLink
	config_add_int he_su_beamformer
	config_add_int he_su_beamformee
	config_add_int he_mu_beamformer
	config_add_int he_bss_color
	config_add_int he_operation_bss_color_disabled
	config_add_int he_default_pe_duration
	config_add_int he_twt_required
	config_add_int he_rts_threshold
	config_add_int he_oper_chwidth
	config_add_int he_oper_centr_freq_seg0_idx
	config_add_int he_oper_centr_freq_seg1_idx
	config_add_int he_basic_mcs_nss_set
	config_add_int he_mu_edca_qos_info_param_count
	config_add_int he_mu_edca_qos_info_q_ack
	config_add_int he_mu_edca_qos_info_queue_request
	config_add_int he_mu_edca_qos_info_txop_request
	config_add_int he_mu_edca_ac_be_aifsn
	config_add_int he_mu_edca_ac_be_ecwmin
	config_add_int he_mu_edca_ac_be_ecwmax
	config_add_int he_mu_edca_ac_be_timer
	config_add_int he_mu_edca_ac_bk_aifsn
	config_add_int he_mu_edca_ac_bk_aci
	config_add_int he_mu_edca_ac_bk_ecwmin
	config_add_int he_mu_edca_ac_bk_ecwmax
	config_add_int he_mu_edca_ac_bk_timer
	config_add_int he_mu_edca_ac_vi_ecwmin
	config_add_int he_mu_edca_ac_vi_ecwmax
	config_add_int he_mu_edca_ac_vi_aifsn
	config_add_int he_mu_edca_ac_vi_aci
	config_add_int he_mu_edca_ac_vi_timer
	config_add_int he_mu_edca_ac_vo_aifsn
	config_add_int he_mu_edca_ac_vo_aci
	config_add_int he_mu_edca_ac_vo_ecwmin
	config_add_int he_mu_edca_ac_vo_ecwmax
	config_add_int he_mu_edca_ac_vo_timer
	config_add_int he_spr_sr_control
	config_add_int he_spr_non_srg_obss_pd_max_offset
	config_add_int he_spr_srg_obss_pd_min_offset
	config_add_int he_spr_srg_obss_pd_max_offset
	config_add_int multibss_enable
}

drv_mac80211_init_device_config() {
	hostapd_common_add_device_config
	drv_mac80211_init_ax_config

	config_add_string path phy 'macaddr:macaddr'
	config_add_string hwmode band atf_config_file
	config_add_string acs_smart_info_file acs_history_file
	config_add_int beacon_int chanbw frag rts dfs_debug_chan externally_managed testbed_mode
	config_add_int rxantenna txantenna txpower distance sFixedLtfGi
	config_add_array ht_capab
	config_add_array channels acs_fallback_chan chanlist
	config_add_boolean \
		rxldpc \
		short_gi_80 \
		short_gi_160 \
		tx_stbc_2by1 \
		su_beamformer \
		su_beamformee \
		mu_beamformer \
		mu_beamformee \
		vht_txop_ps \
		htc_vht \
		rx_antenna_pattern \
		tx_antenna_pattern
	config_add_int vht_max_a_mpdu_len_exp vht_max_mpdu vht_link_adapt vht160 rx_stbc tx_stbc
	config_add_boolean \
		ldpc \
		greenfield \
		short_gi_20 \
		short_gi_40 \
		max_amsdu \
		dsss_cck_40
	config_add_boolean atf
	config_add_int atf_interval atf_free_time atf_debug
	config_add_int obss_interval ignore_40_mhz_intolerant
	config_add_boolean full_ch_master_control
	config_add_string ap_retry_limit

	if [ -f /lib/netifd/debug_infrastructure.sh ]; then
		config_add_string hostapd_log_level
		debug_infrastructure_config_add_string debug_iw_pre_up_
		debug_infrastructure_config_add_string debug_iw_post_up_
	fi
}

drv_mac80211_init_iface_config() {
	hostapd_common_add_bss_config

	config_add_string 'macaddr:macaddr' ifname

	config_add_boolean wds powersave
	config_add_int maxassoc
	config_add_int max_listen_int
	config_add_int dtim_period
	config_add_int start_disabled
	config_add_int atf_vap_grant
	config_add_array 'atf_sta_grants:list(macaddr,int)'
	config_add_string vendor_elems

	# mesh
	config_add_string mesh_id
	config_add_int $MP_CONFIG_INT
	config_add_boolean $MP_CONFIG_BOOL
	config_add_string $MP_CONFIG_STRING

	# td add start
	config_add_boolean ssid_isolate
	config_add_boolean sreliablemcast
	# td add end
}

mac80211_append_ax_parameters() {
	if [ "$ieee80211ax" = "1" ]; then

		json_get_vars \
			sDynamicMuTypeDownLink \
			sDynamicMuTypeUpLink \
			he_su_beamformer \
			he_su_beamformee \
			he_mu_beamformer \
			he_bss_color \
			he_operation_bss_color_disabled \
			he_default_pe_duration \
			he_twt_required \
			he_rts_threshold \
			he_oper_chwidth \
			he_oper_centr_freq_seg0_idx \
			he_oper_centr_freq_seg1_idx \
			he_basic_mcs_nss_set \
			he_mu_edca_qos_info_param_count \
			he_mu_edca_qos_info_q_ack \
			he_mu_edca_qos_info_queue_request \
			he_mu_edca_qos_info_txop_request \
			he_mu_edca_ac_be_aifsn \
			he_mu_edca_ac_be_ecwmin \
			he_mu_edca_ac_be_ecwmax \
			he_mu_edca_ac_be_timer \
			he_mu_edca_ac_bk_aifsn \
			he_mu_edca_ac_bk_aci \
			he_mu_edca_ac_bk_ecwmin \
			he_mu_edca_ac_bk_ecwmax \
			he_mu_edca_ac_bk_timer \
			he_mu_edca_ac_vi_ecwmin \
			he_mu_edca_ac_vi_ecwmax \
			he_mu_edca_ac_vi_aifsn \
			he_mu_edca_ac_vi_aci \
			he_mu_edca_ac_vi_timer \
			he_mu_edca_ac_vo_aifsn \
			he_mu_edca_ac_vo_aci \
			he_mu_edca_ac_vo_ecwmin \
			he_mu_edca_ac_vo_ecwmax \
			he_mu_edca_ac_vo_timer \
			he_spr_sr_control \
			he_spr_non_srg_obss_pd_max_offset \
			he_spr_srg_obss_pd_min_offset \
			he_spr_srg_obss_pd_max_offset \
			multibss_enable

		append base_cfg "ieee80211ax=$ieee80211ax" "$N"
		[ -n "$multibss_enable" ] && append base_cfg "multibss_enable=$multibss_enable" "$N"
		[ -n "$sDynamicMuTypeDownLink" ] && append base_cfg "sDynamicMuTypeDownLink=$sDynamicMuTypeDownLink" "$N"
		[ -n "$sDynamicMuTypeUpLink" ] && append base_cfg "sDynamicMuTypeUpLink=$sDynamicMuTypeUpLink" "$N"
		[ -n "$he_su_beamformer" ] && append base_cfg "he_su_beamformer=$he_su_beamformer" "$N"
		[ -n "$he_su_beamformee" ] && append base_cfg "he_su_beamformee=$he_su_beamformee" "$N"
		[ -n "$he_mu_beamformer" ] && append base_cfg "he_mu_beamformer=$he_mu_beamformer" "$N"
		[ -n "$he_bss_color" ] && append base_cfg "he_bss_color=$he_bss_color" "$N"
		[ -n "$he_operation_bss_color_disabled" ] && append base_cfg "he_operation_bss_color_disabled=$he_operation_bss_color_disabled" "$N"
		[ -n "$he_default_pe_duration" ] && append base_cfg "he_default_pe_duration=$he_default_pe_duration" "$N"
		[ -n "$he_twt_required" ] && append base_cfg "he_twt_required=$he_twt_required" "$N"
		[ -n "$he_rts_threshold" ] && append base_cfg "he_rts_threshold=$he_rts_threshold" "$N"
		[ -n "$he_oper_chwidth" ] && append base_cfg "he_oper_chwidth=$he_oper_chwidth" "$N"
		[ -n "$he_oper_centr_freq_seg0_idx" ] && append base_cfg "he_oper_centr_freq_seg0_idx=$he_oper_centr_freq_seg0_idx" "$N"
		[ -n "$he_oper_centr_freq_seg1_idx" ] && append base_cfg "he_oper_centr_freq_seg1_idx=$he_oper_centr_freq_seg1_idx" "$N"
		[ -n "$he_basic_mcs_nss_set" ] && append base_cfg "he_basic_mcs_nss_set=$he_basic_mcs_nss_set" "$N"
		[ -n "$he_mu_edca_qos_info_param_count" ] && append base_cfg "he_mu_edca_qos_info_param_count=$he_mu_edca_qos_info_param_count" "$N"
		[ -n "$he_mu_edca_qos_info_q_ack" ] && append base_cfg "he_mu_edca_qos_info_q_ack=$he_mu_edca_qos_info_q_ack" "$N"
		[ -n "$he_mu_edca_qos_info_queue_request" ] && append base_cfg "he_mu_edca_qos_info_queue_request=$he_mu_edca_qos_info_queue_request" "$N"
		[ -n "$he_mu_edca_qos_info_txop_request" ] && append base_cfg "he_mu_edca_qos_info_txop_request=$he_mu_edca_qos_info_txop_request" "$N"
		[ -n "$he_mu_edca_ac_be_aifsn" ] && append base_cfg "he_mu_edca_ac_be_aifsn=$he_mu_edca_ac_be_aifsn" "$N"
		[ -n "$he_mu_edca_ac_be_ecwmin" ] && append base_cfg "he_mu_edca_ac_be_ecwmin=$he_mu_edca_ac_be_ecwmin" "$N"
		[ -n "$he_mu_edca_ac_be_ecwmax" ] && append base_cfg "he_mu_edca_ac_be_ecwmax=$he_mu_edca_ac_be_ecwmax" "$N"
		[ -n "$he_mu_edca_ac_be_timer" ] && append base_cfg "he_mu_edca_ac_be_timer=$he_mu_edca_ac_be_timer" "$N"
		[ -n "$he_mu_edca_ac_bk_aifsn" ] && append base_cfg "he_mu_edca_ac_bk_aifsn=$he_mu_edca_ac_bk_aifsn" "$N"
		[ -n "$he_mu_edca_ac_bk_aci" ] && append base_cfg "he_mu_edca_ac_bk_aci=$he_mu_edca_ac_bk_aci" "$N"
		[ -n "$he_mu_edca_ac_bk_ecwmin" ] && append base_cfg "he_mu_edca_ac_bk_ecwmin=$he_mu_edca_ac_bk_ecwmin" "$N"
		[ -n "$he_mu_edca_ac_bk_ecwmax" ] && append base_cfg "he_mu_edca_ac_bk_ecwmax=$he_mu_edca_ac_bk_ecwmax" "$N"
		[ -n "$he_mu_edca_ac_bk_timer" ] && append base_cfg "he_mu_edca_ac_bk_timer=$he_mu_edca_ac_bk_timer" "$N"
		[ -n "$he_mu_edca_ac_vi_ecwmin" ] && append base_cfg "he_mu_edca_ac_vi_ecwmin=$he_mu_edca_ac_vi_ecwmin" "$N"
		[ -n "$he_mu_edca_ac_vi_ecwmax" ] && append base_cfg "he_mu_edca_ac_vi_ecwmax=$he_mu_edca_ac_vi_ecwmax" "$N"
		[ -n "$he_mu_edca_ac_vi_aifsn" ] && append base_cfg "he_mu_edca_ac_vi_aifsn=$he_mu_edca_ac_vi_aifsn" "$N"
		[ -n "$he_mu_edca_ac_vi_aci" ] && append base_cfg "he_mu_edca_ac_vi_aci=$he_mu_edca_ac_vi_aci" "$N"
		[ -n "$he_mu_edca_ac_vi_timer" ] && append base_cfg "he_mu_edca_ac_vi_timer=$he_mu_edca_ac_vi_timer" "$N"
		[ -n "$he_mu_edca_ac_vo_aifsn" ] && append base_cfg "he_mu_edca_ac_vo_aifsn=$he_mu_edca_ac_vo_aifsn" "$N"
		[ -n "$he_mu_edca_ac_vo_aci" ] && append base_cfg "he_mu_edca_ac_vo_aci=$he_mu_edca_ac_vo_aci" "$N"
		[ -n "$he_mu_edca_ac_vo_ecwmin" ] && append base_cfg "he_mu_edca_ac_vo_ecwmin=$he_mu_edca_ac_vo_ecwmin" "$N"
		[ -n "$he_mu_edca_ac_vo_ecwmax" ] && append base_cfg "he_mu_edca_ac_vo_ecwmax=$he_mu_edca_ac_vo_ecwmax" "$N"
		[ -n "$he_mu_edca_ac_vo_timer" ] && append base_cfg "he_mu_edca_ac_vo_timer=$he_mu_edca_ac_vo_timer" "$N"
		[ -n "$he_spr_sr_control" ] && append base_cfg "he_spr_sr_control=$he_spr_sr_control" "$N"
		[ -n "$he_spr_non_srg_obss_pd_max_offset" ] && append base_cfg "he_spr_non_srg_obss_pd_max_offset=$he_spr_non_srg_obss_pd_max_offset" "$N"
		[ -n "$he_spr_srg_obss_pd_min_offset" ] && append base_cfg "he_spr_srg_obss_pd_min_offset=$he_spr_srg_obss_pd_min_offset" "$N"
		[ -n "$he_spr_srg_obss_pd_max_offset" ] && append base_cfg "he_spr_srg_obss_pd_max_offset=$he_spr_srg_obss_pd_max_offset" "$N"

	fi
}

mac80211_add_capabilities() {
	local __var="$1"; shift
	local __mask="$1"; shift
	local __out= oifs

	oifs="$IFS"
	IFS=:
	for capab in "$@"; do
		set -- $capab

		[ "$(($4))" -gt 0 ] || continue
		[ "$(($__mask & $2))" -eq "$((${3:-$2}))" ] || continue
		__out="$__out[$1]"
	done
	IFS="$oifs"

	export -n -- "$__var=$__out"
}

get_ht_capab() {
	local ht_capab=

	if [ "$auto_channel" -gt 1 ]; then
		ht_capab="[HT40+][HT40-]"
	else
		case "$htmode" in
			VHT20|HT20) ;;
			HT40+|VHT40+) ht_capab="[HT40+]" ;;
			HT40-|VHT40-) ht_capab="[HT40-]" ;;
			*) # 80 or above, add HT40+ if channel allows it
				case "$channel" in
					8|9|10|11|12|13|40|48|56|64|104|112|120|128|136|144|153|161) ht_capab="[HT40-]" ;;
					165|14) ;; # 165 only support 20M
					*)   ht_capab="[HT40+]"
						case "$country" in 
							PE|LB|MK|AM|OM|LK|EG|JO|TN)
								if [ "$band" = "5GHz" ];then
									ht_capab=""
								fi
							;;
						esac
						;;

				esac
			;;
		esac
	fi

	echo "$ht_capab"
}

mac80211_hostapd_prepare_atf_config() {
	local config_file="$1"
	local atf_cfg=

	json_get_vars atf atf_interval atf_free_time atf_debug

	rm -f "$config_file"

	set_default atf_debug 0
	set_default atf 0
	set_default atf_interval 1000
	set_default atf_free_time 0
	append atf_cfg "debug=$atf_debug" "$N"
	append atf_cfg "distr_type=$atf" "$N"
	append atf_cfg "algo_type=1" "$N"
	append atf_cfg "vap_enabled=1" "$N"
	append atf_cfg "station_enabled=1" "$N"
	append atf_cfg "weighted_type=0" "$N"
	append atf_cfg "interval=$atf_interval" "$N"
	append atf_cfg "free_time=$atf_free_time" "$N"

	cat >> "$config_file" <<EOF
$atf_cfg

EOF
}

mac80211_hostapd_setup_base() {
	local phy="$1"

	json_select config
	json_get_vars band full_ch_master_control
	set_default full_ch_master_control 0

	[ "$auto_channel" -gt 0 ] && {
		channel=acs_smart
		json_get_values channel_list chanlist channels
		json_get_values acs_fallback_chan_list acs_fallback_chan
		
		case "$htmode" in
			auto)
				channel_bandwidth=Auto;;
			HT20|VHT20)
				channel_bandwidth=20MHz;;
			HT40*|VHT40)
				channel_bandwidth=40MHz;;
			HT80|VHT80)
				channel_bandwidth=80MHz;;
			HT160|VHT160)
				channel_bandwidth=160MHz
				case "$country" in
					ID|BO|PK|VE|BZ|BN|KP)
					channel_bandwidth=80MHz ;;
				esac
				;;
				
		esac
		
		case "$country" in 
			PE|LB|MK|AM|OM|LK|EG|JO|TN)
				channel_bandwidth=20MHz;;
		esac
			
	}

	json_get_values ht_capab

	ieee80211n=
	ieee80211ac=
	ieee80211ax=
	case "$hwmode" in
		ng|bgn|n) ieee80211n=1 ;;
		an) ieee80211n=1
			require_mode=n;;
		ac) ieee80211ac=1
			ieee80211n=1
			require_mode=ac;;
		nac|anac)
			ieee80211n=1
			ieee80211ac=1
		;;
		ax) ieee80211ax=1
			ieee80211n=0
			ieee80211ac=0
			require_mode=ax;;
		bgnax)
			ieee80211n=1
			ieee80211ax=1
		;;
		anacax)
			ieee80211n=1
			ieee80211ac=1
			ieee80211ax=1
		;;
	esac
	

	case "$hwmode" in
		*g*) hwmode=g ;;
		*b*) hwmode=b ;;
		*a*) hwmode=a ;;
	esac

	ht_capab=`get_ht_capab`

	[ -n "$ieee80211n" ] && {
		append base_cfg "ieee80211n=1" "$N"

		json_get_vars \
			ldpc:1 \
			greenfield:0 \
			short_gi_20:1 \
			short_gi_40:1 \
			tx_stbc:1 \
			rx_stbc:3 \
			max_amsdu:1 \
			dsss_cck_40:1

		ht_cap_mask=0
		for cap in $(iw phy "$phy" info | grep 'Capabilities:' | cut -d: -f2); do
			ht_cap_mask="$(($ht_cap_mask | $cap))"
		done

		cap_rx_stbc=$((($ht_cap_mask >> 8) & 3))
		[ "$rx_stbc" -lt "$cap_rx_stbc" ] && cap_rx_stbc="$rx_stbc"
		ht_cap_mask="$(( ($ht_cap_mask & ~(0x300)) | ($cap_rx_stbc << 8) ))"

		mac80211_add_capabilities ht_capab_flags $ht_cap_mask \
			LDPC:0x1::$ldpc \
			GF:0x10::$greenfield \
			SHORT-GI-20:0x20::$short_gi_20 \
			SHORT-GI-40:0x40::$short_gi_40 \
			TX-STBC:0x80::$tx_stbc \
			RX-STBC1:0x300:0x100:1 \
			RX-STBC12:0x300:0x200:1 \
			RX-STBC123:0x300:0x300:1 \
			MAX-AMSDU-7935:0x800::$max_amsdu \
			DSSS_CCK-40:0x1000::$dsss_cck_40

		ht_capab="$ht_capab$ht_capab_flags"
		[ -n "$ht_capab" ] && append base_cfg "ht_capab=$ht_capab" "$N"
	}

	enable_vht=0
	he_phy_channel_width_set=0
	if [ "$band" = "2.4GHz" ]; then
		if [ "$htmode" = "auto" ]; then
			htmode="HT40"
			obss_interval=300
			ignore_40_mhz_intolerant=0
		else
			obss_interval=0
			ignore_40_mhz_intolerant=1
		fi

		[ -n "$obss_interval" ] && append base_cfg "obss_interval=$obss_interval" "$N"
		[ -n "$ieee80211n" ] && enable_vht=1
		
		case "$htmode" in
			HT40*|VHT40*)
				he_phy_channel_width_set=1
			;;
		esac
		op_class=81
	fi

	[ -n "$ignore_40_mhz_intolerant" ] && append base_cfg "ignore_40_mhz_intolerant=$ignore_40_mhz_intolerant" "$N"

	# 802.11ac
	vht_oper_centr_freq_seg0_idx=0
	vht_oper_chwidth=0
	if [ "$band" = "5GHz" ] || [ "$band" = "6GHz" ]; then

		if [ "$band" = "5GHz" ]; then
			op_class=115
		fi
		if [ "$htmode" = "auto" ]; then
			htmode="VHT160"
			case "$channel" in
				132|136|140|144|149|153|157|161) htmode="VHT80" ;;
				165) htmode="VHT20" ;;
			esac
		fi

		[ "$ieee80211ax" = "1" ] && {
			case "$htmode" in
				HT40*) htmode="V${htmode}" ;;
			esac
		}

		case "$htmode" in
			VHT20|VHT40*)
				vht_oper_chwidth=0
				if [ "$htmode" = "VHT40+" ] || [ "$htmode" = "VHT40" ] || [ "$htmode" = "VHT40-" ]; then
					[ "$htmode" = "VHT40+" ] && vht_oper_centr_freq_seg0_idx=$($channel+2)
					[ "$htmode" = "VHT40-" ] && vht_oper_centr_freq_seg0_idx=$($channel-2)
					he_phy_channel_width_set=2
				fi

				if [ "$band" = "6GHz" ]; then
					if [ "$htmode" = VHT20 ]; then
						op_class=131
						vht_oper_centr_freq_seg0_idx=$channel
					else
						op_class=132
						case "$channel" in
							1|5) vht_oper_centr_freq_seg0_idx=3 ;;
							9|13) vht_oper_centr_freq_seg0_idx=11 ;;
							17|21) vht_oper_centr_freq_seg0_idx=19 ;;
							25|29) vht_oper_centr_freq_seg0_idx=27 ;;
							33|37) vht_oper_centr_freq_seg0_idx=35 ;;
							41|45) vht_oper_centr_freq_seg0_idx=43 ;;
							49|53) vht_oper_centr_freq_seg0_idx=51;;
							57|61) vht_oper_centr_freq_seg0_idx=59 ;;
							65|69) vht_oper_centr_freq_seg0_idx=67 ;;
							73|77) vht_oper_centr_freq_seg0_idx=75 ;;
							81|85) vht_oper_centr_freq_seg0_idx=83 ;;
							89|93) vht_oper_centr_freq_seg0_idx=91 ;;
							97|101) vht_oper_centr_freq_seg0_idx=99 ;;
							105|109) vht_oper_centr_freq_seg0_idx=107 ;;
							113|117) vht_oper_centr_freq_seg0_idx=115 ;;
							121|125) vht_oper_centr_freq_seg0_idx=123 ;;
							129|133) vht_oper_centr_freq_seg0_idx=131 ;;
							137|141) vht_oper_centr_freq_seg0_idx=139 ;;
							145|149) vht_oper_centr_freq_seg0_idx=147 ;;
							153|157) vht_oper_centr_freq_seg0_idx=155 ;;
							161|165) vht_oper_centr_freq_seg0_idx=163 ;;
							169|173) vht_oper_centr_freq_seg0_idx=171 ;;
							177|181) vht_oper_centr_freq_seg0_idx=179 ;;
							185|189) vht_oper_centr_freq_seg0_idx=187 ;;
							193|197) vht_oper_centr_freq_seg0_idx=195 ;;
							201|205) vht_oper_centr_freq_seg0_idx=203 ;;
							209|213) vht_oper_centr_freq_seg0_idx=211 ;;
							217|221) vht_oper_centr_freq_seg0_idx=219 ;;
							225|229) vht_oper_centr_freq_seg0_idx=227 ;;
						esac

					fi
				fi
			;;
			VHT80)
				vht_oper_chwidth=1
				if [ "$band" = "6GHz" ]; then
					op_class=133
					case "$channel" in
						1|5|9|13) vht_oper_centr_freq_seg0_idx=7 ;;
						17|21|25|29) vht_oper_centr_freq_seg0_idx=23 ;;
						33|37|41|45) vht_oper_centr_freq_seg0_idx=39 ;;
						49|53|57|61) vht_oper_centr_freq_seg0_idx=55 ;;
						65|69|73|77) vht_oper_centr_freq_seg0_idx=71 ;;
						81|85|89|93) vht_oper_centr_freq_seg0_idx=87 ;;
						97|101|105|109) vht_oper_centr_freq_seg0_idx=103 ;;
						113|117|121|125) vht_oper_centr_freq_seg0_idx=119 ;;
						129|133|137|141) vht_oper_centr_freq_seg0_idx=135 ;;
						145|149|153|157) vht_oper_centr_freq_seg0_idx=151 ;;
						161|165|169|173) vht_oper_centr_freq_seg0_idx=167 ;;
						177|181|185|189) vht_oper_centr_freq_seg0_idx=183 ;;
						193|197|201|205) vht_oper_centr_freq_seg0_idx=199 ;;
						209|213|217|221) vht_oper_centr_freq_seg0_idx=215 ;;
					esac
				else #means 5GHz
					case "$channel" in
						36|40|44|48) vht_oper_centr_freq_seg0_idx=42 ;;
						52|56|60|64) vht_oper_centr_freq_seg0_idx=58 ;;
						100|104|108|112) vht_oper_centr_freq_seg0_idx=106 ;;
						116|120|124|128) vht_oper_centr_freq_seg0_idx=122 ;;
						132|136|140|144) vht_oper_centr_freq_seg0_idx=138 ;;
						149|153|157|161) vht_oper_centr_freq_seg0_idx=155 ;;
					esac
				fi

				he_phy_channel_width_set=2
			;;
			VHT160)
				vht_oper_chwidth=2
				if [ "$band" = "6GHz" ]; then
					op_class=134
					case "$channel" in
						1|5|9|13|17|21|25|29) vht_oper_centr_freq_seg1_idx=15 ;;
						33|37|41|45|49|53|57|61) vht_oper_centr_freq_seg1_idx=47 ;;
						65|69|73|77|81|85|89|93) vht_oper_centr_freq_seg1_idx=79 ;;
						97|101|105|109|113|117|121|125) vht_oper_centr_freq_seg1_idx=111 ;;
						129|133|137|141|145|149|153|157) vht_oper_centr_freq_seg1_idx=143 ;;
						161|165|169|173|177|181|185|189) vht_oper_centr_freq_seg1_idx=175 ;;
						193|197|201|205|209|213|217|221) vht_oper_centr_freq_seg1_idx=207 ;;
					esac
					case "$channel" in
						1|5|9|13) vht_oper_centr_freq_seg0_idx=7 ;;
						17|21|25|29) vht_oper_centr_freq_seg0_idx=23 ;;
						33|37|41|45) vht_oper_centr_freq_seg0_idx=39 ;;
						49|53|57|61) vht_oper_centr_freq_seg0_idx=55 ;;
						65|69|73|77) vht_oper_centr_freq_seg0_idx=71 ;;
						81|85|89|93) vht_oper_centr_freq_seg0_idx=87 ;;
						97|101|105|109) vht_oper_centr_freq_seg0_idx=103 ;;
						113|117|121|125) vht_oper_centr_freq_seg0_idx=119 ;;
						129|133|137|141) vht_oper_centr_freq_seg0_idx=135 ;;
						145|149|153|157) vht_oper_centr_freq_seg0_idx=151 ;;
						161|165|169|173) vht_oper_centr_freq_seg0_idx=167 ;;
						177|181|185|189) vht_oper_centr_freq_seg0_idx=183 ;;
						193|197|201|205) vht_oper_centr_freq_seg0_idx=199 ;;
						209|213|217|221) vht_oper_centr_freq_seg0_idx=215 ;;
					esac
				else #means 5GHz
					case "$channel" in
						36|40|44|48|52|56|60|64) vht_oper_centr_freq_seg0_idx=50 ;;
						100|104|108|112|116|120|124|128) vht_oper_centr_freq_seg0_idx=114 ;;
					esac
				fi

				he_phy_channel_width_set=6
			;;
		esac
	fi

	append base_cfg "op_class=$op_class" "$N"
	[ "$ieee80211ax" = "1" ] &&  append base_cfg "he_phy_channel_width_set=$he_phy_channel_width_set" "$N"

	if [ -n "$ieee80211ac" ]; then
		if [ "$auto_channel" -gt 0 ]; then
			vht_oper_centr_freq_seg0_idx=0
			vht_oper_centr_freq_seg1_idx=0
		fi

		append base_cfg "vht_oper_chwidth=$vht_oper_chwidth" "$N"
		append base_cfg "vht_oper_centr_freq_seg0_idx=$vht_oper_centr_freq_seg0_idx" "$N"
		if [ "$band" = "6GHz" ]; then
			append base_cfg "vht_oper_centr_freq_seg1_idx=$vht_oper_centr_freq_seg1_idx" "$N"
		fi
		append base_cfg "ieee80211ac=1" "$N"
		append base_cfg "opmode_notif=1" "$N"
		enable_vht=1
	fi

	if [ "$enable_vht" != "0" ]; then
		json_get_vars \
			rxldpc:1 \
			short_gi_80:1 \
			short_gi_160:1 \
			tx_stbc_2by1:1 \
			su_beamformer:1 \
			su_beamformee:1 \
			mu_beamformer:1 \
			mu_beamformee:1 \
			vht_txop_ps:1 \
			htc_vht:1 \
			rx_antenna_pattern:1 \
			tx_antenna_pattern:1 \
			vht_max_a_mpdu_len_exp:7 \
			vht_max_mpdu:11454 \
			rx_stbc:4 \
			vht_link_adapt:3 \
			vht160:2

		vht_cap=0
		for cap in $(iw phy "$phy" info | awk -F "[()]" '/VHT Capabilities/ { print $2 }'); do
			vht_cap="$(($vht_cap | $cap))"
		done

		cap_rx_stbc=$((($vht_cap >> 8) & 7))
		[ "$rx_stbc" -lt "$cap_rx_stbc" ] && cap_rx_stbc="$rx_stbc"
		vht_cap="$(( ($vht_cap & ~(0x700)) | ($cap_rx_stbc << 8) ))"

		case "$vht_oper_chwidth" in
			0)
				short_gi_80=0
				short_gi_160=0
				vht160=0
			;;
			1)
				short_gi_160=0
				vht160=0
			;;
		esac

		mac80211_add_capabilities vht_capab $vht_cap \
			RXLDPC:0x10::$rxldpc \
			SHORT-GI-80:0x20::$short_gi_80 \
			SHORT-GI-160:0x40::$short_gi_160 \
			TX-STBC-2BY1:0x80::$tx_stbc_2by1 \
			VHT-TXOP-PS:0x200000::$vht_txop_ps \
			HTC-VHT:0x400000::$htc_vht \
			RX-STBC-1:0x700:0x100:1 \
			RX-STBC-12:0x700:0x200:1 \
			RX-STBC-123:0x700:0x300:1 \
			RX-STBC-1234:0x700:0x400:1 \

		# supported Channel widths
		vht160_hw=0
		[ "$(($vht_cap & 12))" -eq 4 -a 1 -le "$vht160" ] && \
			vht160_hw=1
		[ "$(($vht_cap & 12))" -eq 8 -a 2 -le "$vht160" ] && \
			vht160_hw=2
		[ "$vht160_hw" = 1 ] && vht_capab="$vht_capab[VHT160]"
		[ "$vht160_hw" = 2 ] && vht_capab="$vht_capab[VHT160-80PLUS80]"

		# maximum MPDU length
		vht_max_mpdu_hw=3895
		[ "$(($vht_cap & 3))" -ge 1 -a 7991 -le "$vht_max_mpdu" ] && \
			vht_max_mpdu_hw=7991
		[ "$(($vht_cap & 3))" -ge 2 -a 11454 -le "$vht_max_mpdu" ] && \
			vht_max_mpdu_hw=11454
		[ "$vht_max_mpdu_hw" != 3895 ] && \
			vht_capab="$vht_capab[MAX-MPDU-$vht_max_mpdu_hw]"

		# maximum A-MPDU length exponent
		vht_max_a_mpdu_len_exp_hw=0
		[ "$(($vht_cap & 58720256))" -ge 8388608 -a 1 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=1
		[ "$(($vht_cap & 58720256))" -ge 16777216 -a 2 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=2
		[ "$(($vht_cap & 58720256))" -ge 25165824 -a 3 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=3
		[ "$(($vht_cap & 58720256))" -ge 33554432 -a 4 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=4
		[ "$(($vht_cap & 58720256))" -ge 41943040 -a 5 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=5
		[ "$(($vht_cap & 58720256))" -ge 50331648 -a 6 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=6
		[ "$(($vht_cap & 58720256))" -ge 58720256 -a 7 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=7
		vht_capab="$vht_capab[MAX-A-MPDU-LEN-EXP$vht_max_a_mpdu_len_exp_hw]"

		# whether or not the STA supports link adaptation using VHT variant
		vht_link_adapt_hw=0
		[ "$(($vht_cap & 201326592))" -ge 134217728 -a 2 -le "$vht_link_adapt" ] && \
			vht_link_adapt_hw=2
		[ "$(($vht_cap & 201326592))" -ge 201326592 -a 3 -le "$vht_link_adapt" ] && \
			vht_link_adapt_hw=3
		[ "$vht_link_adapt_hw" != 0 ] && \
			vht_capab="$vht_capab[VHT-LINK-ADAPT-$vht_link_adapt_hw]"


		num_antennas_in_hex=`iw phy "$phy" info | grep Configured | awk '{print $4}' | tr -d '0' | tr -d 'x'`
		case "$num_antennas_in_hex" in
			[f]) sounding_dimension=4 ;;
			[7bde]) sounding_dimension=3 ;;
			[3569ac]) sounding_dimension=2 ;;
			[1248]) sounding_dimension=1 ;;
		esac

		[ -n "$vht_capab" ] && append base_cfg "vht_capab=$vht_capab" "$N"
	fi

	json_get_vars sFixedLtfGi
	[ -n "$sFixedLtfGi" ] && append base_cfg "sFixedLtfGi=$sFixedLtfGi" "$N"

	mac80211_append_ax_parameters

	[ "$auto_channel" -gt 0 ] && {
		json_get_vars acs_smart_info_file acs_history_file

		set_default acs_smart_info_file "/var/run/acs_smart_info_wlan${phy#phy}.txt"
		set_default acs_history_file "/var/run/acs_history_wlan${phy#phy}.txt"
		append base_cfg "acs_num_scans=1" "$N"
		append base_cfg "acs_smart_info_file=$acs_smart_info_file" "$N"
		append base_cfg "acs_history_file=$acs_history_file" "$N"
		append base_cfg "acs_bw_comparison=0" "$N"
		append base_cfg "acs_bw_threshold=80 80 80" "$N"

		[ "$band" = "2.4GHz" ] && {
			append base_cfg "acs_use24overlapped=1" "$N"
		}
		append base_cfg "acs_to_degradation=1 0 0 1 1 1 100" "$N"
		append base_cfg "obss_beacon_rssi_threshold=-60" "$N"
		append base_cfg "channel_bandwidth=$channel_bandwidth" "$N"
	}

	json_get_vars ap_retry_limit
	[ -n "$ap_retry_limit" ] && append base_cfg "ap_retry_limit=$ap_retry_limit" "$N"

	if [ -f /lib/netifd/debug_infrastructure.sh ]; then
		debug_infrastructure_json_get_vars debug_hostap_conf_
		debug_infrastructure_append debug_hostap_conf_ base_cfg
	fi

	hostapd_prepare_device_config "$hostapd_conf_file" nl80211
	cat >> "$hostapd_conf_file" <<EOF
${channel:+channel=$channel}
${channel_list:+chanlist=$channel_list}
${acs_fallback_chan_list:+acs_fallback_chan=$acs_fallback_chan_list}
$base_cfg

EOF
	mac80211_hostapd_prepare_atf_config "$hostapd_atf_conf_file"
	json_select ..
}

mac80211_hostapd_setup_atf_bss() {
	local config_file="$1"
	local ifname="$2"
	local atf_cfg=
	local sta_mac
	local sta_precent

	has_content=0
	json_get_vars atf_vap_grant
	json_get_values atf_sta_grants atf_sta_grants

	append atf_cfg "[$ifname]" "$N"
	for atf_sta_grant in $atf_sta_grants; do
		sta_mac=`echo ${atf_sta_grant} | cut -d"," -f1`
		sta_precent=`echo ${atf_sta_grant} | cut -d"," -f2`
		sta_precent=`expr $sta_precent \* 100` # Driver expects it to be multiplied by 100
		append atf_cfg "sta=$sta_mac,$sta_precent" "$N"
		has_content=1
	done
	[ -n "$atf_vap_grant" ] && {
		atf_vap_grant=`expr $atf_vap_grant \* 100` # Driver expects it to be multiplied by 100
		append atf_cfg "vap_grant=$atf_vap_grant" "$N"
		has_content=1
	}

	if [ $has_content -eq 0 ]; then # Prevent having an empty section
		return
	fi

	cat >> "$config_file" <<EOF
$atf_cfg

EOF
}

mac80211_hostapd_setup_bss() {
	local phy="$1"
	local ifname="$2"
	local macaddr="$3"
	local type="$4"

	hostapd_cfg=
	append hostapd_cfg "$type=$ifname" "$N"

	hostapd_set_bss_options hostapd_cfg "$vif" || return 1
	json_get_vars wds dtim_period max_listen_int start_disabled

	set_default wds 0
	set_default start_disabled 0

	[ "$wds" -gt 0 ] && append hostapd_cfg "wds_sta=1" "$N"
	[ "$staidx" -gt 0 -o "$start_disabled" -eq 1 ] && append hostapd_cfg "start_disabled=1" "$N"

	cat >> /var/run/hostapd-$phy.conf <<EOF
$hostapd_cfg
bssid=$macaddr
${dtim_period:+dtim_period=$dtim_period}
${max_listen_int:+max_listen_interval=$max_listen_int}
EOF

	mac80211_hostapd_setup_atf_bss "$hostapd_atf_conf_file" "$ifname"
}

mac80211_get_addr() {
	local phy="$1"
	local idx="$(($2 + 1))"

	head -n $(($macidx + 1)) /sys/class/ieee80211/${phy}/addresses | tail -n1
}

mac80211_generate_mac() {
	local phy="$1"
	local id="${macidx:-0}"

	local ref="$(cat /sys/class/ieee80211/${phy}/macaddress)"
	local mask="$(cat /sys/class/ieee80211/${phy}/address_mask)"

	[ "$mask" = "00:00:00:00:00:00" ] && {
		mask="ff:ff:ff:ff:ff:ff";

		[ "$(wc -l < /sys/class/ieee80211/${phy}/addresses)" -gt 1 ] && {
			addr="$(mac80211_get_addr "$phy" "$id")"
			[ -n "$addr" ] && {
				echo "$addr"
				return
			}
		}
	}

	local oIFS="$IFS"; IFS=":"; set -- $mask; IFS="$oIFS"

	local mask1=$1
	local mask6=$6

	local oIFS="$IFS"; IFS=":"; set -- $ref; IFS="$oIFS"

	macidx=$(($id + 1))
	[ "$((0x$mask1))" -gt 0 ] && {
		b1="0x$1"
		[ "$id" -gt 0 ] && \
			b1=$(($b1 ^ ((($id - 1) << 2) | 0x2)))
		printf "%02x:%s:%s:%s:%s:%s" $b1 $2 $3 $4 $5 $6
		return
	}

	[ "$((0x$mask6))" -lt 255 ] && {
		printf "%s:%s:%s:%s:%s:%02x" $1 $2 $3 $4 $5 $(( 0x$6 ^ $id ))
		return
	}

	off2=$(( (0x$6 + $id) / 0x100 ))
	printf "%s:%s:%s:%s:%02x:%02x" \
		$1 $2 $3 $4 \
		$(( (0x$5 + $off2) % 0x100 )) \
		$(( (0x$6 + $id) % 0x100 ))
}

find_phy() {
	[ -n "$phy" -a -d /sys/class/ieee80211/$phy ] && return 0
	[ -n "$path" ] && {
		for phy in $(ls /sys/class/ieee80211 2>/dev/null); do
			case "$(readlink -f /sys/class/ieee80211/$phy/device)" in
				*$path) return 0;;
			esac
		done
	}
	[ -n "$macaddr" ] && {
		for phy in $(ls /sys/class/ieee80211 2>/dev/null); do
			grep -i -q "$macaddr" "/sys/class/ieee80211/${phy}/macaddress" && return 0
		done
	}
	return 1
}

mac80211_check_ap() {
	has_ap=1
}

mac80211_custom_teardown_vif() {
	json_select config

	json_get_vars ifname mode sreliablemcast
	
	[ -n "$ifname" ] || ifname="wlan${phy#phy}${if_idx:+-$if_idx}"
	if_idx=$((${if_idx:-0} + 1))
	
	json_select ..

	json_add_object data
	json_add_string ifname "$ifname"
	json_close_object
	json_select config

	case "$mode" in
		ap)
			iw dev $ifname iwlwav sreliablemcast ${sreliablemcast:-0}
		;;
	esac

	json_select ..
}

mac80211_prepare_vif() {
	json_select config

	json_get_vars ifname mode ssid wds powersave macaddr ssid_isolate

	[ -n "$ifname" ] || ifname="wlan${phy#phy}${if_idx:+-$if_idx}"
	if_idx=$((${if_idx:-0} + 1))

	set_default wds 0
	set_default powersave 0

	# td add start
	set_default ssid_isolate 0
	# td add end

	json_select ..

	[ -n "$macaddr" ] || {
		macaddr="$(mac80211_generate_mac $phy)"
		macidx="$(($macidx + 1))"
	}

	json_add_object data
	json_add_string ifname "$ifname"
	json_close_object
	json_select config

	# It is far easier to delete and create the desired interface
	case "$mode" in
		adhoc)
			iw phy "$phy" interface add "$ifname" type adhoc
		;;
		ap)
			# Hostapd will handle recreating the interface and
			# subsequent virtual APs belonging to the same PHY
			if [ -n "$hostapd_ctrl" ]; then
				type=bss
			else
				type=interface
			fi

			mac80211_hostapd_setup_bss "$phy" "$ifname" "$macaddr" "$type" || return

			[ -n "$hostapd_ctrl" ] || {
				iw phy "$phy" interface add "$ifname" type __ap
				hostapd_ctrl="${hostapd_ctrl:-/var/run/hostapd/$ifname}"
			}

			# td add start
			[ $ssid_isolate -ne 0 ] && {
				ebtables -A "ISOLATE_${phy}" -i $ifname -o wlan+ -j DROP
			}			
			# td add end
		;;
		mesh)
			iw phy "$phy" interface add "$ifname" type mp
		;;
		monitor)
			iw phy "$phy" interface add "$ifname" type monitor
		;;
		sta)
			local wdsflag=
			staidx="$(($staidx + 1))"
			[ "$wds" -gt 0 ] && wdsflag="4addr on"
			[ -n "$hostapd_ctrl" ] || {
				local iface_num=${ifname#"wlan"}
				local master_num=$((iface_num-1))
				local master_iface="wlan$master_num"
				iw phy "$phy" interface add "$master_iface" type __ap
			}

			iw phy "$phy" interface add "$ifname" type managed $wdsflag
			[ "$powersave" -gt 0 ] && powersave="on" || powersave="off"
			iw "$ifname" set power_save "$powersave"
		;;
	esac

	case "$mode" in
		monitor|mesh)
			[ "$auto_channel" -gt 0 ] || iw dev "$ifname" set channel "$channel" $htmode
		;;
	esac

	if [ "$mode" != "ap" ]; then
		# ALL ap functionality will be passed to hostapd
		# All interfaces must have unique mac addresses
		# which can either be explicitly set in the device
		# section, or automatically generated
		ip link set dev "$ifname" address "$macaddr"
	fi

	json_select ..
}

mac80211_setup_supplicant() {
	wpa_supplicant_prepare_interface "$ifname" nl80211 || return 1
	wpa_supplicant_add_network "$ifname"
	[ "$full_ch_master_control" -gt 0 ] && full_ch_master="-F"
	wpa_supplicant_run "$ifname" ${hostapd_ctrl:+-H $hostapd_ctrl $full_ch_master}
}

mac80211_setup_adhoc_htmode() {
	case "$htmode" in
		VHT20|HT20) ibss_htmode=HT20;;
		HT40*|VHT40|VHT160)
			case "$hwmode" in
				a)
					case "$(( ($channel / 4) % 2 ))" in
						1) ibss_htmode="HT40+" ;;
						0) ibss_htmode="HT40-";;
					esac
				;;
				*)
					case "$htmode" in
						HT40+) ibss_htmode="HT40+";;
						HT40-) ibss_htmode="HT40-";;
						*)
							if [ "$channel" -lt 7 ]; then
								ibss_htmode="HT40+"
							else
								ibss_htmode="HT40-"
							fi
						;;
					esac
				;;
			esac
			[ "$auto_channel" -gt 0 ] && ibss_htmode="HT40+"
		;;
		VHT80)
			ibss_htmode="80MHZ"
		;;
		NONE|NOHT)
			ibss_htmode="NOHT"
		;;
		*) ibss_htmode="" ;;
	esac

}

mac80211_setup_adhoc() {
	json_get_vars bssid ssid key mcast_rate

	keyspec=
	[ "$auth_type" = "wep" ] && {
		set_default key 1
		case "$key" in
			[1234])
				local idx
				for idx in 1 2 3 4; do
					json_get_var ikey "key$idx"

					[ -n "$ikey" ] && {
						ikey="$(($idx - 1)):$(prepare_key_wep "$ikey")"
						[ $idx -eq $key ] && ikey="d:$ikey"
						append keyspec "$ikey"
					}
				done
			;;
			*)
				append keyspec "d:0:$(prepare_key_wep "$key")"
			;;
		esac
	}

	brstr=
	for br in $basic_rate_list; do
		wpa_supplicant_add_rate brstr "$br"
	done

	mcval=
	[ -n "$mcast_rate" ] && wpa_supplicant_add_rate mcval "$mcast_rate"

	iw dev "$ifname" ibss join "$ssid" $freq $ibss_htmode fixed-freq $bssid \
		beacon-interval $beacon_int \
		${brstr:+basic-rates $brstr} \
		${mcval:+mcast-rate $mcval} \
		${keyspec:+keys $keyspec}
}

mac80211_setup_vif() {
	local name="$1"
	local failed

	json_select data
	json_get_vars ifname
	json_select ..

	json_select config
	json_get_vars mode

	# try again if up wlanX fail.
#	ip link set dev "$ifname" up || sleep 3
	ip link set dev "$ifname" up || {
		wireless_setup_vif_failed IFUP_ERROR
		json_select ..
		return
	}

	case "$mode" in
		mesh)
			# authsae or wpa_supplicant
			json_get_vars key
			if [ -n "$key" ]; then
				if [ -e "/lib/wifi/authsae.sh" ]; then
					. /lib/wifi/authsae.sh
					authsae_start_interface || failed=1
				else
					wireless_vif_parse_encryption
					mac80211_setup_supplicant || failed=1
				fi
			else
				json_get_vars mesh_id mcast_rate

				mcval=
				[ -n "$mcast_rate" ] && wpa_supplicant_add_rate mcval "$mcast_rate"

				case "$htmode" in
					VHT20|HT20) mesh_htmode=HT20;;
					HT40*|VHT40)
						case "$hwmode" in
							a)
								case "$(( ($channel / 4) % 2 ))" in
									1) mesh_htmode="HT40+" ;;
									0) mesh_htmode="HT40-";;
								esac
							;;
							*)
								case "$htmode" in
									HT40+) mesh_htmode="HT40+";;
									HT40-) mesh_htmode="HT40-";;
									*)
										if [ "$channel" -lt 7 ]; then
											mesh_htmode="HT40+"
										else
											mesh_htmode="HT40-"
										fi
									;;
								esac
							;;
						esac
					;;
					VHT80)
						mesh_htmode="80Mhz"
					;;
					VHT160)
						mesh_htmode="160Mhz"
					;;
					*) mesh_htmode="NOHT" ;;
				esac

				freq="$(get_freq "$phy" "$channel")"
				iw dev "$ifname" mesh join "$mesh_id" freq $freq $mesh_htmode \
					${mcval:+mcast-rate $mcval} \
					beacon-interval $beacon_int
			fi

			for var in $MP_CONFIG_INT $MP_CONFIG_BOOL $MP_CONFIG_STRING; do
				json_get_var mp_val "$var"
				[ -n "$mp_val" ] && iw dev "$ifname" set mesh_param "$var" "$mp_val"
			done
		;;
		adhoc)
			wireless_vif_parse_encryption
			mac80211_setup_adhoc_htmode
			if [ "$wpa" -gt 0 -o "$auto_channel" -gt 0 ]; then
				mac80211_setup_supplicant || failed=1
			else
				mac80211_setup_adhoc
			fi
		;;
		sta)
			mac80211_setup_supplicant || failed=1
		;;
	esac

	json_select ..
	[ -n "$failed" ] || wireless_add_vif "$name" "$ifname"
}

get_freq() {
	local phy="$1"
	local chan="$2"
	iw "$phy" info | grep -E -m1 "(\* ${chan:-....} MHz${chan:+|\\[$chan\\]})" | grep MHz | awk '{print $2}'
}

mac80211_interface_cleanup() {
	local phy="$1"

	for wdev in $(list_phy_interfaces "$phy"); do
		local interface_idx="${wdev:4:1}"
		local phy_idx="${phy:3:1}"
		phy_idx="$((phy_idx*2))"
		if [ "$interface_idx" = "$phy_idx" ]; then
			ip link set dev "$wdev" down 2>/dev/null
		fi
		#iw dev "$wdev" del
	done
}

drv_mac80211_cleanup() {
	hostapd_common_cleanup
}

drv_mac80211_setup_phy() {
	local phys=$(ls /sys/class/ieee80211/)
	local path_5g=`uci show | grep "5GHz" | awk -F"." '{print $1 "." $2}' | awk -v RS=  '{$1=$1}1'`
	local path_6g=`uci show | grep "6GHz" | awk -F"." '{print $1 "." $2}' | awk -v RS=  '{$1=$1}1'`
	local path_24g=`uci show | grep "2.4GHz" | awk -F"." '{print $1 "." $2}' | awk -v RS=  '{$1=$1}1'`
	local idx_5g=1
	local idx_6g=1
	local idx_24g=1

	for phy in $phys
	do
		`iw $phy info | grep "* 58.. MHz" > /dev/null`
		is_phy_5g=$?
		`iw $phy info | grep "* 59.. MHz" > /dev/null`
		is_phy_6g=$?

		if [ $is_phy_5g = '0' ]; then
			local path=`echo "$path_5g" | awk -v idx_5g="$idx_5g" '{print $idx_5g}'`
			idx_5g=$((idx_5g+1))
		elif [ $is_phy_6g = '0' ]; then
			local path=`echo "$path_6g" | awk -v idx_6g="$idx_6g" '{print $idx_6g}'`
			idx_6g=$((idx_6g+1))
		else
			local path=`echo "$path_24g" | awk -v idx_24g="$idx_24g" '{print $idx_24g}'`
			idx_24g=$((idx_24g+1))
		fi

		uci set $path.phy=$phy
	done

	uci commit wireless
}

check_repeater_mode() {
	if [ "$band" = "5GHz" ]; then
		channel=36
	else
		channel=1
	fi

	set_default ignore_40_mhz_intolerant 1
}

setup_reconf() {
	json_select config
	json_get_vars \
		phy macaddr path \
		country chanbw distance \
		txpower \
		rxantenna txantenna \
		frag rts beacon_int:100 htmode atf_config_file \
		obss_interval ignore_40_mhz_intolerant

	if [ -f /lib/netifd/debug_infrastructure.sh ]; then
		json_get_vars hostapd_log_level
		debug_infrastructure_json_get_vars debug_iw_pre_up_
		debug_infrastructure_json_get_vars debug_iw_post_up_
	fi

	json_get_values basic_rate_list basic_rate
	json_select ..

	local action="$1"; shift

	find_phy || {
		echo "Could not find PHY for device '$1'"
		wireless_set_retry 0
		return 1
	}

	wireless_set_data phy="$phy"

	if [ "$action" = "setup" ]; then
		mac80211_interface_cleanup "$phy"
	fi

	# convert channel to frequency
	[ "$auto_channel" -gt 0 ] || freq="$(get_freq "$phy" "$channel")"

	[ -n "$country" ] && {
		iw reg get | grep -q "^country $country:" || {
			iw reg set "$country"
			sleep 1
		}
	}

	which flock > /dev/null 2>&1
	local which_ret=$?
	if [ $which_ret -eq 0 ]; then
		local lock_attempts_left=5
		local lock_file="/tmp/lock_file_$phy"
		exec 222>$lock_file
		flock -n 222
		local flock_ret=$?

		while [[ $flock_ret -ne 0 && $lock_attempts_left -gt 0 ]]; do
			sleep 1
			flock -n 222
			flock_ret=$?
			lock_attempts_left=$((lock_attempts_left-1))
		done

		if [ $lock_attempts_left -le 0 ]; then
			exit 1
		fi
	else
		/usr/bin/logger -t HOSTAPD_CONF -p 3 "flock isn't found..."
		/usr/bin/logger -t HOSTAPD_CONF -p 3 "...Big probability of race condition"
	fi

	set_default atf_config_file "/var/run/hostapd-$phy-atf.conf"
	hostapd_conf_file="/var/run/hostapd-$phy.conf"
	hostapd_atf_conf_file="$atf_config_file"

	no_ap=1
	macidx=0
	staidx=0

	[ -n "$chanbw" ] && {
		for file in /sys/kernel/debug/ieee80211/$phy/ath9k/chanbw /sys/kernel/debug/ieee80211/$phy/ath5k/bwmode; do
			[ -f "$file" ] && echo "$chanbw" > "$file"
		done
	}

	# td add start
	ebtables -L | grep -q "ISOLATE_${phy}" || {
		ebtables -N "ISOLATE_${phy}"
		ebtables -A FORWARD -j "ISOLATE_${phy}"
	}
	# td add end

	set_default rxantenna all
	set_default txantenna all
	set_default distance 0

	iw phy "$phy" set antenna $txantenna $rxantenna >/dev/null 2>&1
	iw phy "$phy" set distance "$distance"

	[ -n "$frag" ] && iw phy "$phy" set frag "${frag%%.*}"
	[ -n "$rts" ] && iw phy "$phy" set rts "${rts%%.*}"

	has_ap=
	hostapd_ctrl=
	for_each_interface "ap" mac80211_check_ap

	rm -f "$hostapd_conf_file"

	if [ "$action" = "setup" ]; then
		for_each_interface "sta" check_repeater_mode
	fi

	[ -n "$has_ap" ] && mac80211_hostapd_setup_base "$phy"

	if [ "$action" = "setup" ]; then
		for_each_interface "sta adhoc mesh monitor" mac80211_prepare_vif
	fi

	for_each_interface "ap" mac80211_prepare_vif

	case "$action" in
		reconf)
			local reconf_vap="$2"
			local reconf_radio_index=$(echo "$1" | tr -dc '0-9')
			local reconf_radio="wlan$reconf_radio_index"

			[ -n "$hostapd_ctrl" ] && {
				if [ "$reconf_vap" = "$reconf_radio" ]; then
					/usr/sbin/hostapd_cli -i${reconf_radio} reconf
				else
					/usr/sbin/hostapd_cli -i${reconf_radio} reconf ${reconf_vap}
				fi

				ret="$?"
				[ "$ret" != 0 ] && {
					echo "[MAC]: reconf failed"
					wireless_setup_failed HOSTAPD_RECONF_FAILED
					return
				}
			}
		;;
		setup)
			[ -n "$hostapd_ctrl" ] && {
				radio_index=$(echo "$1" | tr -dc '0-9')
				if [ -f /lib/netifd/debug_infrastructure.sh ]; then
					debug_infrastructure_execute_iw_command debug_iw_pre_up_ $radio_index
				fi

				/usr/sbin/hostapd -s"$hostapd_log_level" -P /var/run/wifi-$phy.pid -B "$hostapd_conf_file"
				ret="$?"

				[ "$ret" != 0 ] && {
					echo "[MAC]: setup failed"
					wireless_setup_failed HOSTAPD_START_FAILED
					return
				}

				retry_count=0
				hostapd_pid=
				until [ $retry_count -ge 5 ]
				do
					hostapd_pid=`cat /var/run/wifi-$phy.pid`
					if [ -n "$hostapd_pid" ]; then
						break;
					fi
					retry_count=$((retry_count+1))
					sleep 1
				done
				[ ! -n "$hostapd_pid" ] && {
					wireless_setup_failed HOSTAPD_START_FAILED
					return
				}
				
				# td add start
				ifname=$(cat "$hostapd_conf_file" |grep '^interface='|cut -d= -f2)
				ppacmd addlan -i $ifname
				# td add end

				wireless_add_process "$hostapd_pid" "/usr/sbin/hostapd" 1
				
				# td acs schedule start
				bss_name=$(cat "$hostapd_conf_file" |grep '^bss='|head -1 |cut -d= -f2)
				if [ $bss_name == "wlan0.1" ] || [ $bss_name == "wlan2.1" ];then 
				    crontab /etc/sh/hostapd_acs_schedule
					/etc/init.d/cron start
				fi
				# td acs schedule stop
				iw dev wlan0 iwlwav sBfMode 4
				iw dev wlan2 iwlwav sBfMode 4

				if [ -f /lib/netifd/debug_infrastructure.sh ]; then
					debug_infrastructure_execute_iw_command debug_iw_post_up_ $radio_index
				fi
			}
		;;
		*)
			echo "Unknown action: \"$action\". Doing nothng"
		;;
	esac

	if [ $which_ret -eq 0 ]; then
		flock -u 222
	fi

	for_each_interface "ap" mac80211_setup_vif

	if [ "$action" = "setup" ]; then
		for_each_interface "sta adhoc mesh monitor" mac80211_setup_vif
		wireless_set_up
	fi
}

drv_mac80211_setup() {
	setup_reconf "setup" "$@"
}

drv_mac80211_reconf() {
	setup_reconf "reconf" "$@"
}

list_phy_interfaces() {
	local phy="$1"
	if [ -d "/sys/class/ieee80211/${phy}/device/net" ]; then
		ls "/sys/class/ieee80211/${phy}/device/net" 2>/dev/null;
	else
		ls "/sys/class/ieee80211/${phy}/device" 2>/dev/null | grep net: | sed -e 's,net:,,g'
	fi
}

drv_mac80211_teardown() {
	wireless_process_kill_all

	json_select data
	json_get_vars phy
	json_select ..

	mac80211_interface_cleanup "$phy"

	# td add start
	ebtables -F "ISOLATE_${phy}" > /dev/null 2>&1

	for_each_interface "ap" mac80211_custom_teardown_vif
	# td add end

	#clear td acs schedule 
	sed -i '/iw_scan.sh/d' /etc/crontabs/root
}

add_driver mac80211
