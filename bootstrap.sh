#!/usr/bin/env bash
# this script prepares web server, opens ports on firewall
#one of the configuration is syslog - need to restart
service rsyslog restart

chown -R apache:apache /var/www/html
chmod -R 644 /var/www/html
find /var/www/html -type d -exec chmod ugo+rx {} \;


yum -y install epel-release
yum-config-manager --save --setopt=epel/x86_64/metalink.skip_if_unavailable=true
yum repolist

yum -y install httpd

systemctl start httpd
systemctl enable httpd

# allow 80 port in firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# create b2note app dir
mkdir /srv/b2note
mkdir /etc/b2note
mkdir -p /opt/b2note
chmod ugo+rwx /srv/b2note
#add permission to allow browse webdav content in /srv/virtualfolder
chmod go+rx /home/vagrant
chown apache:apache /srv/b2note

