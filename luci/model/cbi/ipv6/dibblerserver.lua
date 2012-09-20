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
dns_server.datatype = "host"

domain = s:option (Value, "domain", translate("Default domain name"), nil)
domain.optional = true
domain.datatype = "string"

t1 = s:option (Value, "T1", translate("Renew address after"), translate("Time in seconds, after client should be able to renew address"))
t1.default = '600'
t1.datatype = "integer" 

t2 = s:option (Value, "T2", translate("Rebind after"), translate("Time after client should send rebind packet"))
t2.default = '1200'
t2.datatype = "integer"

sip_server = s:option (Value, "sip_server", translate("SIP server"), nil)
sip_server.optional = true
sip_server.datatype = "ip6addr"

sip_domain = s:option (Value, "sip_domain", translate("SIP domain"), nil)
sip_domain.optional = true
sip_domain.datatype = "string"

--[[
aftr = s:option (Value, "aftr", translate("Tunnel endpoint for DS-Lite (AFTR)"), nil)
aftr.optional = true
aftr.datatype = "ip6addr"

aftr_fqdn = s:option (Value, "aftr_fqdn", translate("Tunnel endpoint hostname (FQDN) for DS-Lite (AFTR)"), nil)
aftr_fqdn.optional = true
aftr_fqdn.datatype = "host"
]]--

ntp_server = s:option (Value, "ntp_server", translate("NTP server"), nil)
ntp_server.optional = true
ntp_server.datatype = "host"


time_zone = s:option (Value, "time_zone", translate("Time zone"), nil)
time_zone.optional = true
time_zone.default = "GMT"

prefered_lifetime = s:option (Value, "prefered_lifetime", translate("Preferred lifetime"), translate("Preferred lease lifetime in seconds"))
prefered_lifetime.default = '3600'
prefered_lifetime.datatype = "integer"

valid_lifetime = s:option (Value, "valid_lifetime", translate("Valid lifetime"), nil)
valid_lifetime.default = '7200'
valid_lifetime.datatype = "integer"

return m

 