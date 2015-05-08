--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>
Modified by InvizBox Ltd  - Copyright 2015 InvizBox Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local fs = require "nixio.fs"
require("luci.sys")
require("luci.sys.zoneinfo")
require("luci.tools.webadmin")
require("luci.fs")
require("luci.config")

m = Map("system", translate("Router Password"),
        translate("Changes the administrator password for accessing the device"))
m:chain("luci")
s = m:section(TypedSection, "system", translate("System Properties"))

s.anonymous = true
s.addremove = false

--s:tab("language",  translate("General Settings"))

o = s:option(ListValue, "_lang", translate("Language"))
o:value("auto", "English")

local i18ndir = luci.i18n.i18ndir .. "base."
for k, v in luci.util.kspairs(luci.config.languages) do
        local file = i18ndir .. k:gsub("_", "-")
        if k:sub(1, 1) ~= "." and luci.fs.access(file .. ".lmo") then
                o:value(k, v)
        end
end

function o.cfgvalue(...)
        return m.uci:get("luci", "main", "lang")
end

function o.write(self, section, value)
        m.uci:set("luci", "main", "lang", value)
end

pw1 = s:option(Value, "pw1", translate("Password"))
pw1.password = true

pw2 = s:option(Value, "pw2", translate("Confirmation"))
pw2.password = true

function s.cfgsections()
        return { "_pass" }
end

function m.on_commit(map)
        local v1 = pw1:formvalue("_pass")
        local v2 = pw2:formvalue("_pass")

        if v1 and v2 and #v1 > 0 and #v2 > 0 then
                if v1 == v2 then
                        if luci.sys.user.setpasswd(luci.dispatcher.context.authuser, v1) == 0 then
                                m.message = translate("Password successfully changed!")
                        else
                                m.message = translate("Unknown Error, password not changed!")
                        end
                else
                        m.message = translate("Given password confirmation did not match, password not changed!")
                end
        end
end


if fs.access("/etc/config/dropbear") then

m2 = Map("dropbear", translate("SSH Access"),
        translate("Dropbear offers <abbr title=\"Secure Shell\">SSH</abbr> network shell access and an integrated <abbr title=\"Secure Copy\">SCP</abbr> server"))

s = m2:section(TypedSection, "dropbear", translate("Dropbear Instance"))
s.anonymous = true
s.addremove = true
s.width = "100"

pt = s:option(Value, "Port", translate("Port"),
        translate("Specifies the listening port of this <em>Dropbear</em> instance"))

pt.datatype = "port"
pt.default  = 22


pa = s:option(Flag, "PasswordAuth", translate("Password authentication"),
        translate("Allow <abbr title=\"Secure Shell\">SSH</abbr> password authentication"))

pa.enabled  = "on"
pa.disabled = "off"
pa.default  = pa.enabled
pa.rmempty  = false


ra = s:option(Flag, "RootPasswordAuth", translate("Allow root logins with password"),
        translate("Allow the <em>root</em> user to login with password"))

ra.enabled  = "on"
ra.disabled = "off"
ra.default  = ra.enabled



s2 = m2:section(TypedSection, "_dummy", translate("SSH-Keys"),
        translate("Here you can paste public SSH-Keys (one per line) for SSH public-key authentication."))
s2.addremove = false
s2.anonymous = true
s2.width = "100%"
s2.template  = "cbi/tblsection"

function s2.cfgsections()
        return { "_keys" }
end

keys = s2:option(TextValue, "_data", "")
keys.wrap    = "off"
keys.rows    = 3
keys.rmempty = false

function keys.cfgvalue()
        return fs.readfile("/etc/dropbear/authorized_keys") or ""
end

function keys.write(self, section, value)
        if value then
                fs.writefile("/etc/dropbear/authorized_keys", value:gsub("\r\n", "\n"))
        end
end

end

return m, m2
