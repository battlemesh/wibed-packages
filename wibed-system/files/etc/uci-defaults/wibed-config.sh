#!/bin/sh

for device in /dev/sd*; do
    if [ -b $device ]; then
        #blkid -t LABEL=wibed-overlay ${device}1 >/dev/null && continue
        wibed-prepare-usb $device >/root/wibed-prepare-usb.log
        break
    fi
done

#Fix wibed version in UCI configuration
TEST=`tail -1 /etc/wibed.version` && uci set wibed.upgrade.version=`echo ${TEST:0:8}`

wibed-config 2>&1 > /root/wibed-config.log
wibed-location -d >/dev/null

(sleep 10 && reboot) &
