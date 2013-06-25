#!/bin/sh

for device in sda sdb sdc; do
    if [ -b /dev/$device ]; then
        continue
    fi
done
