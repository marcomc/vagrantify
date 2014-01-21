NEW_USER_NAME="$1" # substitute with $1
NEW_USER_HOME="/home/$NEW_USER_NAME" 
NEW_USER_PASSWORD="$2"  # substitute with $2
#RSA_PUB_KEY_URL="" #used if we complete the function
SUDO_GROUP="$3"

# creation of a $NEW_USER_NAME user on each server
useradd $NEW_USER_NAME --password "" -m -d $NEW_USER_HOME -s /bin/bash
echo $NEW_USER_NAME:$NEW_USER_PASSWORD | chpasswd
mkdir $NEW_USER_HOME/.ssh
touch $NEW_USER_HOME/.ssh/authorized_keys
chown -R $NEW_USER_NAME:$NEW_USER_NAME $NEW_USER_HOME/.ssh
chmod -R go-rwx $NEW_USER_HOME/.ssh

# add user the the sudo group
gpasswd -a $NEW_USER_NAME $SUDO_GROUP

# install the SSH2 RSA Public key of the $NEW_USER_NAME user of the nagios/icinga server
# curl -o $NEW_USER_NAME_rsa_key.pub $RSA_PUB_KEY_URL
# cat $NEW_USER_NAME_rsa_key.pub >> $NEW_USER_HOME/.ssh/authorized_keys
# rm $NEW_USER_NAME_rsa_key.pub

