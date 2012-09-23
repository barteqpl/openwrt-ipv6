#!/bin/sh

if [ -n "`uci get dibblerserver.@interface[0].pool`" ]; then

	if [ "$1" = add ]; then
		
		if [ -n "$PREFIX1 ] && [ -n "$PREFIX1LEN ]; then
			uci set dibblerserver.@interface[0].pool="$PREFIX1/$PREFIX1LEN"
			uci commit
			/etc/init.d/dibblerserver restart
			if [ -e "/var/etc/radvd.conf" ]; then
				/etc/init.d/radvd restart
			fi
		fi
	fi
fi
