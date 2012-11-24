#!/bin/sh

# Automatic DS-Lite and PD delegation script
# (c) 2012 - Bartosz Nowicki <barteqpl@gmail.com>

IFACE="`uci get dibblerclient.@interface[0].downlink_prefix_ifaces`"

# DS-LITE options
if [ "$1" = add ] || [ "$1" = update ]; then
	
	# automatically sets up AFTR tunnel if recieved proepr AFTR address, dslite is allowed and enabled
	if [ -n "$SRV_OPTION64" ] && [ `uci get dslite.@dslite[0].automatic` -eq 1 ] && [ $(/etc/init.d/dslite enabled && echo 1) ]; then
	
		# dirty but working. Better switch to nslookup, cause ping fails in case ds-lite enabled and no connection established
		aftr_ip="`ping -6 -c 1 -w 1 -W 1 -q $SRV_OPTION64| head -n1 | sed -e 's/.*\ (\(.*\))\:.*/\1/'`"
		logger -t dibblerclient "Received AFTR - $SRV_OPTION64 ($aftr_ip)"

		if [ -z "`grep dslite0 /proc/net/dev`" ]; then
			logger -t dibblerclient "No active AFTR tunnel found. Starting"
			/etc/init.d/dslite start
		
		# do nothing in case tunnel is up and aftr IP remains the same
		# if not assign new one and restart tunnel
		else 
			if [ "`uci get dslite.@dslite[0].aftr`" != $aftr_ip ]; then
				uci set dslite.@dslite[0].aftr=$aftr_ip
				uci commit
				logger -t dibblerclient "Dslite module restarted"
				/etc/init.d/dslite restart
			fi
		fi
	fi
fi

if [ "$1" = delete ]; then		
	if [ $(/etc/init.d/dslite enabled && echo 1) ]; then
			
			logger -t dibblerclient "Removing AFTR tunnel"
			/etc/init.d/dslite stop
	fi
fi

# Options related to automatic dibbler-serverconfiguration (Prefix Delegation)
# rise an action only if dibbler-server service is enabled
if [  $(/etc/init.d/dibblerserver enabled && echo 1) ]; then

	# starts only if pool filed is empty
	if [ -n "`uci get dibblerserver.@interface[0].pool|sed -e 's/\///'`" ]; then

		if [ "$1" = add ] || [ "$1" = update ]; then
			
			if [ -n "$PREFIX1" ] && [ -n "$PREFIX1LEN" ]; then
				
				currentip="$(ip -6 addr show dev $IFACE|grep $PREFIX1/$PREFIX1LEN | awk '{ print $2 }')"
				[ -n "$currentip" ] && exit 0
				
				[ "$1" = add ] && logger -t dibblerclient "new prefix added - $PREFIX1/$PREFIX1LEN to interface $IFACE"
			
				ip -6 addr add $PREFIX1/$PREFIX1LEN dev $IFACE
			
				uci set dibblerserver.@interface[0].pool="$PREFIX1/$PREFIX1LEN"
				uci commit
				/etc/init.d/dibblerserver restart
				logger -t dibblerclient "dibbler-server restarted"

				if [ ! -e /var/run/radvd.pid ]; then
					logger -t dibblerclient "radvd not running. Starting..."
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
