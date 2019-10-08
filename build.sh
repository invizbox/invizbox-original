#!/bin/bash

set -e

version=$(grep CONFIG_VERSION_NUMBER src/.config | cut -d '"' -f 2)

echo "Preparing the openwrt directory..."
resources/clone_or_update.bash openwrt
rsync -avh  src/files/ openwrt/files/ --delete
cp src/feeds.conf openwrt/
cp src/.config openwrt/
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig

echo "Building the firmware"
sed -e "s,@VPN_PROVIDER@,invizbox," -e "s,@IB_VERSION@,${version}," ../src/files/etc/config/update > files/etc/config/update
sed "s,@IB_VERSION@,${version}," ../src/files/etc/banner > files/etc/banner
make -j $(($(grep -c processor /proc/cpuinfo)))
echo "All Done!"
