CONTENTS OF THIS FILE --------------------- 

* Introduction 
* Overview 
* Modules 
	* Aiccu 
	* Dibbler-server 
	* Dibbler-client 
	* DS-Lite 
	* IP46NAT 
* External documents 

INTRODUCTION ------------ 

Current maintainer and author of attached code: Bartosz Nowicki 
<barteqpl@gmail.com> 

Main goal of this project is to provide several methods of IPv6 
configuration using GUI on OpenWRT powered routers. It consists of 
several modules, providing ability to configure IPv6 using OpenWRT, LuCI 
based GUI. 

This includes full support for DHCPv6 client and server – Dibbler 
(homepage: http://klub.com.pl/dhcpv6/), graphical interface for AICCU 
tunnels provided by SixXS, DS-Lite support (automatic and manual tunnel 
creation) and IP46NAT translator (project website: 
http://klub.com.pl/ip46nat/). Support means full implementation of UCI, 
custom init scripts and LuCI based GUI. This file is intended to give an 
overview on how code works and tips for further development. 

Installation method is described in INSTALL file. 

OVERVIEW ------------ 

Provided code is platform independent. All files are interpretable 
scripts only, written mainly in ASH (works also on SH/BASH and probably 
others), and LUA. Code was tested on OpenWRT Backfire 10.03.1 with LuCI 
0.10. Please be aware that no tests were done on another distributions, 
especially currently developed “Attitude Adjustment” edition. USE IT 
ON YOUR OWN RISK. 

MODULES ------------ 

Schema of every module is exactly the same. This 
includes /etc/config/$modulename file, defining UCI structure [1]. Next 
part is /etc/init.d/$modulename – BASH script - that is used to start 
and stop application. This file should implement all parameters, 
previously defined in UCI file. Last element is LUA script, written in 
MVC framework, LuCI, which implements GUI. Due to MVC (Model, View, 
Controller) nature, all project files should use 3-layer methodology, 
but because of several benefits from LuCI CBI model, we can omit the 
View part. Views are created automatically, basing on definitions 
contained in the Model. All Model files are located in 
/usr/lib/lua/luci/model/cbi/ipv6/. Last part – the Controller - is 
implemented in only one file, located in 
/usr/lib/lua/luci/controller/ipv6/main.lua. This is also common part of 
every module. 

* AICCU ------------ 

Used files: 
	- /etc/config/aiccu *
	- /etc/init.d/aiccu *
	- /usr/lib/lua/luci/model/cbi/ipv6/aiccu.lua 

	* - files shipped with the newer version of aiccu model. These were 
	only backported to Backfire by module author 

AICCU is an AYIYA protocol client. Used mostly by SixXS, an IPv6 tunnel 
broker. AICCU module belonging to this project implements GUI only. UCI 
structure and init file was already provided by package maintainer. 

Main part of the module is aiccu.lua. This file uses all defined 
parameters from UCI. LUA part is also responsible for basic data 
validation and contains set of suggested values. All mandatory fields 
have an attribute “rmempty” set to false, that prevents creating not 
working configuration. 

* DIBBLER SERVER ------------ 

This module uses files: 
	- /etc/config/dibblerserver 
	- /etc/init.d/dibblerserver 
	- /usr/lib/lua/luci/model/cbi/ipv6/dibblerserver.lua 
	- /var/lib/dibbler/ * 

	* - files located in this directory are not related to module itself, 
	but are used by dibbler (client and server) [4]. In case of problems 
	it’s suggested to remove contents of this directory and re-run 
	appropriate processes 

Dibbler is a portable DHCPv6 implementation. This module implements only 
server part. 

UCI structure is split into two parts – connected to interface and 
second containing general values, like log level or log mode. 

Second part of the module is the init script. It creates all needed 
directories, including /tmp/run (that consists generated on the fly 
configuration) and /var/lib/dibbler/, which is used by dibbler itself. 
As a next step /tmp/run/dibbler-server.conf file is generated, based on 
the values set using UCI interface. All values are being checked in case 
they are empty. After generation, a new symlink is created from 
/tmp/run/dibbler-server.conf to /etc/dibbler/server.conf that 
corresponds to dibbler-server default configuration file location. 

Third and the last one is GUI. CBI model is more sophisticated that the 
AICCU one. First of all it allows checking process status, and for the 
second can enable or disable dibbler-server from the system processes 
list. This can be also done by System -> Startup menu, but having it in 
the same place is simpler for the user. To achieve this, several LUA 
modules must be used, that includes: nixio.fs, posix, luci.fs, luci.sys 
and luci.util. It also utilized dibbler created PID file, located in 
/var/lib/dibbler/server.pid in order to check processes existence. 
Please be aware that manually killing dibbler-server can break this 
functionality. After checking PID file contents, and comparing to 
process list, new value called ‘pid’ is created. If it differs from 
0, module assumes that dibbler-server is running. Next there are 
definitions of all UCI keys with basic checks against improper values. 
Last part of module is status checker and button allowing service to be 
enabled to disabled. Status filed simply shows ‘pid’ value (if 
different from 0). Button, depending on what user wants, enables or 
disables service (using luci.sys.init.enable() or disable() function) 
and starts or stops it using standard system call. 

Last part is not straightforward. Dibbler, like all other DHCPv6 servers 
is not able to broadcast router address. To achieve this it uses RADVD 
daemon. In order to work properly, please check if radvd is properly 
configured. It needs Enable to be ‘ticked’ on LAN interface and on 
Routes. Basic UCI configuration example below: 

config 'interface'
        option 'interface' 'lan'
        option 'AdvSendAdvert' '1'
        option 'ignore' '0'
        option 'IgnoreIfMissing' '1'
        option 'AdvManagedFlag' '1'
        option 'AdvSourceLLAddress' '1'

config 'route'
        option 'interface' 'lan'
        option 'ignore' '0'

* DIBBLER CLIENT ------------ 

Files: 
	- /etc/config/dibblerclient 
	- /etc/init.d/dibblerclient
	- /etc/hotplug.d/iface/35-dibbler 
	- /usr/bin/dibbler.sh 
	- /usr/lib/lua/luci/model/cbi/ipv6/dibblerclient.lua 
	- /var/lib/dibbler/ * 

	* same as in dibbler-server 

UCI and startup script is almost identical with dibbler-server. 
Differences start with /usr/bin/dibbler.sh script. It’s used as an 
auto configuration interface. Dibbler-client allows using such file. It 
also passes arguments to the script, depending on what daemon received. 
This includes actions add, update or delete. In case dibbler-server 
service is enabled and we are requesting a Prefix Delegation (PD) field, 
this script automatically assigns prefix to LAN interface and also sets 
dibbler-server’s UCI value for delegated pool. Afterwards 
dibbler-server daemon is being restarted to propagate newly assigned 
values. In case radvd is not running script also tries to run this 
daemon. This check however is based on existence of /var/run/radvd.pid 
that might exist even if radvd doesn’t work. 

LuCI part, dibblerclient.lua is almost identical to dibbler-server one. 
Please refer server documentation. 

Last part of the module is /etc/hotplug.d/iface/35-dibbler file. It 
automatically enables client if wan link is back again or was not 
available while startup. 

* DS-LITE ------------ 

Used files: 
	- /etc/config/dslite 
	- /etc/init.d/dslite 
	- /usr/lib/lua/luci/model/cbi/ipv6/dslite.lua 
	- /usr/bin/dibbler.sh 

DS-Lite module is little bit different from other ones. It doesn’t 
need anything more than kmod-iptunnel6 to work, but all automation 
scripts uses dibbler-client. 

It consists of very limited standard UCI file that keeps only two 
parameters – automatic and aftr. Main part of the module is startup 
script that creates a softwire tunnel, depending on the AFTR endpoint IP 
address. Be aware that it’s an experimental module, thus it also 
DISABLES FIREWALL (both for IPv4 and IPv6) in order to work. Working 
together with FW is on to do list. 

Next part is LuCI module that allows not only setting parameters but 
also checks tunnel status and allows enabling or disabling it instantly. 

Most tricky unit is dibbler.sh that can automatically set up a tunnel 
under several conditions. If automatic mode is enabled AND dslite module 
is enabled AND dibbler-client asks for AFTR address AND server responds 
with an address then it’s being created. 

* IP46NAT ------------ 

Used files: 
	- /etc/config/ip46nat 
	- /etc/init.d/ip46nat 
	- /usr/lib/lua/luci/model/cbi/ipv6/ip46nat.lua 
	- /lib/modules/2.6.32.27/ip46nat.ko * 

	* kernel module is an essential part 

First of all be aware that using module with all other IPv6 services is 
problematic. It’s intended to work alone, with router dedicated ONLY 
for IPv4 to IPv6 translation. Due to that limit it always disables any 
of the working firewalls and enables IP forwarding for both protocols. 
It also adds a new firewall rule to prevent creation of duplicated 
packages. It’s essential for proper operation and it’s done for IPv4 
only [5]. 

As usual module consists of UCI structure, defining all available kernel 
module parameters. Second part is init scripts that loads ip46nat.ko, 
disables firewall and adds a rule to cut off duplicated packages 
generation. 

Last part is LuCI related. GUI allows setting all values but also 
displays kernel module status. It uses two module provided procfs files 
- /proc/ip46nat/params and /proc/ip46nat/stats, to display an actual 
configuration parameters and module status. From LuCI we can also 
disable or enable the translator. 

EXTERNAL DOCUMENTS ------------ 

[1] UCI documentation - http://wiki.openwrt.org/doc/uci 
[2] LuCI reference - http://luci.subsignal.org/trac/wiki/Documentation 
[3] LuCI CBI - http://luci.subsignal.org/trac/wiki/Documentation/CBI 
[4] Dibbler - http://klub.com.pl/dhcpv6/ 
[5] IP46NAT documentation - http://klub.com.pl/ip46nat/ 

