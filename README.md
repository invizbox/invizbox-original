# Invizbox.io

Invizbox is a hardware based Tor router

Web: https://www.invizbox.com/  
Twitter: https://twitter.com/invizbox/  
Reddit: https://www.reddit.com/r/invizbox  

## To start:

Get source of InvizBox  
`mkdir invizbox`  
`cd invizbox`  
`git clone https://github.com/invizbox/invizbox.git`


## Get source of openwrt - 15.05 branch:

Using http://wiki.openwrt.org/doc/howto/build


`cd openwrt`

`cd feeds`
`rm -rf luci` # removing tip luci and default config
`git clone https://github.com/openwrt/luci.git`
`cd luci`
`git checkout luci-0.12`


## Now Make InvizBox:

Using the files from the invizbox-firware and invizbox-luci proceed to build your InvizBox.

## What the folders are


`invizbox-firmware/`

 This folder contains the base Make files for Tor, obfsclient etc.


`invizbox-luci/`

 This folder contains the luci UI and configuration files to setup InvizBox.
