#VM Preparation
1. Install Centos 6.5 or Ubuntu 10.13-server
2. Copy the 'vagrantme' script collection into the VM
3. Run common_vm_settings <vmname> (i.e. centos64-65 or ubuntu64-1013-server)
4. shutdown the VM

from the command-line of the host machine run:
```bash
vagrant package --base vagrant-ubuntu64-server-1310 -o ubuntu64-server.box
vagrant box add ubuntu64-server ubuntu64-server.box

vagrant package --base vagrant-centos64-65 -o centos64.box
vagrant box add centos64 centos64.box
```
#Setup of the vagrant vms
Create a folder to contain your vagrant VMs such as ~/vms/
##ubuntu64-server
Create a folder to contain your ubuntu64-server vagrant vm such as ~/vms/ubuntu64-server
Initialise the vagrant vm:
```bqsh
vagrant init ubuntu64-server
```
##cantos64
Create a folder to contain your ubuntu64-server vagrant vm such as ~/vms/centos64
Initialise the vagrant vm:
```bqsh
vagrant init centos64
```
Clone the 'vagrantme' scripts in the 'vagrant' folder that will be shared with between the host and the server
```bash
cd ~/vms/centos64/vagrant
git clone https://github.com/marcomc/vagrantme.git
```
#Vagrantfile for Centos vm
After initialising the folder tor the vagrant vm, add the following lines to the 'Vagrantfile' configuration
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
