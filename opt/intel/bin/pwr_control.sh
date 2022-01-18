#!/bin/sh

#select single device or all devices
sel_pm=$1
#enable/disable power saving feature(s) or force to low power mode
level_pm=$2
############################################################

############################################################
# function definition
############################################################
help_pm () {
	echo ""
	echo "Help Power Control:"
	echo "First parameter defines the device, which is treated."
	echo "registered parameters are:"
	echo "WLAN:                                             -ewlan0"
	echo "                                                  -ewlan2"
	echo "                                                   ..."
	echo "                                                  -ewlan10"
	echo "DSL:                                              -edsl0"
	echo "                                                  -edsl1"
	echo "Ethernet/GPHY:                                    -eeth      (for all GPHYs)"
	echo "                                                  -eeth0_1"
	echo "                                                  -eeth0_2"
	echo "                                                   ..."
	echo "                                                  -eeth0_4"
	echo "PCIe:                                             -epcie"
	echo "CPU:                                              -ecpu"
	echo "all above at once:                                -eall"
	echo ""
	echo "Second parameter defines required action."
	echo "registered paramters are:"
	echo "disable power saving feature(s):                  -i0"
	echo "enable power saving feature(s):                   -i1"
	echo "disable device/low power mode:                    -i2"
	echo "enabel device/operational mode:                   -i3"
	echo "current device status:                             no argument"
	echo ""
	echo "examples:"
	echo "pm_util -ewlan0                  shows current status of wlan0"
	echo "pm_util -ewlan2 -i1              enables powersaving mode (AutoCoCMode) for wlan2"
	echo "pm_util -eeth0_4 -i2             puts eth0_4 into low power mode"
	echo ""
}
############################################################

############################################################
# all available power saving features for the system
all_pm () {
	if [ "$level_pm" = "0" ]
		then
			echo "all power saving features will be disabled:"

			#wifi:
			i=0
			for i in 0 2 4 6 8 10; do
				wlan_pm $i
			done

			#GPHY:
			all_gphy_pm

			#CPU:
			cpu_pm

			#PCIe:
			pcie_pm
		elif [ "$level_pm" = "1" ]
			then
				echo "all power saving features will be enabled:"

				#wifi:
				i=0
				for i in 0 2 4 6 8 10; do
					wlan_pm $i
				done

				#GPHY:
				all_gphy_pm

				#CPU:
				cpu_pm

				#PCIe:
				pcie_pm
		elif [ "$level_pm" = "2" ]
			then
				echo "Disable devices. Force devices into low power mode"
			
				#wifi:
				i=0
				for i in 0 2 4 6 8 10; do
					wlan_pm $i
				done

				#GPHY:
				all_gphy_pm

				#DSL:
				i=0
				for i in 0 1; do
					dsl_pm $i
				done
		elif [ "$level_pm" = "3" ]
			then
				echo "Enable devices. Bring the devices back into operational mode"

				#wifi:
				i=0
				for i in 0 2 4 6 8 10; do
					wlan_pm $i
				done

				#GPHY:
				all_gphy_pm

				#DSL:
				i=0
				for i in 0 1; do
					dsl_pm $i
				done
		else
			echo ""

			echo "*********************************************************"
			#wifi:
			echo "status wlan:"
			i=0
			for i in 0 2 4 6 8 10; do
				wlan_pm $i
			done

			echo "*********************************************************"
			#GPHY:
			all_gphy_pm

			echo "*********************************************************"
			#CPU:
			cpu_pm

			echo "*********************************************************"
			#PCIe:
			pcie_pm

			echo "*********************************************************"
			#DSL:
			i=0
			for i in 0 1; do
				dsl_pm $i
			done
	fi
}
############################################################

############################################################
# wlan power saving feature(s)
wlan_pm () {
nWlan=$1
	if [ "$level_pm" = "0" ]
		then
			if iw wlan"$nWlan" iwlwav sCoCPower 0 4 4 1> /dev/null 2> /dev/null
			then
				if iw wlan"$nWlan" iwlwav sCoCPower 0 4 4
				then
					echo "wlan$nWlan power saving feature (Auto-CoC-MiMo-Mode) will be disabled"
				fi
			fi
		elif [ "$level_pm" = "1" ]
			then
				if iw wlan"$nWlan" iwlwav sCoCPower 1 1> /dev/null 2> /dev/null
				then
					if iw wlan"$nWlan" iwlwav sCoCPower 1
					then
						echo "wlan$nWlan power saving feature (Auto-CoC-MiMo-Mode) will be enabled"
					fi
				fi
		elif [ "$level_pm" = "2" ]
			then
				if iw wlan"$nWlan" iwlwav gCoCPower 1> /dev/null 2> /dev/null
				then
					if ifconfig wlan"$nWlan" down
					then
						echo "Disable wlan$nWlan. Force device into low power mode"
					fi
				fi
		elif [ "$level_pm" = "3" ]
			then
				if iw wlan"$nWlan" iwlwav gCoCPower 1> /dev/null 2> /dev/null
				then
					if ifconfig wlan"$nWlan" up
					then
						echo "Enable wlan$nWlan. Bring the device back into operational mode"
					fi
				fi
		else
			if iw wlan"$nWlan" iwlwav gCoCPower 1> /dev/null 2> /dev/null
			then
				iw wlan"$nWlan" iwlwav gCoCPower
				if ifconfig | grep -q "wlan$nWlan"; then
					echo "wlan$nWlan in operative mode"
				else
					echo "wlan$nWlan in low power mode"
				fi
			else
				echo "No wlan$nWlan on this board!"
			fi
	fi
}
############################################################
 
############################################################
############################################################
#DSL Helper function for vrx518 single line
#Tear Down DSL Link and Power Down LD
wait_for_firmware_ready() {
nTimeout=$1
	while [ "$nTimeout" -gt 0 ]
	do
		FDSG_VALS=$(/opt/intel/bin/dsl_cpe_pipe.sh asg)
		if echo "$FDSG_VALS"
		then
			for k in $FDSG_VALS; do eval "$k" 2>/dev/null; done
			if [ "$nStatus" = "5" ]; then
				#echo "nStatus="$nStatus
			        break
			fi
		fi
		nTimeout=$(("$nTimeout"-1))
		sleep 1
		echo "$nTimeout"
	done
}
########################################################
#DSL Helper function for vrx518 bonding
#Tear Down DSL Link and Power Down LD
wait_for_firmware_ready2() {
nTimeout=$1
nLine=$2
	echo "nLine=""$nLine"
	echo "nTimeout=""$nTimeout"
	
	while [ "$nTimeout" -gt 0 ]
	do
		FDSG_VALS=$(/opt/lantiq/bin/dsl_cpe_pipe.sh asg "$nLine")
		if echo "$FDSG_VALS"
		then
		        for k in $FDSG_VALS; do eval "$k" 2>/dev/null; done
			if [ "$nStatus" = "5" ]; then
				#echo "nStatus="$nStatus
				break
			elif [ "$nStatus" = "7" ]; then
			#echo "nStatus="$nStatus
			break
            		fi
		fi
		nTimeout=$(("$nTimeout"-1))
		sleep 1
		echo "$nTimeout"
	done
}
###########################################################
# dsl helper function to detect VRX518 or VRX618
dsl_vrx_detect () {
	if lspci -n | grep -q 8086:09a9
		then
			dsl_family="vrx518"
		elif lspci -n | grep -q 8086:09aa
		then
			dsl_family="vrx618"
		else
			dsl_family="not_defined"
	fi
}
###########################################################
# dsl helper function to detect VRX518 or VRX618
dsl_bonding_detect () {
	if < /proc/driver/mei_cpe/devinfo grep "MaxDeviceNumber=2"
		then
			dsl_bonding="bonding"
		else
			dsl_bonding="single"
	fi
}
############################################################

############################################################
# dsl power saving feature(s)
dsl_vrx_detect
dsl_bonding_detect
dsl_pm () {
nLine=$1
	if [ "$level_pm" = "0" ]
		then
			echo "No power saving feature(s) for $dsl_family!"
			
		elif [ "$level_pm" = "1" ]
			then
				echo "No power saving feature(s) for $dsl_family!"
		elif [ "$level_pm" = "2" ]
			then
				if test [ "$dsl_family" = "vrx518" ] && [ "$dsl_bonding" = "single" ]
					then
						if [ "$nLine" = "0" ]
							then
								echo "Disable dsl$nLine. Force device into low power mode"
								/opt/intel/bin/dsl_cpe_pipe.sh acos 1 1 1 1 0 0
								/opt/intel/bin/dsl_cpe_pipe.sh acs 2
								wait_for_firmware_ready 30
								#disable Line Driver
								/opt/intel/bin/dsl_cpe_pipe.sh dms 0xa62 0 1 0x0
								#disable AFE
								/opt/intel/bin/dsl_cpe_pipe.sh dms 0xa173 0 2 0x30c740 0x4000
								/opt/intel/bin/dsl_cpe_pipe.sh dms 0xa173 0 2 0x30c700 0x4000
								/opt/intel/bin/dsl_cpe_pipe.sh acs 3
								sleep 3
								echo "/opt/intel/bin/dsl_cpe_pipe.sh quit"
								#read -n1 -r -p "Press space to continue..." key
								/opt/intel/etc/init.d/ltq_load_dsl_cpe_api.sh stop
								sleep 3
								echo "/opt/intel/etc/init.d/ltq_load_cpe_mei_drv.sh stop"
								#read -n1 -r -p "Press space to continue..." key
								/opt/intel/etc/init.d/ltq_load_cpe_mei_drv.sh stop
								sleep 3
								#read -n1 -r -p "Press space to continue..." key
								#clock gating CGU/PMU_PWDCR  PD PPE/DSL/SPI/DMA/ACA_DMA/etc
								mem -us 0xb400011c -w 0x20ec0305
								#disable PLL CGU/PLL_CFG
								mem -us 0xb4000060 -w 0x40000001
								mem -us 0xb4000060 -w 0x40000000
							else
								echo "No second dsl line available. Single line!"
						fi
				elif test [ "$dsl_family" = "vrx518" ] && [ "$dsl_bonding" = "bonding" ]
					then
						/opt/lantiq/bin/dsl_cpe_pipe.sh acos "$nLine" 1 1 1 1 0 0
						/opt/lantiq/bin/dsl_cpe_pipe.sh acs "$nLine" 2
						wait_for_firmware_ready2 30 "$nLine"
						#disable Line Driver
						/opt/lantiq/bin/dsl_cpe_pipe.sh dms "$nLine" 0xa62 0 1 0x0
						#disable AFE
						/opt/lantiq/bin/dsl_cpe_pipe.sh dms "$nLine" 0xa173 0 2 0x30c740 0x4000
						/opt/lantiq/bin/dsl_cpe_pipe.sh dms "$nLine" 0xa173 0 2 0x30c700 0x4000
						/opt/lantiq/bin/dsl_cpe_pipe.sh acs "$nLine" 3
						sleep 3
						/opt/lantiq/bin/dsl_cpe_pipe.sh acs "$nLine" 0
						#clock gating CGU/PMU_PWDCR  PD PPE/DSL/SPI/DMA/ACA_DMA/etc
						#mem -us 0xbc80011c -w 0x10ec0305
						# DSL clock gating can not be activated on GRX300 platform; if we do this the system hangs.
						# On GRX500 platform it is working; currently this is unclear why this is a problem on GRX300 platform.
						mem -us 0x1b00011c -w 0x10ec0105
						#disable PLL CGU/PLL_CFG
						mem -us 0x1b000060 -w 0x40000001
						mem -us 0x1b000060 -w 0x40000000
				elif [ "$dsl_family" = "vrx618" ]
					then
						echo "disable vrx618"
						#dsl di 2 1
				else
					echo "No dsl device found!"
				fi
		elif [ "$level_pm" = "3" ]
			then
				if test [ "$dsl_family" = "vrx518" ] && [ "$dsl_bonding" = "single" ]
					then
						if [ "$nLine" = "0" ]
							then
								echo "Enable dsl$nLine. Bring the device back into operational mode"
								#enable PLL CGU/PLL_CFG
								mem -us 0xb4000060 -w 0x00600011
								#enable clocks CGU/PMU_PWDCR  PD PPE/DSL/SPI/DMA/ACA_DMA/etc
								mem -us 0xb400011c -w 0x0
								/opt/intel/etc/init.d/ltq_load_cpe_mei_drv.sh start
								sleep 3
								/opt/intel/etc/init.d/ltq_load_dsl_cpe_api.sh start
								sleep 3
								/opt/intel/etc/init.d/ltq_cpe_control_init.sh start
								sleep 3
								/opt/intel/bin/dsl_cpe_pipe.sh acs 2
							else
								echo "No second dsl line available. Single line!"
						fi
				elif test [ "$dsl_family" = "vrx518" ] && [ "$dsl_bonding" = "bonding" ]
					then
						#enable PLL CGU/PLL_CFG
						mem -us 0x1b000060 -w 0x00600011
						#enable clocks CGU/PMU_PWDCR  PD PPE/DSL/SPI/DMA/ACA_DMA/etc
						mem -us 0x1b00011c -w 0x0
						/opt/lantiq/bin/dsl_cpe_pipe.sh acs "$nLine" 1
						sleep 3
						/opt/lantiq/bin/dsl_cpe_pipe.sh acs "$nLine" 2
				elif [ "$dsl_family" = "vrx618" ]
					then
						echo "enable vrx618"
						#dsl di 2 1
				else
					echo "No dsl device found!"
				fi
		else
			echo "status dsl$nLine:"
			if test [ "$dsl_family" = "vrx518" ] && [ "$dsl_bonding" = "single" ]
				then
					if [ "$nLine" = "0" ]
						then
							echo "VRX518; $dsl_bonding"
							dsl_profile=$(dsl_cpe_pipe dms 0xcd03 1 1 |awk '{ print $5 }')
							case "$dsl_profile" in
								"0001") echo "Profile_8a"
									;;
								"0002") echo "Profile_8b"
									;;
								"0004") echo "Profile_8c"
									;;
								"0008") echo "Profile_8d"
									;;
								"0010") echo "Profile_12a"
									;;
								"0020") echo "Profile_12b"
									;;
								"0040") echo "Profile_17a"
									;;
								"0080") echo "Profile_30a"
									;;
								"0100") echo "Profile_30b"
									;;
								*) echo "Unknown profile"
									;;
							esac
							dsl_cpe_pipe lsg
						else
							echo "No second dsl line available. Single line!"
					fi
				elif test [ "$dsl_family" = "vrx518" ] && [ "$dsl_bonding" = "bonding" ]
					then
						echo "VRX518; $dsl_bonding"
						dsl_cpe_pipe lsg "$nLine"
				elif [ "$dsl_family" = "vrx618" ]
					then
						echo "VRX618; $dsl_bonding"
						dsl_pipe lsg "$nLine"   #for VRX618
				else
					echo "No dsl device found!"
			fi
	fi
}
############################################################
############################################################
# eth0_1 = GPHY_port2;	eth0_3 = GPHY_port4
# eth0_2 = GPHY_port3;	eth0_4 = GPHY_port5
############################################################
# all GPHYs/ethernet ports power saving feature(s)

all_gphy_pm () {
	if [ "$level_pm" = "0" ]
		then
			j=1
			for j in 1 2 3 4; do
 				ethtool --set-eee eth0_$j tx-lpi off
			done
			echo "GPHY power saving feature (EEE-Mode) will be disabled for all ports"
		elif [ "$level_pm" = "1" ]
			then
				j=1
				for j in 1 2 3 4; do
 					ethtool --set-eee eth0_$j tx-lpi on
				done
				echo "GPHY power saving feature (EEE-Mode) will be enabled for all ports"
		elif [ "$level_pm" = "2" ]
			then
				j=2
				for j in 2 3 4 5; do
					switch_cli GSW_MDIO_DATA_WRITE nAddressDev=$j nAddressReg=0 nData=0x1840 1> /dev/null 2> /dev/null
				done
				echo "Disable GPHYs. Force all ports into low power mode"
		elif [ "$level_pm" = "3" ]
			then
				j=2
				for j in 2 3 4 5; do
					switch_cli GSW_MDIO_DATA_WRITE nAddressDev=$j nAddressReg=0 nData=0x1000 1> /dev/null 2> /dev/null
				done
				echo "Enable GPHYs. Bring all ports back into operational mode"
		else
			echo "status GPHYs:"
			i=2
			j=1
				for j in 1 2 3 4; do
					echo ""
					if switch_cli GSW_MDIO_DATA_READ nAddressDev=$j nAddressReg=0 | grep -q "0x18"; then
						echo "eth0_$j in low power mode"
					else
						echo "eth0_$j in operational mode"
					fi
					ethtool --show-eee eth0_$j
					ethtool eth0_$j | grep "Link detected:"
				done
	fi
}
############################################################

############################################################
# GPHY/Ethernet power saving feature(s)
gphy_pm () {
nEth=$1
nGphy=$2
	if [ "$level_pm" = "0" ]
		then
 			ethtool --set-eee eth0_"$nEth" tx-lpi off
			echo "GPHY power saving feature (EEE-Mode) will be disabled for port$nGphy"
		elif [ "$level_pm" = "1" ]
			then
 				ethtool --set-eee eth0_"$nEth" tx-lpi on
				echo "GPHY power saving feature (EEE-Mode) will be enabled for port$nGphy"
		elif [ "$level_pm" = "2" ]
			then
				switch_cli GSW_MDIO_DATA_WRITE nAddressDev="$nGphy" nAddressReg=0 nData=0x1840 1> /dev/null 2> /dev/null
				echo "Disable GPHY$nGphy. Force port$nGphy into low power mode"
		elif [ "$level_pm" = "3" ]
			then
				switch_cli GSW_MDIO_DATA_WRITE nAddressDev="$nGphy" nAddressReg=0 nData=0x1000 1> /dev/null 2> /dev/null
				echo "Enable GPHY. Bring port$nGphy back into operational mode"
		else
			echo "status GPHY$nGphy:"
			ethtool --show-eee eth0_"$nEth"
			ethtool eth0_"$nEth" | grep "Link detected:"

			if switch_cli GSW_MDIO_DATA_READ nAddressDev="$nGphy" nAddressReg=0 | grep -q "0x18"; then
				echo "eth0_$nEth in low power mode"
			else
				echo "eth0_$nEth in active mode"
			fi
	fi
}

############################################################

############################################################
# PCIe power saving feature(s)
pcie_pm () {
	if [ "$level_pm" = "0" ]
		then
 			echo performance > /sys/module/pcie_aspm/parameters/policy
			echo "Disable PCIe power saving feature (ASPM)"
		elif [ "$level_pm" = "1" ]
			then
 				echo powersave > /sys/module/pcie_aspm/parameters/policy
				echo "Enable PCIe power saving feature (ASPM)"
		elif [ "$level_pm" = "2" ]
			then
				echo "No power down mode for PCIe available"
		elif [ "$level_pm" = "3" ]
			then
				echo "No power down mode for PCIe available"
		else
			echo "status PCIe:"
			lspci -vv
	fi
}
############################################################

############################################################
# CPU power saving feature(s)
cpu_pm () {
	if [ "$level_pm" = "0" ]
		then
 			echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
			echo "Disable CPU power saving feature (DVFS)"
		elif [ "$level_pm" = "1" ]
			then
 				echo conservative > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
				echo "Enable CPU power saving feature (DVFS)"
		elif [ "$level_pm" = "2" ]
			then
				echo "No power down mode for CPU available"
		elif [ "$level_pm" = "3" ]
			then
				echo "No power down mode for CPU available"
		else
			echo "status CPU:"
			cd /sys/devices/system/cpu/cpufreq || exit
			grep -rvl "\x00" -- * | while read -r file; do printf "\n#### %s ####\n" "$file"; cat "$file"; done
	fi
}
############################################################


############################################################
# Main switch case
############################################################
case "$sel_pm" in
	"help") help_pm
		;;
	"all") all_pm
		;;
	"wlan0") wlan_pm 0
		;;
	"wlan2") wlan_pm 2
		;;
	"wlan4") wlan_pm 4
		;;
	"wlan6") wlan_pm 6
		;;
	"wlan8") wlan_pm 8
		;;
	"wlan10") wlan_pm 10
		;;
	"dsl0") dsl_pm 0
		;;
	"dsl1") dsl_pm 1
		;;
	"eth") all_gphy_pm
		;;
	"eth0_1") gphy_pm 1 2
		;;
	"eth0_2") gphy_pm 2 3
		;;
	"eth0_3") gphy_pm 3 4
		;;
	"eth0_4") gphy_pm 4 5
		;;
	"pcie") pcie_pm
		;;
	"cpu") cpu_pm
		;;
	*) echo "Unknown Parameter"
		;;
esac
exit 0
############################################################

