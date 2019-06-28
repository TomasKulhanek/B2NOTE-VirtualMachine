# installs httpd, mongodb, git, clones b2note, install pip

# one of the configuration is syslog - need to restart
service rsyslog restart

# install apache

#chown -R apache:apache /var/www/html
#chmod -R 644 /var/www/html
#find /var/www/html -type d -exec chmod ugo+rx {} \;

yum -y install epel-release
yum-config-manager --save --setopt=epel/x86_64/metalink.skip_if_unavailable=true
yum repolist

yum -y install httpd
#mod_wsgi required by b2note_api
#httpd-devel required by pip mod_wsgi 

systemctl start httpd
systemctl enable httpd

# allow 80 port in firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# disable selinux, by default enabled, httpd cannot initiate connection otherwise etc.
setenforce 0
sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

## install mongodb 4.0
yum -y install https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-shell-4.0.9-1.el7.x86_64.rpm
yum -y install https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-server-4.0.9-1.el7.x86_64.rpm
yum -y install https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/RPMS/mongodb-org-tools-4.0.9-1.el7.x86_64.rpm

#mongodb mongodb-server
systemctl start mongod
systemctl enable mongod

# put initial db into mongodb
mongo admin /vagrant/script/bootstrapmongo.js

# create b2note app dir
mkdir /srv/b2note
mkdir /etc/b2note
mkdir -p /opt/b2note
chmod ugo+rwx /srv/b2note
#add permission to allow browse webdav content
chmod go+rx /home/vagrant
chown apache:apache /srv/b2note

# build b2note from source code
yum -y install git
cd /home/vagrant

# clone from repository, default from github
if [[ -z "${B2NOTE_REPO}" ]]
then
git clone https://github.com/EUDAT-B2NOTE/b2note.git
else
git clone ${B2NOTE_REPO}
fi

cd b2note
if [[ ${B2NOTE_BRANCH} ]]; then git checkout ${B2NOTE_BRANCH}; fi;
yum -y install python-pip
pip install --upgrade pip
cd /home/vagrant
