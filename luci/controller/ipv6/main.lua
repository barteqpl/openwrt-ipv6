--[[
LuCI - Lua Configuration Interface

Copyright 2011 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id: ipv6.lua 1 2011-04-13 20:22:36Z jow $ 

]]--

module("luci.controller.ipv6.main", package.seeall)

function index()
	--entry({"admin", "network", "ipv6"}, cbi("ipv6/ipv6_main"), "IPv6  Connectivity", 80)
	entry({"admin", "network", "ipv6"}, alias("admin", "network", "ipv6", "aiccu"), "IPv6  Connectivity", 80).index = true
	entry({"admin", "network", "ipv6", "aiccu"}, cbi("ipv6/aiccu"), "AICCU", 20).leaf = true
	entry({"admin", "network", "ipv6", "ip46nat"}, cbi("ipv6/ip46nat"), "IP46NAT", 30).leaf = true
--	entry({"admin", "network", "ipv6", "teredo"}, cbi("ipv6/teredo"), "Teredo", 40).leaf = true
--	entry({"admin", "network", "ipv6", "dslite"}, cbi("ipv6/dslite"), "DS-Lite", 50).leaf = true
	--entry({"admin", "network", "ipv6", "static"}, cbi("ipv6/static"), "Static IPv6 Tunnel", 60).leaf = true
	entry({"admin", "network", "ipv6", "dibblerserver"}, cbi("ipv6/dibblerserver"), "DHCPv6", 70).leaf = true
	
end
