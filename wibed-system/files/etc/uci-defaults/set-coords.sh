#!/bin/sh

lat="41.38953022908476"
lon="2.11306169629097"
offset="10000000"
mac="$(cat /sys/class/net/eth0/address)"

c1hx=$(echo $mac | cut -d: -f6)
c2hx=$(echo $mac | cut -d: -f5)

c1=$(echo "0x$c1hx$c2hx" | awk '{printf "%d", $1}')
c2=$(echo "0x$c2hx$c2hx" | awk '{printf "%d", $1}')

lat1="$(echo $lat | cut -d. -f1)"
lat2="$(echo $lat | cut -d. -f2)"
lon1="$(echo $lon | cut -d. -f1)"
lon2="$(echo $lon | cut -d. -f2)"

newlat2=$(($c1*$offset+$lat2))
newlon2=$(($c1*$offset+$lon2))

newlat="$lat1.$newlat2"
newlon="$lon1.$newlon2"

echo "$newlat"
echo "$newlon"

uci set libremap.location.latitude="$newlat"
uci set libremap.location.longitude="$newlon"
uci commit


