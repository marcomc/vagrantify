#VM Preparation
1* Install Centos 6.5 or Ubuntu 10.13-server
2* Copy the 'vagrantme' script collection into the VM
3* Run common_vm_settings <vmname> (i.e. centos64-65 or ubuntu64-1013-server)
4* shutdown the VM

from the command-line of the host machine run:
* vagrant package --base vagrant-ubuntu64-server-1310 -o ubuntu64-server.box
* vagrant box add ubuntu64-server ~VirtualBox\ VMs/ubuntu64-server.box

* vagrant package --base vagrant-centos64-65 -o centos64.box
* vagrant box add centos64 ~/VirtualBox\ VMs/centos64.box

