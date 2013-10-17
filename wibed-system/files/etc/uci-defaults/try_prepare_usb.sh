#!/bin/sh

for device in /dev/sd*; do
    if [ -b $device ]; then
        blkid -t LABEL=wibed-overlay ${device}1 &>/dev/null && continue
        wibed-prepare-usb $device &>/root/wibed-prepare-usb.log && reboot
        break
    fi
done
