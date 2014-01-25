#!/bin/sh

uci get libremap.location.configured && exit

lat="41.38953022908476"
lon="2.11306169629097"
offset="1000000"

seed1="$(dd if=/dev/urandom bs=2 count=1 2>&- | hexdump | if read line; then echo ${line#* }; fi)"
seed2="$(dd if=/dev/urandom bs=2 count=1 2>&- | hexdump | if read line; then echo ${line#* }; fi)"
c1=$(echo "0x$seed1" | awk '{printf "%d", $1}')
c2=$(echo "0x$seed2" | awk '{printf "%d", $1}')

lat1="$(echo $lat | cut -d. -f1)"
lat2="$(echo $lat | cut -d. -f2)"
lon1="$(echo $lon | cut -d. -f1)"
lon2="$(echo $lon | cut -d. -f2)"

newlat2=$(($c1*$offset+$lat2))
newlon2=$(($c2*$offset+$lon2))

newlat="$lat1.$newlat2"
newlon="$lon1.$newlon2"

echo "$newlat"
echo "$newlon"

uci set libremap.location.configured="1"
uci set libremap.location.latitude="$newlat"
uci set libremap.location.longitude="$newlon"
uci commit

