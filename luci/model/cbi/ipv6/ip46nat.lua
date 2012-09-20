--[[
LuCI - Lua Configuration Interface

Copyright 2011 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id: 6rd.lua 1 2011-04-13 20:22:36Z jow $ 

]]--


m = Map ("ip46nat", "IP46NAT module", "Experimental ip46nat module")
s = m:section (TypedSection, "ip46nat","IP46NAT module configuration", nil)

v4addr = s:option(Value, "v4addr", translate("IPv4 network address"), translate("Defines IPv4 subnet that will be translated to IPv6 traffic")) -- gets info about username 
v4addr.datatype = "ip4addr"
v4addr.rmempty = false

prefixlan = s:option (Value, "prefixlan", translate("LAN IPv6 prefix"), translate("IPv6 prefix for LAN side of the router"))
prefixlan.rmempty = false

prefixwan = s:option (Value, "prefixwan", translate("WAN IPv6 prefix"), translate("IPv6 prefix for WAN side of the router"))
prefixwan.rmempty = false

return m