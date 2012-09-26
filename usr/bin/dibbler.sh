#!/bin/sh

IFACE="`uci get dibblerclient.@interface[0].downlink_prefix_ifaces`"

if [ -n "`uci get dibblerserver.@interface[0].pool|sed -e 's/\///'`" ]; then

	if [ "$1" = add ] || [ "$1" = update ]; then
			
		if [ -n "$PREFIX1" ] && [ -n "$PREFIX1LEN" ]; then
		[ "$1" = add ] && logger -t dibblerclient "new prefix added - $PREFIX1/$PREFIX1LEN to interface $IFACE"
			ip -6 addr add $PREFIX1/$PREFIX1LEN dev $IFACE
						
			uci set dibblerserver.@interface[0].pool="$PREFIX1/$PREFIX1LEN"
			uci commit
			/etc/init.d/dibblerserver restart
			if [ -e "/var/etc/radvd.conf" ]; then
				/etc/init.d/radvd restart
			fi
		fi
	fi
	
	if [ "$1" = delete ]; then
	logger -t dibblerclient "prefix $PREFIX1/$PREFIX1LEN removed. Stopping dibbler-server."
		uci set dibblerserver.@interface[0].pool=""
		uci commit
		/etc/init.d/dibblerserver stop
		ip -6 addr del $PREFIX1/$PREFIX1LEN dev $IFACE
	fi
fi
