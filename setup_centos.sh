#!/bin/bash
# configure eth0 to be loaded at boot
# http://blog.vandenbrand.org/2012/02/21/creating-a-centos-6-2-base-box-for-vagrant/

# enable the ethernet card to be loaded at oot, apparently not the default beahviour
sed -i 's/.*ONBOOT.*/ONBOOT=yes/'  /etc/sysconfig/network-scripts/ifcfg-eth0

# activate eth0 as by default seems to be down
ifup eth0

# set the hostname
sed -i "s/.*HOSTNAME.*/HOSTNAME=$VAGRANT_HOSTNAME/" /etc/sysconfig/network

# make sure that the system is updated at the latests release
yum -qy upgrade

# install desired packages
yum -q -y install vim make screen man openssh-server openssh-client

# spring cleaning
yum clean all -q
