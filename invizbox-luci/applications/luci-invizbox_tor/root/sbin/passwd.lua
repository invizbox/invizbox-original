--[[
Copyright 2015 InvizBox Ltd

Licensed under the InvizBox Shared License;
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        https://www.invizbox.com/lic/license.txt
]]--
require("luci.sys")
luci.sys.user.setpasswd("root", arg[1])
