#!/bin/sh
# Workaround to get ipv6 mutlicast ( ping ff02::1 ) working.
# More info: https://bugs.lede-project.org/index.php?do=details&task_id=154

uci set firewall.@defaults[0].drop_invalid=0
