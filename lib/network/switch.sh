#!/bin/sh
#port LAN1 5 0x20
#port LAN2 4 0x10
#port LAN3 3 0x08
#port WAN 15 0x8000

setup_tag_mde(){
	local port=$1
	local portmap=$2
	local vlanid=$3
	
	switch_cli dev=1 GSW_CFG_SET bVLAN_Aware=0x1
	switch_cli dev=1 GSW_VLAN_ID_CREATE nVId=$vlanid nFId=1

	switch_cli dev=1 GSW_VLAN_PORT_CFG_SET nPortId=$port nPortVId=$vlanid eVLAN_MemberViolation=0 eAdmitMode=0 bTVM=1
	switch_cli dev=1 GSW_VLAN_PORT_MEMBER_ADD nPortId=$port nVId=$vlanid bVLAN_TagEgress=0

	switch_cli dev=1 GSW_PCE_EG_VLAN_CFG_SET nPortId=15 bEgVidEna=1 eEgVLANmode=0 nEgStartVLANIdx=160
	switch_cli dev=1 GSW_PCE_EG_VLAN_ENTRY_WRITE nPortId=15 nIndex=160 bEgVLAN_Action=1 bEgSVidRem_Action=0 bEgCVidRem_Action=0 bEgSVidIns_Action=0 bEgCVidIns_Action=0
	switch_cli dev=1 GSW_PCE_EG_VLAN_ENTRY_WRITE nPortId=15 nIndex=161 bEgVLAN_Action=1 bEgSVidRem_Action=0 bEgCVidRem_Action=0 bEgSVidIns_Action=0 bEgCVidIns_Action=1 nEgCVid=$vlanid
	
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=5 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port action.ePortMapAction=4 action.nForwardPortMap=0x8000 action.bRMON_Action=1 action.nRMON_Id=5
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=6 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15 pattern.bVid=1 pattern.nVid=$vlanid action.ePortMapAction=4 action.nForwardPortMap=$portmap action.bRMON_Action=1 action.nRMON_Id=6
	switch_cli dev=1 GSW_SVLAN_PORT_CFG_SET nPortId=15 bSVLAN_TagSupport=0
	switch_cli dev=0 GSW_MAC_TABLE_CLEAR
}

setup_tranparent_mode(){
	local port=$1
	local portmap=$2
	#Enable Port VLAN aware on Port 5 and 15
	switch_cli dev=1 GSW_VLAN_PORT_CFG_SET nPortId=$port bTVM=1
	switch_cli dev=1 GSW_VLAN_PORT_CFG_SET nPortId=15 bTVM=1

	switch_cli dev=1 GSW_SVLAN_PORT_CFG_SET nPortId=15 bSVLAN_TagSupport=0
	switch_cli dev=1 GSW_SVLAN_PORT_CFG_SET nPortId=$port bSVLAN_TagSupport=0
	
	#Upstream bind Port 15 PCP 0~7 forward to Port 5
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=141 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=0 Action.ePortMapAction=4 action.nForwardPortMap=$portmap
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=142 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=1 Action.ePortMapAction=4 action.nForwardPortMap=$portmap
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=143 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=2 Action.ePortMapAction=4 action.nForwardPortMap=$portmap
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=144 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=3 Action.ePortMapAction=4 action.nForwardPortMap=$portmap
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=145 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=4 Action.ePortMapAction=4 action.nForwardPortMap=$portmap
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=146 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=5 Action.ePortMapAction=4 action.nForwardPortMap=$portmap
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=147 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=6 Action.ePortMapAction=4 action.nForwardPortMap=$portmap
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=148 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=15  pattern.bPCP_Enable=1 pattern.nPCP=7 Action.ePortMapAction=4 action.nForwardPortMap=$portmap

	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=151 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=0 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=152 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=1 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=153 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=2 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=154 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=3 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=155 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=4 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=156 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=5 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=157 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=6 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
	switch_cli dev=1 GSW_PCE_RULE_WRITE pattern.nIndex=158 pattern.bEnable=1 pattern.bPortIdEnable=1 pattern.nPortId=$port  pattern.bPCP_Enable=1 pattern.nPCP=7 Action.ePortMapAction=4 action.nForwardPortMap=0x8000
}

setup_switch() { 
	local lan_proto=$(uci get network.lan.proto)
	#Test APMODE
	if [ "$lan_proto"x = "dhcp"x ];then
		#disable guest network and save current switch status
		$(mem -s 0x16080120 -w 0x800 -u)
		$(mem -s 0x1c003c1c -w 0x7c -u)
		$(mem -s 0x1a003d10 -w 0x1806 -u)
		$(mem -s 0x16080120 -w 0x100800 -u)
		$(switch_cli GSW_PORT_CFG_SET nPortId=6 eEnable=1)
		$(mem -s 0x16000010 -w 0x80000000 -u)
		$(mem -s 0x16000010 -w 0x0 -u)
		return;
	fi
	
	local stb_enable=$(uci get iptv.@stb[0].enabled)
	#Test IPTV Eanble
	[ "$stb_enable"x = "0"x ] && return;
	
	
	local portid=$(uci get iptv.@stb[0].port)
	local lanport=5
	local lanportmap=0x40
			
	case $portid in
        1)
			lanport=5
			lanportmap=0x20
        ;;
        2)
			lanport=4
			lanportmap=0x10
        ;;
		3)
			lanport=3
			lanportmap=0x8
        ;;     		
        *)
			lanport=5
			lanportmap=0x40
        ;;
	esac 
	
	local vlanid=$(uci get iptv.@stb[0].vlanId)		
	local untag=$(uci get iptv.@stb[0].untag)
	local wanvlan=$(uci get network.wan.vlanid)
	
	[ "$untag"x = "1"x ] && {
		[ "$wanvlan"x != ""x ] && {
			return;
		} || {
			setup_tag_mde $lanport $lanportmap $vlanid
		}
	}||{
		setup_tranparent_mode $lanport $lanportmap
	}
}

setup_iptv_mde_MY() {
	local vlanid=$(uci get iptv.@stb[0].vlanId)	
	local untag=$(uci get iptv.@stb[0].untag)
	local wanvlan=$(uci get network.wan.vlanid)
	
	[ "$untag"x = "1"x ] && {
		[ "$wanvlan"x != ""x ] && {
			[ "$vlanid"x != ""x ] && {
				ip link add link eth1 name eth1.$vlanid type vlan id $vlanid
				ifconfig eth1.$vlanid up
				
				ppacmd delwan -i eth1.$vlanid
				ppacmd addlan -i eth1.$vlanid
			}
		}
	}
}