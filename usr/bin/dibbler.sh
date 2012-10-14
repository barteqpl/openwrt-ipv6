#!/bin/sh

# (c) 2012 - barteq.info

IFACE="`uci get dibblerclient.@interface[0].downlink_prefix_ifaces`"

if [  $(/etc/init.d/dibblerserver enabled && echo 1) ]; then
# rise an action only if dibbler-server service is enabled

	if [ -n "`uci get dibblerserver.@interface[0].pool|sed -e 's/\///'`" ]; then

		if [ "$1" = add ] || [ "$1" = update ]; then
				
			if [ -n "$PREFIX1" ] && [ -n "$PREFIX1LEN" ]; then
				[ "$1" = add ] && logger -t dibblerclient "new prefix added - $PREFIX1/$PREFIX1LEN to interface $IFACE"
			
				ip -6 addr add $PREFIX1/$PREFIX1LEN dev $IFACE
			
				# automatically set aftr IP if allowed and both server and client supports this option 	
				if [ -n "$SRV_OPTION64" ] && [ `uci get dslite.@dslite[0].automatic` -eq 1 ]; then
					aftr_ip="`ping -6 -c 1 -w 1 -W 1 -q $SRV_OPTION64| head -n1 | sed -e 's/.*\ (\(.*\))\:.*/\1/'`"
					
					logger -t dibblerclient "Recieved AFTR - $SRV_OPTION64 ($aftr_ip)"
					if [ "`uci get dslite.@dslite[0].aftr`" != $aftr_ip ]; then
						uci set dslite.@dslite[0].aftr=$aftr_ip
						uci commit
						logger -t dibblerclient "Dslite restart"
						/etc/init.d/dslite restart
					fi
				fi
				
				uci set dibblerserver.@interface[0].pool="$PREFIX1/$PREFIX1LEN"
				uci commit
				/etc/init.d/dibblerserver restart
				logger -t dibblerclient "dibbler-server restarted"

				if [ ! -e /var/run/radvd.pid ]; then
					logger -t dibblerclient "radvd not running. Stared."
					/etc/init.d/radvd start
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
fi
