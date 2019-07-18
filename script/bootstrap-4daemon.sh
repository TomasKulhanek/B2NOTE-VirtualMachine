#############################################################################################################
#################################### daemon scripts #########################################################
#############################################################################################################

chown -R vagrant:vagrant /home/vagrant/b2note

# apache wsgi to b2note_api and alias to b2note_app, redirect interface_main to /api/interface_main for compatibility
cat <<EOT >> /etc/httpd/conf.d/b2note.conf
LoadModule wsgi_module "/home/vagrant/py3/lib64/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so"
WSGIPythonHome "/home/vagrant/py3"
WSGIDaemonProcess b2note_api user=vagrant group=vagrant processes=1 threads=5 python-home=/home/vagrant/py3 python-path=/home/vagrant/b2note/b2note_api
WSGIPassAuthorization On
WSGIScriptAlias /api /home/vagrant/b2note/b2note_api/api.wsgi

    <Directory /home/vagrant/b2note/b2note_api>
        Require all granted
        WSGIProcessGroup b2note_api
        WSGIApplicationGroup %{GLOBAL}
        Order allow,deny
	Allow from all
    </Directory>

Alias "/b2note" "/home/vagrant/b2note/b2note_app/dist"
<Directory "/home/vagrant/b2note/b2note_app/dist">
  Header set Access-Control-Allow-Origin "*"
  Require all granted
  Options FollowSymLinks IncludesNOEXEC
  AllowOverride All
</Directory>

RewriteEngine On
RewriteRule    ^/interface_main$   /api/interface_main    [PT]

EOT
#yum -y install mod_ssl
service httpd restart

