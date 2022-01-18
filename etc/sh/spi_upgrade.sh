#!/bin/sh

if [ ! -f /tmp/uImage -o ! -f /tmp/image ]
then
    reboot -f
    exit
fi

/etc/init.d/httpd stop
/etc/init.d/ucloud stop
/etc/init.d/td_serverd stop
/sbin/wifi down
sleep 3
stop_bin="td_filter_ctrl td_wan_speed td_ol_srv wan_type_probe td_flow_statistic_ctl gpio_switch log sysfixtime telnet ppa odhcpd dnsmasq miniupnpd urngd cron sysntpd network urandom_seed"

for cmd in $stop_bin
do
    /etc/init.d/$cmd stop
done
sleep 2
echo 1 > /proc/sys/vm/drop_caches

if [ ! -f /tmp/uImage ]
then
    reboot -f
fi

sync;mtd write /tmp/uImage kernel
sleep 1

if [ ! -f /tmp/image ]
then
    reboot -f
fi

sync;mtd  -r write /tmp/image rootfs
reboot -f
umount -a
