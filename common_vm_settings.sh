#!/bin/bash
#
# Setup vm
#
# http://docs.vagrantup.com/v2/boxes/base.html
# https://github.com/fespinoza/checklist_and_guides/wiki/Creating-a-vagrant-base-box-for-ubuntu-12.04-32bit-server
# http://blog.vandenbrand.org/2012/02/21/creating-a-centos-6-2-base-box-for-vagrant/

# to modify so that the os is autodetectd via /etc/os-release or /etc/redhat-release files
OS="$1" # 'ubuntu64-server-xxx' or 'centos65xx'
#VARIANT="$2"
VAGRANT_HOSTNAME="vagrant-$OS" #-$VARIANT"
VAGRANT_DOMAIN="vagrantup.com"
ROOT_PWD="vagrant"
MAIN_ACCOUNT="vagrant"
MAIN_ACCOUNT_PWD="vagrant"
ADMIN_GROUP="admin"

# this checks what kind of OS we want to vagrantify, allowing the definition of personalised names for the os 
if echo $OS | grep centos - -q ;then
    source "./setup_cenotos.sh"
elif echo $OS | grep ubuntu - -q ; then
    source "./setup_ubuntu.sh"
fi

# set the domain name
sed -i "/127.0.1.1/d" /etc/hosts #removes existing definitions
echo "127.0.1.1 $VAGRANT_HOSTNAME.$VAGRANT_DOMAIN $VAGRANT_HOSTNAME" >> /etc/hosts

# blacklist the modules not necessary for a vm
MODULES_BLACKLIST_FILE="/etc/modprobe.d/blacklist-vagrant.conf"
MODULES_BLACKLIST="usb i2c snd sound parport"
read -a LIST_OF_MODULES <<< "$MODULES_BLACKLIST"
for modulename in ${LIST_OF_MODULES[@]}
do
    # run lsmod, grab just the name of the modules that match the undesired, and create a blacklist out of them that will be loaded by modprobe at the next restart
    lsmod | cut -d " " -f1 | grep $modulename | sed 's/^/blacklist /g' >> $MODULES_BLACKLIST_FILE
done

# In order to keep SSH speedy even when your machine or the Vagrant machine is not connected to the internet, set the UseDNS configuration to no in the SSH server configuration.
# remove any UseDNS setting from the sshd_config file
sed -i "/UseDNS/d" /etc/ssh/sshd_config
# add the UseDNS=no setting to the sshd_config file
echo 'UseDNS no' >> /etc/ssh/sshd_config

# set the ssh server to listen on port 2222
sed -i '/Port /d' /etc/ssh/sshd_config
echo 'Port 2222' >> /etc/ssh/sshd_config

# set the root password
echo root:$ROOT_PWD | chpasswd

# Create admin group and allow it for sudo NOPASSWORD capability
groupadd $ADMIN_GROUP -f

# updates the SSH_AUTH_SOCK settings in sudoers
sed -i '/SSH_AUTH_SOCK/d' /etc/sudoers
echo 'Defaults env_keep="SSH_AUTH_SOCK"' >> /etc/sudoers

# remove the current set up for the ADMIN group in the sudoers file
sed -i "/$ADMIN_GROUP/d" /etc/sudoers
# add a new set up for the ADMIN group in the sudoers file
echo "%$ADMIN_GROUP   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# create the vagrant user
bash ./create_new_user.sh $MAIN_ACCOUNT $MAIN_ACCOUNT_PWD $ADMIN_GROUP
curl -o /home/$MAIN_ACCOUNT/.ssh/vagrant https://raw.github.com/mitchellh/vagrant/master/keys/vagrant
chown $MAIN_ACCOUNT:$MAIN_ACCOUNT /home/$MAIN_ACCOUNT/.ssh/vagrant
curl -o /home/$MAIN_ACCOUNT/.ssh/vagrant.pub https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown $MAIN_ACCOUNT:$MAIN_ACCOUNT /home/$MAIN_ACCOUNT/.ssh/vagrant.pub

cat /home/$MAIN_ACCOUNT/.ssh/vagrant.pub >> /home/$MAIN_ACCOUNT/.ssh/authorized_keys
# install the insecure vagrant private key pair

# delete the user 'user' wich we probably did set up when we created the vm
# on ubunto this command will fail if we are running the script as sudo from the user 'user' itself
if [ -d "/home/user" ]; then
    userdel -f -r user
fi
