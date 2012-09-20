--[[
LuCI - Lua Configuration Interface

Copyright 2011 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id: aiccu.lua 1 2011-04-13 20:22:36Z jow $ 

]]--

m = Map ("aiccu", "AICCU (Automatic IPv6 Connectivity Client Utility)", "AICCU uses automated tunnel setup provided by www.sixxs.org")
s = m:section (TypedSection, "aiccu","Aiccu configuration", nil)

login = s:option(Value, "username", translate("Username"), translate("username that will be used for tunnel setup")) -- gets info about username 
login.rmempty = false

pw = s:option(Value, "password", translate("Password"))
pw.password = true -- enables password masking
pw.rmempty = false 

srv = s:option (Value, "server", translate("Server"), translate("Tunnel endpoint. No need to change in default setup"))
srv.default = "tic.sixxs.net"
srv.rmempty = false

interface = s:option (Value, "interface", translate("Interface"), translate("Name of the interface"))
interface.default = "sixxs0"
interface.rmempty = false

tls = s:option(Flag, "requiretls", translate("Require TLS"))
tls.optional = true
tls.default = 0

route = s:option(Flag, "defaultroute", translate("Use as default route"))
route.optional = true
route.default = 1

p = s:option(ListValue, "proto", "Protocol")
p:value("tic", "TIC")
p:value("tsp", "TSP")
p:value("l2tp", "L2TP")
p.default = "tic"
p.optional = true

tunnel_id = s:option (Value, "tunnel_id", translate("Tunnel ID"), translate("Usable if there are multiple tunnels assigned to the sixxs account"))
tunnel_id.optional = true

return m