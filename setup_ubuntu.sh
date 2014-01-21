#!/bin/bash
# set the hostname
echo $VAGRANT_HOSTNAME > /etc/hostname
# set the domain name
sed -i "/127.0.1.1/d" /etc/hosts #removes existing definitions
echo "127.0.1.1 $VAGRANT_HOSTNAME.$VAGRANT_DOMAIN $VAGRANT_HOSTNAME" >> /etc/hosts

# make sure that the system is updated at the latests release
#
# updates the system
apt-get -q update && sudo apt-get -q dist-upgrade

# install desired packages
apt-get -q install ssh vim screen make git-core
apt-get -q clean

update-alternatives --set  editor /usr/bin/vim.basic


