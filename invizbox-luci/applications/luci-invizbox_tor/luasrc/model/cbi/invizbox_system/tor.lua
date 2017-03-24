--[[
Copyright 2015 InvizBox Ltd

Licensed under the InvizBox Shared License;
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        https://www.invizbox.com/lic/license.txt
]]--

fs = require "nixio.fs"
--sock = nixio.socket("inet", "stream")
require("luci.sys")
require("luci.util")
require("luci.cbi")
require("luci.fs")

bNewIdentity = 0  -- to only reset new identity
m = Map("system", translate("Tor Status and Configuration"),
	translate(""))

m:chain("luci")


s = m:section(TypedSection, "system", translate(""))
s.anonymous = true
s.addremove = false



s:tab("torstatus",  translate("Tor Status"))
s:tab("bridge",  translate("Bridge Configuration"))
s:tab("proxy", translate("Proxy Configuration"))
s:tab("geoip", translate("Country Options"))



--[[=======================TOR STATUS===============]]--

tor_restart_button = s:taboption("torstatus", Button, "_list", translate(""))
tor_restart_button.inputtitle = translate("Restart Tor")
tor_restart_button.inputstyle = "apply"
tor_restart_button.rmempty = true

function s.on_apply(self, section)
    luci.sys.call('/etc/init.d/tor restart')
end

tor_new_identity = s:taboption("torstatus", Button, "_link", "")
tor_new_identity.inputtitle = translate("New Identity")
tor_new_identity.rmempty = true
tor_new_identity.inputstyle = "link"
tor_new_identity.template = "invizbox_status/newidentity"


tor_refresh = s:taboption("torstatus", Button, "_list", "")
tor_new_identity.inputstyle = "link"
tor_refresh.template = "invizbox_status/refresh"

tor_status = s:taboption("torstatus", Value, "_data", "")
tor_status.legend = translate("Tor Connection Status")
tor_status.template = "invizbox_status/label"

tor_rec = s:taboption("torstatus", Value, "_data","" )
tor_rec.legend = "Tor Version"
tor_rec.template = "invizbox_status/label"

tor_circ = s:taboption("torstatus", Value, "_data", "")
tor_circ.legend = "Tor Circuit Status"
tor_circ.template = "invizbox_status/labelpure"



function tor_new_identity.write()

        returnstring = ""
        sock = nixio.socket("inet", "stream")
        if sock and sock:connect("127.0.0.1", 9051) then
            res, data = tor_request("AUTHENTICATE \"\"\r\n")
            if not res then
               returnstring = returnstring .. data
            end

-- current verion
            res, data = tor_request("SIGNAL NEWNYM\r\n")
            if not res then
                    returnstring = returnstring .. data
            end
        else
            returnstring = "Tor Not running"
        end
        bNewIdentity = 1
        sock:close()
        return returnstring
end

function tor_restart_button.write(self, section)
    luci.sys.call('/etc/init.d/tor restart')
end

function lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

function tor_status.cfgvalue()
        returnstring = ""
	sock = nixio.socket("inet", "stream")
        if sock and sock:connect("127.0.0.1", 9051) then
            res, data = tor_request("AUTHENTICATE \"\"\r\n")
            if not res then
                    returnstring = returnstring .. data
            end
-- Is tor connected and circuits established
            res, data = tor_request("GETINFO network-liveness\r\n")
            if not res then
                    returnstring = returnstring .. data
            end
            status = string.sub(data, string.find(data,"=%w*"))
            if status == "=up" then
                returnstring = returnstring .. "Connected to the Tor network"
            else
                returnstring = "Not connected to the Tor network (please allow up to 60 seconds if you have just applied changes, then click 'Refresh')"
            end
	else
            returnstring = "Tor Not running"
	end
        sock:close()
	return translate(returnstring)

end

function tor_rec.cfgvalue()
        returnstring = ""
	sock = nixio.socket("inet", "stream")
        if sock and sock:connect("127.0.0.1", 9051) then
            res, data = tor_request("AUTHENTICATE \"\"\r\n")
            if not res then
               returnstring = returnstring .. data
            end

-- current verion
            res, data = tor_request("GETINFO version\r\n")
            if not res then
                    returnstring = returnstring .. data
                return returnstring
            else
                returnstring = returnstring .. string.match(data, "%d.%d.%d.%d+") .. " : "

            end
-- current verion recomended
            res, data = tor_request("GETINFO status/version/current\r\n")
            if not res then
                    returnstring = returnstring .. data
                return returnstring
            else
                returnstring = returnstring .. string.match(data,"%w+",string.find(data,"="))
            end
        else
            returnstring = "Tor Not running"
        end
        sock:close()
        return returnstring

end

function tor_circ.cfgvalue()
        returnstring = ""
        temp_rtnstring = ""
        sock = nixio.socket("inet", "stream")
        if sock and sock:connect("127.0.0.1", 9051) then
            res, data = tor_request("AUTHENTICATE \"\"\r\n")
            if not res then
               returnstring = returnstring .. data
               return
            end

            res, data = tor_request("GETINFO circuit-status\r\n")
            if not res then
                    returnstring = returnstring .. data
                else
                    returnstring = string.gsub(string.gsub(data,"\r\n250 .+$",""),"^250\+[^\n]*","")
                    temp_arr = lines(returnstring)
                    for key,circstat in pairs(temp_arr) do
                       temp_rtnstring = temp_rtnstring .. string.gsub(circstat,"BUILD.*","") .. "<br>"
                    end
            end

            res, data = tor_request("QUIT\r\n")
        else
            returnstring = "Tor not running"
        end
        sock:close()

        return temp_rtnstring

end


function s.cfgsections()
      return { "_pass" }
end


function tor_request(command)
        if not sock:send(command) then
                return false, translate("Cannot send the command to Tor")
        end
        reply = ""
        resp = sock:recv(1000)
        while resp do
                reply = reply .. resp
                if string.len(resp) < 1000 then break end
                resp = sock:recv(1000)
        end

        if not resp then
                return false, translate("Cannot read the response from Tor")
        end
        i, j = string.find(reply, "^%d%d%d")
        if j ~= 3 then
                return false, "Malformed response from Tor"
        end
        code = string.sub(reply, i, j)
        if code ~= "250" and (code ~= "650" or command ~= "") then
                return false, "Tor responded with an error: " .. reply
        end

        return true, reply
end

--[[======================= BRIDGE CONFIG ===============]]--

zbridge_config = s:taboption("bridge", TextValue, "_data",translate("Bridge Configuration"),translate("Please enter in the bridges you want Tor to use, one per line.<br>The format is : \"ip:port [fingerprint]\" where fingerprint is optional. e.g. 121.101.27.4:443 4352e58420e68f5e40ade74faddccd9d1349413.<br> To get bridge information, see <a href=\"https://bridges.torproject.org/bridges\">the Tor bridges page</a>.<br><br>InvizBox also has pluggable transport support. We support  <a href=\"https://bridges.torproject.org/bridges?transport=obfs2\">obfs2</a>,  <a href=\"https://bridges.torproject.org/bridges?transport=obfs3\">obfs3</a> and <a href=\"https://bridges.torproject.org/bridges?transport=scramblesuit\">scramblesuit</a> bridges. Only use these bridge types if normal bridges are blocked for you."))
zbridge_config.wrap    = "off"
zbridge_config.rows    = 3
zbridge_config.cleanempty = true
zbridge_config.optional = true

function zbridge_config.cfgvalue()
    returnstring = ""
    file = io.open("/etc/tor/bridges", "r")
    while true do
        line = file:read()
        if line == nil then break end
        if line ~= "UseBridges 1" then
            returnstring = returnstring .. line:gsub("Bridge ", "") .. "\n"
        end
    end
        file:close()
    return returnstring

end


function zbridge_config.write(self, section, value)
    os.execute("echo -n > /etc/tor/bridges")
    formatted = ""
    if value and #value > 0 then
        formatted = "UseBridges 1\n" .. value:gsub("\r\n", "\n")
        formatted = formatted:gsub("\n\n", "")
        formatted = formatted:gsub("\n", "\nBridge ")
        formatted = formatted:gsub("Bridge \n", "")
                fs.writefile("/etc/tor/bridges", formatted )
    end
    if bNewIdentity == 0 then
        os.execute("cat /etc/tor/torrc.base /etc/tor/proxy /etc/tor/bridges /etc/tor/geoip > /etc/tor/torrc ; /etc/init.d/tor restart")
    end
end

--[[======================= PROXY CONFIG ===============]]--
proxy_config = s:taboption("proxy", ListValue, "proxy_config", translate("Proxy Type"))
proxy_config:value("None")
proxy_config:value("HTTP/HTTPS")
proxy_config:value("SOCKS4")
proxy_config:value("SOCKS5")

proxy_file_string = nil
local ip_from_file, port_from_file, username_from_file, password_from_file

function proxy_config.cfgvalue()
	file = io.open("/etc/tor/proxy", "r")
	proxy_config.default = "None"
	proxy_address.default = ""
	while true do
		if (file) then

			line = file:read()
			if line == nil then break end

			if line:find("HTTPSProxy ") then
				proxy_config.default = "HTTP/HTTPS"
				colonpos,j = line:find(":")
				ip_from_file = line:sub(12,colonpos - 1)
				port_from_file = line:sub(colonpos + 1)
			elseif line:find("Socks4Proxy ") then
				proxy_config.default = "SOCKS4"
				colonpos,j = line:find(":")
                                ip_from_file = line:sub(13,colonpos - 1)
                                port_from_file = line:sub(colonpos + 1)
			elseif line:find("Socks5Proxy ") then
				proxy_config.default = "SOCKS5"
				colonpos,j = line:find(":")
                                ip_from_file = line:sub(13,colonpos - 1)
                                port_from_file = line:sub(colonpos + 1)
			elseif line:find("Socks5ProxyUsername ") then
				username_from_file = line:sub(21)
			elseif line:find("Socks5ProxyPassword ") then
				password_from_file = line:sub(21)
			elseif line:find("HTTPSProxyAuthenticator ") then
				colonpos, j = line:find(":")
				username_from_file = line:sub(25, colonpos-1)
				password_from_file = line:sub(colonpos + 1)
			end
		else
			--create it
			file = io.open("/etc/tor/proxy", "w")
			file:write("")
			file:close()
		end
	end
end

function proxy_config.write(self, section, value)
	if (value == "None") then
		fs.unlink('/etc/tor/proxy')
		os.execute('touch /etc/tor/proxy')
        elseif (value == "HTTP/HTTPS") then
                proxy_file_string = "HTTPSProxy "
        elseif (value == "SOCKS4") then
		proxy_file_string = "Socks4Proxy "
        elseif (value == "SOCKS5") then
		proxy_file_string = "Socks5Proxy "
        end
end

proxy_address = s:taboption("proxy", Value, "proxy_address", translate("Proxy IP Address"))
proxy_address.placeholder = "192.168.1.5"
proxy_address.datatype = "ip4addr"

function proxy_address.cfgvalue()
	if (ip_from_file ~= nil) then
		proxy_address.default = ip_from_file
	else
		proxy_address.default = ""
	end
end

function proxy_address.write(self, section, value)
	if proxy_file_string ~= nil then
		proxy_file_string = proxy_file_string .. value .. ":"
	end
end

proxy_port = s:taboption("proxy", Value, "proxy_port", translate("Port"))
proxy_port.placeholder = "80"
proxy_port.datatype = "port"
proxy_port.rmempty = true

function proxy_port.cfgvalue()

end

function proxy_port.write(self, section, value)
	proxy_port.default = port_from_file
        if proxy_file_string ~= nil then
                proxy_file_string = proxy_file_string .. value .. "\n"
		--proxy_file_string = proxy_file_string .. "ReachableAddresses *:80,*:443\nReachableAddresses reject *:*\n"
		fs.writefile("/etc/tor/proxy", proxy_file_string)
        end
end


proxy_username = s:taboption("proxy", Value, "proxy_username", translate("Username"))
proxy_username.placeholder = "optional"
proxy_username.optional = true

function proxy_username.cfgvalue()
	proxy_username.default = username_from_file
end

function proxy_username.write(self, section, value)
        if (proxy_file_string ~= nil and value ~= nil) then
		if (proxy_file_string:find("HTTP")) then
			proxy_file_string = proxy_file_string .. "HTTPSProxyAuthenticator " .. value .. ":"
		elseif (proxy_file_string:find("Socks5")) then
			proxy_file_string = proxy_file_string .. "Socks5ProxyUsername " .. value .. "\n"
		end
        end
end


proxy_password = s:taboption("proxy", Value, "proxy_password", translate("Password"))
proxy_password.placeholder = "optional"
proxy_password.password = true
proxy_password.optional = true

function proxy_password.cfgvalue()
	proxy_password.default = password_from_file
end

function proxy_password.write(self, section, value)
        if (proxy_file_string ~= nil and value ~= nil) then
                if (proxy_file_string:find("HTTPSProxyAuthenticator")) then
                        proxy_file_string = proxy_file_string .. value .. "\n"
                elseif (proxy_file_string:find("Socks5ProxyUsername")) then
                        proxy_file_string = proxy_file_string .. "Socks5ProxyPassword " .. value .. "\n"
		end

		fs.writefile("/etc/tor/proxy", proxy_file_string)
	end
end

--[[======================= GEOIP CONFIG ===============]]--
geoip_file_string = nil
geoip_config = s:taboption("geoip", ListValue, "geoip_config", translate("Country Config"))
geoip_config:value("Use any exit node (default)")
geoip_config:value("Exclude \"Five Eyes\" countries")
geoip_config:value("Allow only countries selected below")
geoip_config:value("Do not use countries selected below")

function geoip_config.cfgvalue()
        file = io.open("/etc/tor/geoip_dropdown", "r")
        geoip_config.default = "Use any exit node (default)"
                if (file) then
			line = file:read()
			if line ~= nil then
				geoip_config.default = line
			end
		else
                        --something went wrong, create it
                        file = io.open("/etc/tor/geoip_dropdown", "w")
                        file:write("")
                        file:close()
                end
	file:close()
end

function geoip_config.write(self, section, value)
	fs.writefile("/etc/tor/geoip_dropdown", value)
	if (value == "Use any exit node (default)") then
		geoip_file_string = ""
		fs.unlink("/etc/tor/geoip")
	elseif (value == "Exclude \"Five Eyes\" countries") then
		geoip_file_string = "\nExcludeExitNodes {AU},{CA},{NZ},{UK},{US}\n"
		fs.writefile("/etc/tor/geoip", geoip_file_string)
	elseif (value == "Allow only countries selected below") then
		geoip_file_string = "\nExitNodes "
		fs.unlink("/etc/tor/geoip")
	elseif (value == "Do not use countries selected below") then
		geoip_file_string = "\nExcludeExitNodes "
		fs.unlink("/etc/tor/geoip")
	end
end


country_list = s:taboption("geoip", MultiValue, "country_list", translate("Countries:    (hold ctrl to select multiple)"))
country_list.widget = "select"
country_list.default = ""
country_list.size = 15
country_list:value("A1","Anonymous Proxies")
country_list:value("AR","Argentina")
country_list:value("AP","Asia/Pacific Region")
country_list:value("AU","Australia")
country_list:value("AT","Austria")
country_list:value("BY","Belarus")
country_list:value("BE","Belgium")
country_list:value("BR","Brazil")
country_list:value("BG","Bulgaria")
country_list:value("KH","Cambodia")
country_list:value("CA","Canada")
country_list:value("CL","Chile")
country_list:value("CO","Colombia")
country_list:value("CR","Costa Rica")
country_list:value("HR","Croatia")
country_list:value("CY","Cyprus")
country_list:value("CZ","Czech Republic")
country_list:value("DK","Denmark")
country_list:value("EG","Egypt")
country_list:value("EE","Estonia")
country_list:value("EU","Europe")
country_list:value("FI","Finland")
country_list:value("FR","France")
country_list:value("GE","Georgia")
country_list:value("DE","Germany")
country_list:value("GR","Greece")
country_list:value("GT","Guatemala")
country_list:value("GG","Guernsey")
country_list:value("HK","Hong Kong")
country_list:value("HU","Hungary")
country_list:value("IS","Iceland")
country_list:value("IN","India")
country_list:value("ID","Indonesia")
country_list:value("IE","Ireland")
country_list:value("IL","Israel")
country_list:value("IT","Italy")
country_list:value("JP","Japan")
country_list:value("KZ","Kazakhstan")
country_list:value("KE","Kenya")
country_list:value("KR","Korea","Republic of")
country_list:value("LV","Latvia")
country_list:value("LI","Liechtenstein")
country_list:value("LT","Lithuania")
country_list:value("LU","Luxembourg")
country_list:value("MK","Macedonia")
country_list:value("MY","Malaysia")
country_list:value("MT","Malta")
country_list:value("MX","Mexico")
country_list:value("MD","Moldova","Republic of")
country_list:value("MA","Morocco")
country_list:value("NA","Namibia")
country_list:value("NL","Netherlands")
country_list:value("NZ","New Zealand")
country_list:value("NG","Nigeria")
country_list:value("NO","Norway")
country_list:value("PK","Pakistan")
country_list:value("PA","Panama")
country_list:value("PL","Poland")
country_list:value("PT","Portugal")
country_list:value("QA","Qatar")
country_list:value("RO","Romania")
country_list:value("RU","Russian Federation")
country_list:value("A2","Satellite Provider")
country_list:value("SA","Saudi Arabia")
country_list:value("RS","Serbia")
country_list:value("SC","Seychelles")
country_list:value("SG","Singapore")
country_list:value("SK","Slovakia")
country_list:value("SI","Slovenia")
country_list:value("ZA","South Africa")
country_list:value("ES","Spain")
country_list:value("SE","Sweden")
country_list:value("CH","Switzerland")
country_list:value("TW","Taiwan")
country_list:value("TH","Thailand")
country_list:value("TR","Turkey")
country_list:value("UA","Ukraine")
country_list:value("GB","United Kingdom")
country_list:value("US","United States")
country_list:value("VE","Venezuela")
country_list:value("VN","Vietnam")


function country_list.cfgvalue()

--add selection parameters here
	country_list.default = ""
	file = io.open("/etc/tor/geoip", "r")
	if (file) then
		line = file:read("*all")
		countries = line:gsub(".* {", "")
		countries = countries:gsub("},{", " ")
		countries = countries:gsub("}", "")
		fs.writefile("/etc/tor/geoiptest", countries)
        	country_list.default = countries
	end



end

function country_list.write(self, section, value)
	line_length = geoip_file_string:len()
	if (line_length > 0) and (line_length < 20) then --not empty or five eyes
		countries = value:gsub(" ", "},{")
		countries = "{" .. countries .. "}"
		geoip_file_string  = geoip_file_string .. countries
	end

	fs.writefile("/etc/tor/geoip", geoip_file_string)
end



return m
