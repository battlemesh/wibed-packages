#!/bin/sh

if ! ( grep -q "/usr/sbin/wibed-node" /etc/crontabs/root 2>/dev/null ) ; then
	SEED="$( dd if=/dev/urandom bs=2 count=1 2>&- | hexdump | if read line; then echo 0x${line#* }; fi )"
	TIME="$(( $SEED % 15 ))"
	echo "* * * * * (sleep $((0+$TIME)) ; /usr/sbin/wibed-node >> /tmp/wibed-node.log)" >> /etc/crontabs/root
	echo "* * * * * (sleep $((15+$TIME)) ; /usr/sbin/wibed-node >> /tmp/wibed-node.log)" >> /etc/crontabs/root
	echo "* * * * * (sleep $((30+$TIME)) ; /usr/sbin/wibed-node >> /tmp/wibed-node.log)" >> /etc/crontabs/root
	echo "* * * * * (sleep $((45+$TIME)) ; /usr/sbin/wibed-node >> /tmp/wibed-node.log)" >> /etc/crontabs/root
	echo "* * * * * (sleep $((5+$TIME)) ; /usr/sbin/wibed-status > /root/wibed-status.log)" >> /etc/crontabs/root
	echo "0 0 * * * /usr/sbin/wibed-rmlogs" >> /etc/crontabs/root
	/etc/init.d/cron enable
	/etc/init.d/cron restart
fi
