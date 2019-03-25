#!/usr/bin/env bash
# this script prepares web server, opens ports on firewall
#one of the configuration is syslog - need to restart
service rsyslog restart

# install apache

#chown -R apache:apache /var/www/html
#chmod -R 644 /var/www/html
#find /var/www/html -type d -exec chmod ugo+rx {} \;

yum -y install epel-release
yum-config-manager --save --setopt=epel/x86_64/metalink.skip_if_unavailable=true
yum repolist

yum -y install httpd

systemctl start httpd
systemctl enable httpd

# allow 80 port in firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# disable selinux, by default enabled, httpd cannot initiate connection otherwise etc.
setenforce 0
sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

## install mongodb
yum -y install mongodb
systemctl start mongodb
systemctl enable mongodb

# put initial db into mongodb
mongo admin bootstrapmongo.js

# create b2note app dir
mkdir /srv/b2note
mkdir /etc/b2note
mkdir -p /opt/b2note
chmod ugo+rwx /srv/b2note
#add permission to allow browse webdav content in /srv/virtualfolder
chmod go+rx /home/vagrant
chown apache:apache /srv/b2note

#
yum -y install git
git clone https://github.com/EUDAT-B2NOTE/b2note.git
#yum -y install django mongodb
yum -y install python-pip
pip install --upgrade pip
cd b2note
pip install virtualenv
virtualenv venv 
# put settings into activate script
cat <<EOT >> /home/vagrant/b2note/venv/bin/activate
# DJANGO B2NOTE variables:
export MONGODB_NAME='b2notedb'
export MONGODB_USR='b2note'
export MONGODB_PWD='b2note'
export SQLDB_NAME='/home/vagrant/b2note/users.sqlite3'
export SQLDB_USR='b2note'
export SQLDB_PWD='b2note'
export VIRTUOSO_B2NOTE_USR='b2note'
export VIRTUOSO_B2NOTE_PWD='Eudat_2016;'
export B2NOTE_SECRET_KEY="ner-x(&1032%5gpx7wc*+(kh6+3!+qxt(t@8!^ky5t5w=@_g0j"
export B2NOTE_PREFIX_SW_PATH='/home/vagrant/b2note'
#export EMAIL_SUPPORT_ADDR='b2note.temp@gmail.com'
export EMAIL_SUPPORT_ADDR='b2note-support'
export EMAIL_SUPPORT_PWD='ysayw1fL2n'
export SUPPORT_EMAIL_ADDR='b2note@bsc.es'
export SUPPORT_EMAIL_PWD='YpWKaJhR'
export SUPPORT_DEST_EMAIL='eudat-b2note-support@postit.csc.fi'
EOT
source venv/bin/activate
pip install django-simple-captcha
pip install -r requirements.txt
pip uninstall django
pip install git+https://github.com/django-nonrel/django@nonrel-1.5
pip install git+https://github.com/django-nonrel/djangotoolbox
pip install git+https://github.com/django-nonrel/mongodb-engine
pip install mongoengine django-countries oic

./manage.py syncdb --noinput
# sqlite3 users.sqlite3

yum -y install sqlite

./manage.py syncdb --database=users --noinput
# create run script
cat <<EOT > /home/vagrant/b2note/runserver.sh
#!/usr/bin/env bash
source /home/vagrant/b2note/venv/bin/activate
cd /home/vagrant/b2note/
/home/vagrant/b2note/manage.py runserver
EOT
chmod +x /home/vagrant/b2note/runserver.sh
chown -R vagrant:vagrant /home/vagrant/b2note

# start django after boot

cat <<EOT > /etc/systemd/system/b2note.service
[Unit]
Description=B2NOTE Service
After=autofs.service

[Service]
Type=simple
#EnvironmentFile=/home/vagrant/b2note/venv/bin/activate
PIDFile=/var/run/westlife-metadata.pid
User=vagrant
ExecStart=/home/vagrant/b2note/runserver.sh
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=b2note
WorkingDirectory=/home/vagrant/b2note/

[Install]
WantedBy=multi-user.target
EOT
chown vagrant:vagrant /tmp/b2note.log
# set debug
sed -i -e "s/^DEBUG =.*$/DEBUG = True/g" /home/vagrant/b2note/b2note_devel/settings.py
# start django now
systemctl start b2note
systemctl enable b2note


# apache proxy to django
cat <<EOT >> /etc/httpd/conf.d/b2note.conf
<Location />
  ProxyPass http://127.0.0.1:8000/
  ProxyPassReverse http://127.0.0.1:8000/
</Location>
EOT

service httpd restart

