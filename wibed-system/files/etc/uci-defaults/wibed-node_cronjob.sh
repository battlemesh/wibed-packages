#!/bin/sh

if ! ( grep -q "/usr/sbin/wibed-node" /etc/crontabs/root 2>/dev/null ) ; then
	echo "*/1 * * * * /usr/sbin/wibed-node" >> /etc/crontabs/root
	echo "*/1 * * * * sleep 15 ; /usr/sbin/wibed-node > /tmp/wibed-node.log" >> /etc/crontabs/root
	echo "*/1 * * * * sleep 30 ; /usr/sbin/wibed-node > /tmp/wibed-node.log" >> /etc/crontabs/root
	echo "*/1 * * * * sleep 45 ; /usr/sbin/wibed-node > /tmp/wibed-node.log" >> /etc/crontabs/root
	echo "*/1 * * * * /usr/sbin/wibed-status > /root/wibed-status.log" >> /etc/crontabs/root
	/etc/init.d/cron enable
	/etc/init.d/cron restart
fi

