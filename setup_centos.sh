#!/bin/bash
# configure eth0 to be loaded at boot
# http://blog.vandenbrand.org/2012/02/21/creating-a-centos-6-2-base-box-for-vagrant/

ROOT_DEVICE=/dev/sda
# Fixes unstable clocksource (which also generates tyoing delays in ssh connection)
sed -i "s/kernel.*$/& clocksource_failover=acpi_PM/g" /boot/grub/grub.conf
grub-install $ROOT_DEVICE

# enable the ethernet card to be loaded at oot, apparently not the default beahviour
sed -i 's/.*ONBOOT.*/ONBOOT=yes/'  /etc/sysconfig/network-scripts/ifcfg-eth0

# activate eth0 as by default seems to be down
ifup eth0

# set the hostname
sed -i "s/.*HOSTNAME.*/HOSTNAME=$VAGRANT_HOSTNAME/" /etc/sysconfig/network

curl -o epel-release-6.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm --quiet -ivh epel-release-6*.rpm

# install desired packages
yum -y -q install vim make gcc screen man openssh-server openssh-client autoconf.noarch kernel-devel-$(uname -r) 

# make sure that the system is updated at the latests release
yum -y -q upgrade

# spring cleaning
yum clean all -q
