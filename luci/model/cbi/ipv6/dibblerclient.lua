--[[
LuCI - Lua Configuration Interface

Copyright 2012 Bartosz Nowicki <barteq@kretyn.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id: dibblerclient.lua 1 2012-09-23 20:22:36Z bn $ 

]]--

local uci = luci.model.uci.cursor()
local fs = require "nixio.fs"
require "posix"
require "luci.fs"
require "luci.sys"
require "luci.util"

local pidfile = "/var/lib/dibbler/client.pid"

pid = fs.readfile(pidfile)                

if pid then -- check if process is still running
	posix.setenv("LUA_PID",pid)
	local f = io.popen("ps -ef | awk '{ print $1 }' | grep ^$LUA_PID$") 
	local l = f:read("*a")

	-- stripping newlines (thanks to http://stackoverflow.com/questions/132397/get-back-the-output-of-os-execute-in-lua)
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

m = Map ("dibblerclient", "DHCPv6 client configuration", "Dibbler-client - portable DHCPv6 client implementation")
s = m:section (TypedSection, "interface", "Interface configuration", nil)

s:tab("general", translate("General settings"))
s:tab("options", translate("Requested options"))



interface = s:taboption ("general", Value, "interface", translate("WAN interface"), translate("Name of the WAN interface"))
interface.default = uci:get("network", "wan", "ifname")
interface.rmempty = false
for i,d in ipairs(luci.sys.net.devices()) do
	if d ~= "lo" then
		interface:value(d)
	end
end

downlink_prefix_ifaces = s:taboption ("general", Value, "downlink_prefix_ifaces", translate("LAN interfaces"), translate("Names of the LAN interfaces (minimum one)"))
downlink_prefix_ifaces.default = "br-lan"
downlink_prefix_ifaces.optional = true
for i,d in ipairs(luci.sys.net.devices()) do
	if d ~= "lo" then
		downlink_prefix_ifaces:value(d)
	end
end
                                

t1 = s:taboption ("general", Value, "T1", translate("Renew address after (seconds)"), translate("Time after client should be able to renew address (hint only)"))
t1.optional = true
t1.default = "600"
t1.datatype = "integer"

t2 = s:taboption ("general", Value, "T2", translate("Rebind after (seconds)"), translate("Time after client should send rebind packet (hint only)"))
t2.optional = true
t2.default = "1200"
t2.datatype = "integer"

prefered_lifetime = s:taboption ("general", Value, "prefered_lifetime", translate("Preferred lifetime (seconds)"), translate("Preferred lease time"))
prefered_lifetime.default = '3600'
prefered_lifetime.datatype = "integer"
prefered_lifetime.optional = true

valid_lifetime = s:taboption ("general", Value, "valid_lifetime", translate("Valid lifetime (seconds)"), nil)
valid_lifetime.default = '7200'
valid_lifetime.datatype = "integer"
valid_lifetime.optional = true

ia = s:taboption ("options", Flag, "ia", translate("IA - regular address (Identity Association for Non-temporary Addresses)"))
ia.rmempty = false
ia.default = true

pd = s:taboption ("options", Flag, "pd", translate("PD - prefix delegation (Identity Association for Prefix Delegation)"))
pd.rmempty = false
pd.default = true

ta = s:taboption ("options", Flag, "ta", translate("TA - temporary address (Indentity Association for Temporary Addresse)"))
ta.rmempty = false
ta.optional = true
ta.default = 0 

dns_server = s:taboption ("options", Flag, "dns_server", translate("DNS server"), nil)                                                                         
dns_server.rmempty = false                                                                                                                                     
dns_server.default = true         

domain = s:taboption ("options", Flag, "domain", translate("Default domain name"), nil)
domain.optional = true

sip_server = s:taboption ("options", Flag, "sip_server", translate("SIP server"), nil)
sip_server.optional = true

sip_domain = s:taboption ("options", Flag, "sip_domain", translate("SIP domain"), nil)
sip_domain.optional = true

aftr = s:taboption ("options", Flag, "aftr", translate("Tunnel endpoint for DS-Lite (AFTR)"), nil)
aftr.optional = true

ntp_server = s:taboption ("options", Flag, "ntp_server", translate("NTP server"), nil)
ntp_server.optional = true

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
log_level.default=syslog

if pid ~= 0 then
	processid = g:option (DummyValue, "processid", translate("Dibbler-client process ID"),nil)
	processid.default = pid
end

if luci.sys.init.enabled('dibblerclient') then 
	btn = g:option(Button, "_btn", translate("Disable"), nil)
	btn.inputstyle = "remove"	
	function btn.write()
		luci.sys.init.disable('dibblerclient')
		-- luci.sys.process.signal(pid, 15)
		luci.sys.call('/etc/init.d/dibblerclient stop')
		luci.http.header("refresh","1")
	end
else
	btn = g:option(Button, "_btn", translate("Enable"), nil)
	btn.inputstyle = "apply"
	function btn.write()
		luci.sys.init.enable('dibblerclient')
		luci.sys.call('/etc/init.d/dibblerclient start')
		luci.http.header("refresh","1")
	end
end

return m
