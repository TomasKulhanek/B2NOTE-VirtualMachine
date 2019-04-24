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
yum -y install mongodb mongodb-server
systemctl start mongod
systemctl enable mongod

# put initial db into mongodb
mongo admin /vagrant/bootstrapmongo.js

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
git clone https://github.com/e-sdf/b2note.git
#yum -y install django mongodb
yum -y install python-pip
pip install --upgrade pip
cd /home/vagrant

#alternative Python 3 env
#sudo yum -y install python36
#cd /home/vagrant
#python3 -m venv py3
#source /home/vagrant/py3/bin/activate
cat <<EOT >> /home/vagrant/py3/bin/activate
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
#pip install --upgrade pip
#pip install django mongoengine pymongo pysolr requests django-countries eve-swagger django-simple-captcha beautifulsoup4 rdflib rdflib-jsonld

# Python 2
pip install virtualenv
virtualenv py2 
# put settings into activate script
cat <<EOT >> /home/vagrant/py2/bin/activate
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
cd /home/vagrant/b2note
source /home/vagrant/py2/bin/activate
pip install django-simple-captcha
pip install -r requirements.txt
pip uninstall -y django
pip install git+https://github.com/django-nonrel/django@nonrel-1.5
pip install git+https://github.com/django-nonrel/djangotoolbox
pip install git+https://github.com/django-nonrel/mongodb-engine
pip install mongoengine django-countries oic
# fix issue https://stackoverflow.com/questions/35254975/import-error-no-module-named-bson
# fix issue import error decimal128
# pip uninstall -y bson
pip uninstall -y pymongo
pip install pymongo

./manage.py syncdb --noinput
# sqlite3 users.sqlite3

yum -y install sqlite

./manage.py syncdb --database=users --noinput
# create run script
cat <<EOT > /home/vagrant/b2note/runui.sh
#!/usr/bin/env bash
source /home/vagrant/py2/bin/activate
cd /home/vagrant/b2note/
./manage.py runserver
EOT
cat <<EOT > /home/vagrant/b2note/runapi.sh
#!/usr/bin/env bash
source /home/vagrant/py2/bin/activate
cd /home/vagrant/b2note/
python b2note_api/b2note_api.py
EOT
chmod +x /home/vagrant/b2note/runui.sh
chmod +x /home/vagrant/b2note/runapi.sh
chown -R vagrant:vagrant /home/vagrant/b2note

# start django after boot

cat <<EOT > /etc/systemd/system/b2noteapi.service
[Unit]
Description=B2NOTE Service
After=autofs.service

[Service]
Type=simple
PIDFile=/var/run/b2noteapi.pid
User=vagrant
ExecStart=/home/vagrant/b2note/runapi.sh
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=b2noteapi
WorkingDirectory=/home/vagrant/b2note/

[Install]
WantedBy=multi-user.target
EOT
cat <<EOT > /etc/systemd/system/b2noteui.service
[Unit]
Description=B2NOTE Service
After=autofs.service

[Service]
Type=simple
PIDFile=/var/run/b2noteui.pid
User=vagrant
ExecStart=/home/vagrant/b2note/runui.sh
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=b2noteui
WorkingDirectory=/home/vagrant/b2note/

[Install]
WantedBy=multi-user.target
EOT
chown vagrant:vagrant /tmp/b2note.log
# set debug
sed -i -e "s/^DEBUG =.*$/DEBUG = True/g" /home/vagrant/b2note/b2note_devel/settings.py
# start django now
systemctl start b2noteui
systemctl enable b2noteui
# start eve api now
systemctl start b2noteapi
systemctl enable b2noteapi

# datasetview
cd /home/vagrant
git clone https://github.com/e-sdf/B2NOTE-DatasetView
chown -R vagrant:vagrant /home/vagrant/B2NOTE-DatasetView
# apache proxy to django
cat <<EOT >> /etc/httpd/conf.d/b2note.conf
Alias "/datasetview" "/home/vagrant/B2NOTE-DatasetView/dist"
<Directory "/home/vagrant/B2NOTE-DatasetView/dist">
  Require all granted
  Options FollowSymLinks IncludesNOEXEC
  AllowOverride All
</Directory>
  ProxyPass /api http://127.0.0.1:5000
  ProxyPassReverse /api http://127.0.0.1:5000
  ProxyPass /ui http://127.0.0.1:8000
  ProxyPassReverse /ui http://127.0.0.1:8000

  SSLProxyEngine On
  SSLProxyVerify none
  SSLProxyCheckPeerCN off
  SSLProxyCheckPeerName off
  SSLProxyCheckPeerExpire off
# proxy to pcloud WEBDAV  
<Location "/pcloud">
  ProxyPass "https://webdav.pcloud.com"
  Header add "Access-Control-Allow-Origin" "*"
</Location>

# proxy to b2drop WEBDAV  
<Location "/b2drop">
  ProxyPass "https://b2drop.eudat.eu/remote.php/webdav"
  Header add "Access-Control-Allow-Origin" "*"
</Location>  
EOT

service httpd restart

# install nodejs v >8.x required by aurelia
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
# remove previous nodejs installation
yum -y remove nodejs
yum -y install nodejs
npm install aurelia-cli -g --quiet


