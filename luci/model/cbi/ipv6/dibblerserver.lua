--[[
LuCI - Lua Configuration Interface

Copyright 2012 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id: dibblerserver.lua 1 2012-09-13 20:22:36Z bn $ 

]]--

m = Map ("dibblerserver", "DHCPv6 server configuration", "Dibbler-server - portable DHCPv6 implementation")
s = m:section (TypedSection, "interface", "Interface configuration", nil)

interface = s:option (Value, "interface", translate("LAN interface name"), translate("Name of the LAN interface"))
interface.default = "br-lan"
interface.rmempty = false

pool = s:option (Value, "pool", translate("DHCPv6 pool"), translate("IPv6 address pool"))
pool.datatype     = "ip6addr"
interface.rmempty = false

dns_server = s:option (Value, "dns_server", translate("DNS server"), nil)
dns_server.rmempty = false

domain = s:option (Value, "domain", translate("Default domain name"), nil)
domain.optional = true

ntp_server = s:option (Value, "ntp_server", translate("NTP server"), nil)
ntp_server.optional = true

time_zone = s:option (Value, "time_zone", translate("Time zone"), nil)
time_zone.optional = true
time_zone.default = "GMT"

prefered_lifetime = s:option (Value, "prefered_lifetime", translate("Preferred lifetime"), translate("Preferred lease lifetime in seconds"))
prefered_lifetime.default = '3600'

valid_lifetime = s:option (Value, "valid_lifetime", translate("Valid lifetime"), nil)
valid_lifetime.default = '7200'


return m

 