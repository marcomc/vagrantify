# make sure that the system is updated at the latests release

OS="ubuntu64-server-13.10"
# updates the system
apt-get -q update && sudo apt-get -q dist-upgrade

# install desired packages
apt-get -q install ssh vim screen make git-core

update-alternatives --set  editor /usr/bin/vim.basic

# set the standard vagrant setup
bash ./common_vm_settings.sh $OS

