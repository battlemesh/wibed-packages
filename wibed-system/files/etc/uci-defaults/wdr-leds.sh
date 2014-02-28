#!/bin/sh

#Checking which leds have your router

#DEFAULT LEDS WDR4300
DEFAULT_SERVER_LED=/sys/class/leds/tp-link\:blue\:qss

#ADD HERE YOUR NODE LEDS {WDR4300, WDR4900}
QSS=/sys/class/leds/tp-link\:blue\:qss
WPS=/sys/class/leds/tp-link\:blue\:wps

ls ${WPS} > /dev/null 2>&1
if [ $? == 0 ]; then
	DEFAULT_SERVER_LED=${WPS}
fi

echo "echo timer > ${DEFAULT_SERVER_LED}/trigger" >> /etc/rc.local
