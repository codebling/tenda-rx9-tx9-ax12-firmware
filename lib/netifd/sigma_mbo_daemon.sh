#!/bin/sh

. /lib/netifd/sigma-ap.sh

is_running=`ps | grep sigma_mbo_d | wc -l`
if [ $is_running -ge 4 ]; then
	debug_print "mbo daemon is already running"
	exit 0
fi

debug_print "--------------------------------------------------- MBO DAEMON STARTED ---------------------------------------------------"

while :;
do
	event=`run_dwpal_cli_cmd -ihostap -mMain -vwlan0.0 -vwlan2.0 -dd -l"AP-STA-CONNECTED" -l"RRM-BEACON-REP-RECEIVED" -l"AP-STA-WNM-NOTIF"`
	debug_print "sigma_mbo_handler event received = $event"
	mbo_handler $event
done
