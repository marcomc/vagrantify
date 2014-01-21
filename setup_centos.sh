#!/bin/bash
# configure eth0 to be loaded at boot
sed -i 's/.*ONBOOT.*/ONBOOT=yes/'  /etc/sysconfig/network-scripts/ifcfg-eth0

# reconfigure the hostname
sed -i 's/.*HOSTNAME.*/HOSTNAME=centos65.localdomain/' /etc/sysconfig/network

# activate eth0 as by default seems to be down
ifup eth0

# make sure that the system is updated at the latests release
yum -qy upgrade

# install desired packages
yum -q -y install vim make screen man openssh-server openssh-client

# create the sudo group
groupadd sudo
echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers


