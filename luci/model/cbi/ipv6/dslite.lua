--[[
LuCI - Lua Configuration Interface

Copyright 2012 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

]]--

m = Map ("dslite", "DS-Lite", "DS-Lite tunnel configuration")
s = m:section (TypedSection, "dslite", "DS-Lite configuration", nil)

automatic = s:option (Flag, "automatic", translate("Automatic configuration"), "Takes AFTR address from DHCP and sets up tunnel automatically. Relies on dibbler-client")
automatic.default = true
automatic.rmepmty = false

aftr = s:option (Value, "aftr", translate("<abrr title=\"Address Family Transition Router\">AFTR</abbr> address"), "Used only if automatic mode is disabled")
aftr.datatype = "ip6addr"

_status = s:option(DummyValue, "_status", "Status")
_status.value = "DOWN"

for i,d in ipairs(luci.sys.net.devices()) do
	if d == "dslite0" 
	then
		_status.value = "UP and running"
	end
end

if luci.sys.init.enabled('dslite') then 
	btn = s:option(Button, "_btn", translate("Disable"), nil)
	btn.inputstyle = "remove"
	function btn.write()
		luci.sys.init.disable('dslite')
		luci.sys.call('/etc/init.d/dslite stop')
		luci.http.header("refresh","1")
	end
else
	btn = s:option(Button, "_btn", translate("Enable"), nil)
	btn.inputstyle = "apply"
	function btn.write()
		luci.sys.init.enable('dslite')
		luci.sys.call('/etc/init.d/dslite start')
		luci.http.header("refresh","1")
	end
end

return m
