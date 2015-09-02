#!/bin/sh

# Reghack not needed anymore
#[ -f /usr/bin/apply_reghack ] && /usr/bin/apply_reghack

for device in /dev/sd*; do
    if [ -b $device ]; then
        #blkid -t LABEL=wibed-overlay ${device}1 >/dev/null && continue
        wibed-prepare-usb $device >/root/wibed-prepare-usb.log
        break
    fi
done

[ ! -f /etc/config/wibed ] && cp -f /etc/wibed.default-config /etc/config/wibed

# Configure ALFRED properly
uci set 'alfred'.alfred.interface='mgmt0'
uci set 'alfred'.alfred.disabled='0'
uci commit
/etc/init.d/alfred start

#Fix wibed version in UCI configuration
TEST=`tail -1 /etc/wibed.version` && uci set wibed.upgrade.version=`echo ${TEST:0:8}`

wibed-config 2>&1 > /root/wibed-config.log
wibed-location -d >/dev/null

# Conform to new OVERLAYFS directories
mkdir -p /tmp/usb-overlay/upper
mkdir -p /tmp/usb-overlay/work

(sleep 10 && reboot) &
