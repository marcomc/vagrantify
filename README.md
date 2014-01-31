#Virtual Machines Preparation
##Run VirtualBox
Install Centos 6.5 or Ubuntu 10.13-server as two new VirtualBox.
> advised to set up an initial admin user called 'user'

Log in to each virtual machine.

Install the VirtualBox Guest Additions:
    1. Click on "VirtualBOX VM (menu) -> Devices -> Insert Guest Additions CD image"
    2. In the Guest command-line type
```bash
sudo mount /dev/cdrom/ /media/cdrom
sudo /media/cdrom/VBoxLinuxAdditions.run
```

Copy the 'vagrantme' script collection into the VM.
```bash
cd /home/user/
wget https://github.com/marcomc/vagrantme/archive/master.zip
# may require the installation of the 'unzip' tool
unzip master.zip
```

From the 'vagrantme' directory withing the virtual machine run:
```bash
sudo common_vm_settings.sh <vm_hostname>
# <vm_hostname> could be centos64-65 or ubuntu64-1013
```

At the stage the 'root' user will be assigned the password 'vagrant'
> log out from the user 'user' and log in as root and delete the user 'user':
```bash
userdel -f -r user
``` 

##Now shutdown the virtual machine.
From the command-line of the host machine run:
```bash
vagrant package --base vagrant-ubuntu64-1310 -o ubuntu64.box
vagrant box add ubuntu64 ubuntu64.box

vagrant package --base vagrant-centos64-65 -o centos64.box
vagrant box add centos64 centos64.box
```
#Setup of the vagrant virtual machine
Create a folder to contain your vagrant VMs such as ~/vms/

##ubuntu64
Create a folder to contain your ubuntu64 vagrant virtual machine such as ~/vms/ubuntu64
Initialise the vagrant virtual machine:
```bqsh
mkdir ~/vms/ubuntu64
cd ~/vms/ubuntu64
vagrant init ubuntu64
```
##cantos64
Create a folder to contain your ubuntu64 vagrant virtual machine such as ~/vms/centos64
Initialise the vagrant vm:
```bqsh
mkdir ~/vms/centos64
cd ~/vms/centos64
vagrant init centos64
```
Clone the 'vagrantme' scripts in the 'vagrant' folder that will be shared with between the host and the server:
```bash
cd ~/vms/centos64/vagrant
git clone https://github.com/marcomc/vagrantme.git
```
#Vagrantfile for Centos vm
After initialising the folder tor the vagrant vm, add the following lines to the 'Vagrantfile' configuration:
```
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  config.vm.network :forwarded_port, guest: 443, host: 8443, auto_correct: true
  config.vm.network :forwarded_port, guest: 6081, host: 8081, auto_correct: true

  # Enable provisioning with Script stand alone.  Bash  manifests
  
  config.vm.provision "shell", path: "vagrantme/setup_centos_webserver.sh"
```
