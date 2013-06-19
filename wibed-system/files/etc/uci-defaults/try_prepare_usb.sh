#!/bin/sh

for device in sdb sdc sde sdf; do
    [ -b /dev/$device ] || continue
done
