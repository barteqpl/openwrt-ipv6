--[[
LuCI - Lua Configuration Interface

Copyright 2011 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id: static.lua 1 2011-04-13 20:22:36Z jow $ 

]]--

m = Map ("network", translate("Static IPv6 Tunnel"), translate("Configures static IPv6 tunnels."))
s = m:section (TypedSection, "interface","Tunnels")

s.addremove = false -- Allow the user to create and remove the interfaces
s:depends("proto","6in4")

--[[function s:filter(value)
	return string.find(value, "^sit") -- returns only interfaces starting with sit.*
end 
]]--

remote = s:option(Value, "ipaddr", Translate("Remote tunnel endpoint"))
function remote:validate(value)
    return value:match("[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+") -- Returns nil if it doesn't match otherwise returns match
end

--s:option(Value, "ifname", "interface", "the physical interface to be used") -- This will give a simple textbox

return m