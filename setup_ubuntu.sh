#!/bin/bash
# set the hostname
echo $VAGRANT_HOSTNAME > /etc/hostname
# make sure that the system is updated at the latests release
#
# updates the system
apt-get -q update && sudo apt-get -q dist-upgrade

# install desired packages
apt-get -q install ssh vim screen make git-core gcc

# spring cleaning
apt-get -q clean
