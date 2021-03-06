#############################################################################################################
#################################### PYTHON 3 environment ###################################################
#############################################################################################################
if [[ ${B2NOTE_PY3} && ${B2NOTE_PY3} -eq "1" ]] 
then 
#alternative Python 3 env
sudo yum -y install python36 python36-devel httpd-devel gcc
#python36-devel httpd-devel and gcc required by pip mod_wsgi
cd /home/vagrant
python3 -m venv py3
cat <<EOT >> /home/vagrant/py3/bin/activate
# DJANGO B2NOTE variables:
export MONGODB_NAME='${MONGODB_NAME}'
export MONGODB_USR='${MONGODB_USR}'
export MONGODB_PWD='${MONGODB_PWD}'
export SQLDB_NAME='/home/vagrant/b2note/users.sqlite3'
export SQLDB_USR='b2note'
export SQLDB_PWD='b2note'
export VIRTUOSO_B2NOTE_USR='b2note'
export VIRTUOSO_B2NOTE_PWD='b2note'
export B2NOTE_PREFIX_SW_PATH='/home/vagrant/b2note'
#export EMAIL_SUPPORT_ADDR='b2note.temp@gmail.com'
export EMAIL_SUPPORT_ADDR='b2note-support'
export EMAIL_SUPPORT_PWD='some-password'
export SUPPORT_EMAIL_ADDR='b2note@bsc.es'
export SUPPORT_EMAIL_PWD='some-password'
export SUPPORT_DEST_EMAIL='eudat-b2note-support@postit.csc.fi'

export GAUTH_CLIENT_ID='${GAUTH_CLIENT_ID}'
export GAUTH_CLIENT_SECRET='${GAUTH_CLIENT_SECRET}'
export GAUTH_BASE_URI='${GAUTH_BASE_URI}'
export GAUTH_AUTH_REDIRECT_URI='${GAUTH_AUTH_REDIRECT_URI}'
export B2NOTE_SECRET_KEY='${B2NOTE_SECRET_KEY}'
export B2ACCESS_CLIENT_ID='${B2ACCESS_CLIENT_ID}'
export B2ACCESS_CLIENT_SECRET='${B2ACCESS_CLIENT_SECRET}'
export B2ACCESS_REDIRECT_URI='${B2ACCESS_REDIRECT_URI}'

EOT
source /home/vagrant/py3/bin/activate
pip install --upgrade pip
cd /home/vagrant/b2note/b2note_api
pip install -r requirements.txt
PY_ENV=py3
#install sqlite
yum -y install sqlite
#replace sqlite 3.7 to newer sqlite 3.11
cp /vagrant/lib/sqlite-3.11/sqlite3 /usr/bin
cp /vagrant/lib/sqlite-3.11/libsqlite3.so.0.8.6 /usr/lib64
#check sqlite version
python -c "import sqlite3; print(sqlite3.sqlite_version)"

#./manage.py syncdb --noinput
cd /home/vagrant/b2note
if [[ -f "/home/vagrant/b2note/manage.py" ]]
then
./manage.py migrate --noinput
# sqlite3 users.sqlite3
./manage.py migrate --database=users --noinput
fi

# configure httpd environment variables
if [[ ${B2NOTE_V2} && ${B2NOTE_V2} -eq "1" ]]
then 
  echo configuring httpd env variables
cat <<EOT >> /etc/sysconfig/httpd
# B2NOTE variables:
MONGODB_NAME='${MONGODB_NAME}'
MONGODB_USR='${MONGODB_USR}'
MONGODB_PWD='${MONGODB_PWD}'
GAUTH_CLIENT_ID='${GAUTH_CLIENT_ID}'
GAUTH_CLIENT_SECRET='${GAUTH_CLIENT_SECRET}'
GAUTH_BASE_URI='${GAUTH_BASE_URI}'
GAUTH_AUTH_REDIRECT_URI='${GAUTH_AUTH_REDIRECT_URI}'
B2NOTE_SECRET_KEY='${B2NOTE_SECRET_KEY}'
B2ACCESS_CLIENT_ID='${B2ACCESS_CLIENT_ID}'
B2ACCESS_CLIENT_SECRET='${B2ACCESS_CLIENT_SECRET}'
B2ACCESS_REDIRECT_URI='${B2ACCESS_REDIRECT_URI}'
# for development uncomment following lines (b2access devel ssl cert may expire), for production comment following lines
# AUTHLIB_INSECURE_TRANSPORT=true
# CURL_CA_BUNDLE=""
EOT

# disable security check for development server
if [[ ${B2NOTE_DEVEL} && ${B2NOTE_DEVEL} -eq "1" ]]
then
cat <<EOT >> /etc/sysconfig/httpd
AUTHLIB_INSECURE_TRANSPORT=true
CURL_CA_BUNDLE=""
EOT
fi

fi

fi