--[[
Copyright 2015 InvizBox Ltd

Licensed under the InvizBox Shared License;
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        https://www.invizbox.io/license.txt
]]--

module("luci.controller.invizbox.invizbox_tor", package.seeall)

function index()
	entry({"invizbox", "tor"}, cbi("invizbox_system/tor"), _("Tor"), 31)
    entry({"invizbox", "torstatus", "status"}, template("invizbox_status/tor_status"), nil)
    entry({"invizbox", "torstatus", "restart"},  call("restart_tor"),  nil)
end
