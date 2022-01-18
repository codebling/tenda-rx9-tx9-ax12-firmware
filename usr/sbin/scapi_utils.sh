#!/bin/sh 

if [ -f /etc/profile.d/ugw_framework_env.sh ] ; then
	. /etc/profile.d/ugw_framework_env.sh
fi

if [ -f /etc/profile.d/intel.sh ] ; then
	. /etc/profile.d/intel.sh
fi

scapi_utils_init()
{
	local file="${VENDOR_PATH}/etc/.certchk"
	#local fwfile="${VENDOR_PATH}/etc/csd/fwboot"

	#local cmd_line t_active_bank active_bank t_update_chk update_chk
	#cmd_line="`cat /proc/cmdline`";

	#[ -z "${cmd_line##*active_bank=[AB]*}" ] && {
	#	t_active_bank=${cmd_line##*active_bank=};
	#	active_bank=${t_active_bank::1};
	#} || active_bank=A;

	#[ -z "${cmd_line##*update_chk=[0-4]*}" ] && {
	#	t_update_chk=${cmd_line##*update_chk=};
	#	update_chk=${t_update_chk::1};
	#} || update_chk=0;

	#if [ "$active_bank" = "B" -a "$update_chk" = "0" ]; then
	#	/usr/sbin/uboot_env --set --name update_chk --value  2
	#elif [ "$active_bank" = "A" -a "$update_chk" != "0" ]; then
	#	/usr/sbin/uboot_env --set --name update_chk --value 0
	#fi

	#create certificate for lighthttpd on first boot.
	if [ ! -s $file ] ; then
		key=`scapiutil get_key`
	fi

	#check whether fw boot or normal boot
	#if [ -f $fwfile ] ; then

		#find last running configuration
	#	file=`cat ${VENDOR_PATH}/csd/etc/csdswap`
	#	chmod 777 ${VENDOR_PATH}/csd/etc/csdswap

	#        _lastmodified=`echo $file | cut -d \= -f 2`

	#	if [[ $_lastmodified -eq 1 ]] ; then
	#		csdutil merge ${VENDOR_PATH}/csd/config/.run-data.xml /rom/${VENDOR_PATH}/etc/datacfg /rom/${VENDOR_PATH}/etc/ctrlcfg
	#	else
	#		csdutil merge ${VENDOR_PATH}/csd/config/.run-data-swp.xml /rom/${VENDOR_PATH}/etc/datacfg /rom/${VENDOR_PATH}/etc/ctrlcfg
	#	fi

		#remove fwboot
	#	[ -e $fwfile ] && rm $fwfile
	#fi

	#create log soft link under /tmp directory for procd log on boot.

	# The source directory and target directories.
	target_location="/tmp/debug_level" # Contains the working location of file.
	source_location="${VENDOR_PATH}/etc/debug_level" # file location.

	if [ ! -s $source_location ] ; then
		echo '2' > $source_location
		echo '#Auto generated file for procd debug level(1-5)' >> $source_location
	fi

	ln -s "$source_location" "$target_location"

	#check devices comming up with default mac or not.
	old_mac=`scapiutil get_mac`
	[ -n "$CONFIG_UBOOT_CONFIG_ETHERNET_ADDRESS" -a -n "$old_mac" ] && \
	  [ "$old_mac" = "$CONFIG_UBOOT_CONFIG_ETHERNET_ADDRESS" ] && {
		local i=0;
		while [ $i -lt 5 ]; do
			echo -en "\033[J"; usleep 150000;
			echo -en "#######################################################\n";
			echo -en "#     DEVICE CONFIGURED WITH DEFAULT MAC ADDRESS!!    #\n";
			echo -en "# This may conflict with other devices. Please change #\n";
			echo -en "#     the MAC address for un-interrupted services.    #\n";
			echo -en "#######################################################\n";
			echo -en "\033[5A\033G"; usleep 300000;
			let i++
		done; echo -en "\n\n\n\n\n";
		echo -en "######Please configure the MAC from uboot using \n";
		echo -en "######set ethaddr 'xx:xx:xx:xx:xx' \n";
		echo -en "###### Board is going to reboot#####\n";
		sleep 5;
		reboot;
	} || true
}

scapi_utils_init

