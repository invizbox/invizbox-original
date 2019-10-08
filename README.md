This repository contains the code to build an InvizBox firmware (original white box hardware).

## Before building

### VPN Settings
* Edit the files in `src/files/etc/openvpn` so that they contain your own VPN configuration files
The files that are already there contain more information to help you initially.

  * `openvpn.conf` should contain your default config (aka initially selected when flashing)
  * `files/` should contains OVPN files 
  * `templates/` can be create templates if your ovpn files are identical apart from the server IP/hostname

* Edit `src/files/etc/config/vpn` as it should now be modified to define your VPN locations based on what you created 
in the previous point.

Note: If you own an original InvizBox, you can duplicate the /etc/openvpn setup from it to get started.

### Default Password
* If you own an original InvizBox, the passwords will be set to the flashed defaults
* If you DO NOT own an original InvizBox and are trying to flash on another router, consider that the initial password
is most likely going to be TOKENPASSWORD (see `src/files/etc/config/wireless`). At this stage, you may want to consider
that the code here reads and writes from a specific part of mtd2 and you need to be sure that it suits your device. The
risks are that you could be overwriting something unexpected on your device mtd2 (I'd consider being able to run a
recovery via serial/tftp before trying this)

### Updating
If you want to get VPN updates from the Invizbox VPN update server, you can enable the `CONFIG_PACKAGE_update` setting
in the src/.config file. (tweaks available to only get some types of updates in `src/files/etc/config/update`)

### DNS and DNS leaking
In `src/files/etc/config/dhcp`, the current DNS values (8.8.8.8 and 8.8.4.4) point to the Google DNS servers.
If you want to use your VPN provider's DNS servers, make sure to edit that file and change the servers
from 8.8.8.8 and 8.8.4.4 to whatever your VPN provider DNS servers are (don't forget the @tun0 after the IP address
when doing so)

## Building an InvizBox firmware

* Use a build environment in which you can already successfully build OpenWRT
* Run ./build.sh
* Find the sysupgrade file in 
  `openwrt/bin/targets/ramips/mt7620/invizbox-openwrt-ramips-mt7620-invizbox-squashfs-sysupgrade.bin`

The build.sh script will create an `openwrt` directory and build your firmware there using the `src/.config` and 
`src/feeds.conf` files.

Enjoy!

The Invizbox Team.
