# B2NOTE Virtual machine

Vagrant template for VM with B2NOTE

Requirement: 
- HW: 1 CPU, 2 GB RAM, 5-50GB disk space.
- OS: Any OS supported by VirtualBox and Vagrant tool (tested on Windows 7,Windows 10, Ubuntu 16.04)
- SW: Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads.html) tested version 2.1.1. Some OS has their own distribution of vagrant and virtualbox: `yum install vagrant virtualbox` OR `apt install vagrant virtualbox`.

Type in your command line:

```bash
git clone https://github.com/TomasKulhanek/B2NOTE-VirtualMachine.git
cd B2NOTE-VirtualMachine
vagrant up
```

Port forwarding is done from guest VM 80 to host 8080 by default. After that B2NOTE is available at http://localhost:8080
