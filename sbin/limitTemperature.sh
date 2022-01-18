#!/bin/sh

cmd=$0
debug=0
debug_file="/tmp/debug_temp.txt"
[ -f "$debug_file" ] && rm -fr $debug_file

keepTime=5
lowThreshold=105
highThreshold=110
lowFlag=0
highFlag=1

usage()
{
	echo "$cmd [keepTime] [lowThreshold] [highThreshold] [debug]"
	echo "EX: $cmd 5 100 115 1"
}

[ $# -gt 0 -a $# -lt 3 ] && usage && exit 1

[ $# -ge 3 ] && {
	keepTime=$1
	lowThreshold=$2
	highThreshold=$3
}

[ $# -gt 3 ] && debug=$4

[ $lowThreshold -ge $highThreshold ] && {
	echo "lowThreshold($lowThreshold) must litter than highThreshold($highThreshold)"
	exit 1
}

setHighPower()
{
	[ $debug -eq 1 ] && {
		echo "`date` [setHighPower] pvt:$pvt highFlag:$highFlag lowFlag:$lowFlag" >> $debug_file
	}
	iw wlan0 iwlwav sCoCPower 0 2 2
	iw wlan2 iwlwav sCoCPower 0 2 2
}

setLowPower()
{
	[ $debug -eq 1 ] && {
		echo "`date` [setLowPower] pvt:$pvt highFlag:$highFlag lowFlag:$lowFlag" >> $debug_file
	}
	iw wlan0 iwlwav sCoCPower 0 1 1
	iw wlan2 iwlwav sCoCPower 0 1 1
}

chkQocc(){
	local qocc=`cat /sys/kernel/debug/tmu/eqt | grep ^036 -m1 | awk -F "," '{print $6}'`
	let qocc=0x$qocc
	[ $qocc -gt 20 ] && {
		echo m 36 > /sys/kernel/debug/tmu/eqt 
	}
}

while [ 1 ]
do
	pvt=`iw wlan0 iwlwav gPVT | cut -d " " -f2`
	
	if [ $pvt -gt $highThreshold ];then
		if [ $highFlag -eq 1 ];then
			setLowPower
			highFlag=0
		fi
		lowFlag=0
	elif [ $highFlag -eq 0 -a $pvt -le $lowThreshold ];then		
		lowFlag=`expr $lowFlag + 1`
		
		if [ $lowFlag -eq $keepTime ];then
			setHighPower
			lowFlag=0
			highFlag=1
		fi
	else
		lowFlag=0
	fi
	#chkQocc
	sleep 1
done

