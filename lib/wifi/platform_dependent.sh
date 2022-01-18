#!/bin/sh

export OS_NAME="UGW"
export BINDIR="/opt/intel/bin"
export SCRIPTS_PATH="/opt/intel/wave/scripts"
export ETC_CONFIG_WIRELESS_PATH="/etc/config/wireless"
export DEV_CREAT_PATH="/dev"
export DEFAULT_DB_PATH="/opt/intel/wave/db"
export UCI_DB_PATH="/etc/config"
export BUSYBOX_BIN_PATH="/bin"
export NC_COMMAND="/bin/lite_nc"
export WAVE_COMPONENTS_PATH="/etc"
export CAL_FILES_PATH="/tmp/wlanconfig"


#functions

UCI=uci_parser

function uci_set_helper(){
        if [ "$2" = "$tmp_wireless" ] || [ "$2" = "$tmp_meta" ]; then
               uci_set_helper_ubus "$@"
        else
             echo "$1" >> "$2"
        fi
}

function use_template(){
        use_template_single "$@"
}

function update_mac_address_if_needed(){
        do_update_mac_address "$@"
}

function init_prog(){
        PROG="ugw"
}

function meta_factory_init(){
        :
}

function get_is_zwdfs(){
        get_is_zwdfs_device "$@"
}

function remove_dfs_state_file(){
        remove_dfs_state_file_device "$@"
}

function is_station_supported(){
        is_station_supported_device "$@"
}

function print_logs(){
        echo "$1" >/dev/console
}

clean_uci_cache(){
        ubus call uci revert '{ "config" : "wireless"}' > /dev/null 2>&1
}

clean_uci_db(){
        local wireless=`cat "$UCI_DB_PATH/wireless"`
        local old_ifs;

        old_ifs=$IFS
        IFS=$'\n'
        for line in $wireless; do
                if [ ""`echo "$line" | cut -f 1 -d " "` = "config" ]; then
                        current_iface=`echo "$line" | cut -f 3 -d " " | tr -d "'"`
                        ubus call uci delete '{ "config" : "wireless", "section" : "'$current_iface'" }'
                fi
        done
        IFS=$old_ifs
}

prepare_vars(){
        phys=`ls /sys/class/ieee80211/`
}

get_iface_idx(){
        get_iface_idx_on_device "$@"
}

get_band(){
        get_band_on_device "$@"
}

set_mac_address(){
        set_mac_address_on_device "$@"
}

get_board(){
        get_board_on_device "$@"
}

use_templates(){
        use_template $1 $3 1
        use_template $1 $2 0
}

use_templates_tmp_file(){
        use_template $1 $2 0
}

prepare_meta_data_radio(){
        :
}

prepare_meta_data_default_radio(){
        :
}

commit_changes(){
        $UCI commit wireless
}
