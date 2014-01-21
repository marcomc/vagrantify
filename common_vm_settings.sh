#!/bin/bash
# Setup vm
OS="$1"
VAGRANT_HOSTNAME="vagrant-$OS"
VAGRANT_DOMAIN="vagrantup.com"
ROOT_PWD="vagrant"
MAIN_ACCOUNT="vagrant"
MAIN_ACCOUNT_PWD="vagrant"
ADMIN_GROUP="admin"


# blacklist the modules not necessary for a vm
MODULES_BLACKLIST_FILE="/etc/modprobe.d/blacklist-vagrant.conf"
MODULES_BLACKLIST="usb i2c snd sound parport"
read -a LIST_OF_MODULES <<< "$MODULES_BLACKLIST"
for modulename in ${LIST_OF_MODULES[@]}
do
    lsmod | cut -d " " -f1 | grep $modulename | sed 's/^/blacklist /g' >> $MODULES_BLACKLIST_FILE
done


# set the root password
echo root:$ROOT_PWD | chpasswd

# Create admin group and allow it for sudo NOPASSWORD capability
groupadd $ADMIN_GROUP -f
sed -i "/$ADMIN_GROUP/d" /etc/sudoers
echo "%$ADMIN_GROUP   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# create the vagrant user
bash ./create_new_user.sh $MAIN_ACCOUNT $MAIN_ACCOUNT_PWD $ADMIN_GROUP
curl -o /home/$MAIN_ACCOUNT/.ssh/id_rsa https://raw.github.com/mitchellh/vagrant/master/keys/vagrant
curl -o /home/$MAIN_ACCOUNT/.ssh/id_rsa.pub https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
# install the insecure vagrant private key pair


