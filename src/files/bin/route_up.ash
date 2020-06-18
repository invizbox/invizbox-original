#!/bin/sh

# Copyright 2020 InvizBox Ltd
#
# Licensed under the InvizBox Shared License;
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        https://www.invizbox.com/lic/license.txt

gateway_ip=`uci get network.lan.ipaddr`
ip route add 127.0.0.0/8 dev lo table 1
ip route add default via ${route_vpn_gateway} dev ${dev} table 1
ip rule add from ${gateway_ip%?}0/24 table 1
mkdir -p /tmp/openvpn/1/
echo "up" > /tmp/openvpn/1/status
