--[[
Copyright 2015 InvizBox Ltd

Licensed under the InvizBox Shared License;
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        https://www.invizbox.com/lic/license.txt
]]--

module("luci.controller.invizbox.invizbox_tor", package.seeall)

function index()
    entry({"invizbox", "tor"}, alias("invizbox", "tor", "status"),_("Tor"), 31)
    entry({"invizbox", "tor", "status"},cbi("invizbox_system/tor"),_("Admin"), 10).leaf = true
    entry({"invizbox", "tor", "toradvcfg"},cbi("invizbox_system/torrccfg"),_("Advanced"), 20).leaf = true

    entry({"invizbox", "torstatus", "status"}, template("invizbox_status/tor_status"), nil)
    entry({"invizbox", "torstatus", "restart"},  call("restart_tor"),  nil)
end
