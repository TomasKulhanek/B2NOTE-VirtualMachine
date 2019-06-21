#############################################################################################################
#################################### daemon scripts #########################################################
#############################################################################################################

# create run script
if [[ -f "/home/vagrant/b2note/manage.py" ]]
then
cat <<EOT > /home/vagrant/b2note/runui.sh
#!/usr/bin/env bash
source /home/vagrant/${PY_ENV}/bin/activate
cd /home/vagrant/b2note/
./manage.py runserver
EOT
fi

if [[ ${B2NOTE_V2} && ${B2NOTE_V2} -eq "1" ]]
then 
  echo skipping runapi.sh conf
else 
cat <<EOT > /home/vagrant/b2note/runapi.sh
#!/usr/bin/env bash
source /home/vagrant/${PY_ENV}/bin/activate
cd /home/vagrant/b2note/
python b2note_api/b2note_api.py
EOT
chmod +x /home/vagrant/b2note/runui.sh
chmod +x /home/vagrant/b2note/runapi.sh
fi

chown -R vagrant:vagrant /home/vagrant/b2note

# start django after boot
if [[ ${B2NOTE_V2} && ${B2NOTE_V2} -eq "1" ]]
then 
  echo skipping django deamon conf
else 

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

if [[ -f "/home/vagrant/b2note/runui.sh" ]]
then
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
fi

chown vagrant:vagrant /tmp/b2note.log
# set debug
sed -i -e "s/^DEBUG =.*$/DEBUG = True/g" /home/vagrant/b2note/b2note_devel/settings.py
# start django now
systemctl start b2noteui
systemctl enable b2noteui
# start eve api now
systemctl start b2noteapi
systemctl enable b2noteapi
fi

# datasetview
if [[ ${B2NOTE_DATASETVIEW} && ${B2NOTE_DATASETVIEW} -eq "1" ]] 
then 
cd /home/vagrant
git clone https://github.com/e-sdf/B2NOTE-DatasetView
chown -R vagrant:vagrant /home/vagrant/B2NOTE-DatasetView
fi
# apache proxy to django and eve, directory to datasetview
cat <<EOT >> /etc/httpd/conf.d/b2note.conf
Alias "/b2note" "/home/vagrant/b2note/b2note_app/dist"
<Directory "/home/vagrant/b2note/b2note_app/dist">
  Header set Access-Control-Allow-Origin "*"
  Require all granted
  Options FollowSymLinks IncludesNOEXEC
  AllowOverride All
</Directory>

Alias "/datasetview" "/home/vagrant/B2NOTE-DatasetView/dist"
<Directory "/home/vagrant/B2NOTE-DatasetView/dist">
  Require all granted
  Options FollowSymLinks IncludesNOEXEC
  AllowOverride All
</Directory>

WSGIDaemonProcess b2note_api user=vagrant group=vagrant processes=1 threads=5 python-home=/home/vagrant/py3-dev python-path=/home/vagrant/b2note/b2note_api
WSGIPassAuthorization On
WSGIScriptAlias /api /home/vagrant/b2note/b2note_api/api.wsgi

    <Directory /home/vagrant/b2note/b2note_api>
        Require all granted
        WSGIProcessGroup b2note_api
        WSGIApplicationGroup %{GLOBAL}
        Order allow,deny
	Allow from all
    </Directory>

  # ProxyPass /api http://127.0.0.1:5000
  # ProxyPassReverse /api http://127.0.0.1:5000
  # ProxyPass / http://127.0.0.1:8000
  # ProxyPassReverse / http://127.0.0.1:8000

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
yum -y install mod_ssl
service httpd restart

