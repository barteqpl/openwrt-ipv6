--[[
LuCI - Lua Configuration Interface

Copyright 2012 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id: dibblerserver.lua 1 2012-09-13 20:22:36Z bn $ 

]]--

local fs = require "nixio.fs"
require "posix"
require "luci.fs"
require "luci.sys"
require "luci.util"

local pidfile = "/var/lib/dibbler/server.pid"

pid = fs.readfile(pidfile)

if pid then -- check if process is still running
	posix.setenv("LUA_PID",pid)
	local f = io.popen("ps -ef | awk '{ print $1 }' | grep ^$LUA_PID$")
	local l = f:read("*a")

	l = string.gsub(l, '^%s+', '')
	l = string.gsub(l, '%s+$', '')
	l = string.gsub(l, '[\n\r]+', ' ')
	
	f:close()
	if l ~= pid then
		pid = 0
	end
                                                                                              
	else
		pid = 0
end
	
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

g = m:section (TypedSection, "default", "General configuration", nil)

log_level = g:option (ListValue, "log_level", "Log level")
log_level:value("1","1 - Emergency")
log_level:value("2","2 - Alert")
log_level:value("3","3 - Critical")
log_level:value("4","4 - Error (default)")
log_level:value("5","5 - Warning")
log_level:value("6","6 - Notice")
log_level:value("7","7 - Info")
log_level:value("8","8 - Debug")
log_level.default=4

log_mode = g:option (ListValue, "log_mode", "Log mode")
log_mode:value("short", "Short")
log_mode:value("full", "Full")
log_mode:value("precise", "Precise") 
log_mode:value("syslog", "Syslog")
log_level.default=short

if pid ~= 0 then
	processid = g:option (DummyValue, "processid", translate("Dibbler-server is enabled and running. Process ID"),nil)
	processid.default = pid
end
                
if luci.sys.init.enabled('dibblerserver') then
	
	btn = g:option(Button, "_btn", translate("Disable"), nil)
	btn.inputstyle = "remove"
	
	function btn.write()
		luci.sys.init.disable('dibblerserver')
		luci.sys.process.signal(pid, 15)
	end

else

	btn = g:option(Button, "_btn", translate("Enable"), nil)
	btn.inputstyle = "apply"
	
	function btn.write()
		luci.sys.init.enable('dibblerserver')
		luci.sys.call('/etc/init.d/dibblerserver start')
	end
	
end
return m
