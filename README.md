# B2NOTE Virtual machine
templates to prepare VM from scratch.

## Requirements

Requirement: 
- HW: 1 CPU, 2 GB RAM, 5-50GB disk space.
- OS: Any OS supported by VirtualBox and Vagrant tool (tested on Windows 7,Windows 10, Ubuntu 16.04)
- SW: Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads.html) tested version 2.1.1. Some OS has their own distribution of vagrant and virtualbox: `yum install vagrant virtualbox` OR `apt install vagrant virtualbox`.

## Local Installation Using Vagrant and Virtualbox

### Without authentication 
Type in your command line:

```bash
git clone https://github.com/e-sdf/B2NOTE-VirtualMachine.git
cd B2NOTE-VirtualMachine
vagrant up
```
### With authentication
Type in your command line:

```bash
git clone https://github.com/e-sdf/B2NOTE-VirtualMachine.git
cd B2NOTE-VirtualMachine
```
Now copy `script/devel-sample.sh` as `script/devel.sh` and fill the client id and secrets accordingly.

```bash
vagrant up
```
### After installation
After several minutes the VM is installed and configured. Port forwarding is done from guest VM 80 to host 8080 by default, reffer Vagrantfile for exact port number. After that B2NOTE is available at http://localhost:8080

## Local Installation of Development Environment

go into the directory with development option and start vagrant script from there.

E.g. for development branch on python 3

```bash
git clone https://github.com/TomasKulhanek/B2NOTE-VirtualMachine.git
cd B2NOTE-VirtualMachine/b2note-vm-py3
vagrant up
```

## Cloud Installation

In case your VM was prepared from templates of cloud providers (RHEL 7 derivatives are recommended, CENTOS 7, ...). Use the following procedure.

The following will bootstrap b2note environmnet in existing VM template.
```bash
mkdir /vagrant
cd /vagrant
wget https://raw.githubusercontent.com/e-sdf/B2NOTE-VirtualMachine/master/bootstrapmongo.js
wget https://raw.githubusercontent.com/e-sdf/B2NOTE-VirtualMachine/master/bootstrap.sh
dos2unix bootstrap.sh
# you may edit b2note.conf and other settings in bootstrap.sh script before launching
./bootstrap.sh
```

## manual installation

- install python pip 
`sudo yum -y install python-pip`
- install virtualenv
`sudo pip install virtualenv`
- clone b2note repository
`git clone https://github.com/EUDAT-B2NOTE/b2note.git`
- create virtualenv, cd into b2note repo
```
cd b2note
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```
- install mongodb
`sudo yum -y install mongodb-server`
- start mongodb
`sudo service mongod start`

TODO 

- create mongodb database
- set MONGODB_NAME before
- run django server
`./manage.py runserver`



