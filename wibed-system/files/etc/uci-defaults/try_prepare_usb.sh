#!/bin/sh

for device in /dev/sda /dev/sdb; do
    if [ -b $device ]; then
        blkid | grep ${device}1.*wibed-overlay && continue
        wibed.prepare-usb $device &>/tmp/wibed.prepare-usb.log && reboot
        break
    fi
done
