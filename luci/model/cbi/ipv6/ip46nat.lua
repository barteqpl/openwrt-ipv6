--[[
LuCI - Lua Configuration Interface

Copyright 2012 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

local fs = require "nixio.fs"

m = Map ("ip46nat", "IP46NAT module", "Experimental ip46nat module. <br/>DISCLAIMER: Be aware that after loading this \
module <strong>firewall is automatically disabled</strong>, both for IPv4 and IPv6!")
s = m:section (TypedSection, "ip46nat","IP46NAT module configuration", nil)

v4addr = s:option(Value, "v4addr", translate("IPv4 network address"), translate("Defines IPv4 subnet that will be translated to IPv6 traffic")) 
v4addr.datatype = "ip4addr"
v4addr.rmempty = false

v4masklen = s:option (Value, "v4masklen", translate("IPv4 mask length"), nil)
v4masklen.datatype = "ip4prefix"
v4masklen.default = 24
v4masklen.optional = true

v4offset = s:option (Value, "v4offset", translate("IPv4 offset"), translate("IPv4 offset in bits (0-95)"))
v4offset.datatype = "uinteger"
v4offset.optional = true 

prefixlan = s:option (Value, "prefixlan", translate("LAN IPv6 prefix"), translate("IPv6 prefix for the LAN side of the router"))
prefixlan.rmempty = false

prefixwan = s:option (Value, "prefixwan", translate("WAN IPv6 prefix"), translate("IPv6 prefix for the WAN side of the router"))
prefixwan.rmempty = false

v6prefixlen = s:option (Value, "v6prefixlen", translate("IPv6 prefix length"), nil)
v6prefixlen.datatype = "ip6prefix"
v6prefixlen.optional = true


debug = s:option (ListValue, "debug", "Debug level")
debug:value("0","0 - Disabled (default)")
debug:value("1","1 - Prints matched packets only")
debug:value("2","2 - Prints all packets (use with caution!)")
debug.default = 0
debug.optional = true

--local file = "/proc/ip46nat/stats"
--ip46stats = fs.readfile(file)
--if ip46stats then

local param_values = fs.readfile("/proc/ip46nat/params")

state = s:option (DummyValue, "_state", translate("Module state"), nil)
if param_values then
	state.value = "Enabled"

	params = s:option (TextValue, "_params", translate("Module parameters"), nil)
	params.wrap = true
	params.rows = 10
	function params.cfgvalue(self, section)
		return param_values
	end
	
	stats = s:option (TextValue, "_stats", translate("Module statistics"), nil)
	stats.wrap = true
	stats.rows = 10
	function stats.cfgvalue(self, section)
		return fs.readfile("/proc/ip46nat/stats")
	end
	        
else 
	state.value = "Disabled"
end

if luci.sys.init.enabled('ip46nat') then 
	btn = s:option(Button, "_btn", translate("Disable"), nil)
	btn.inputstyle = "remove"
	function btn.write()
		luci.sys.init.disable('ip46nat')
		luci.sys.call('/etc/init.d/ip46nat stop')
		luci.http.header("refresh","1")
	end
else
	btn = s:option(Button, "_btn", translate("Enable"), nil)
	btn.inputstyle = "apply"
	function btn.write()
		luci.sys.init.enable('ip46nat')
		luci.sys.call('/etc/init.d/ip46nat start')
		luci.http.header("refresh","1")
	end
end

return m
