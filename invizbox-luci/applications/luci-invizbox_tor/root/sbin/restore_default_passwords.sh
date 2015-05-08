#!/bin/ash
#Copyright 2015 InvizBox Ltd
#
#Licensed under the InvizBox Shared License;
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#        https://www.invizbox.io/license.txt
PASSWORD=$(dd if=/dev/mtd2 bs=1 skip=65522 count=14)
sed -i "s/option key.*/option key '$PASSWORD'/" /etc/config/wireless
lua /sbin/passwd.lua "$PASSWORD"
