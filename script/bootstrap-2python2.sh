#############################################################################################################
#################################### PYTHON 2 environment ###################################################
#############################################################################################################
if [[ ${B2NOTE_PY2} && ${B2NOTE_PY2} -eq "1" ]] 
then 
# Python 2
pip install virtualenv
virtualenv py2 
source /home/vagrant/py2/bin/activate
pip install django mongoengine pymongo pysolr requests django-countries eve-swagger django-simple-captcha beautifulsoup4 rdflib rdflib-jsonld django_mongodb_engine
pip install git+https://github.com/django-nonrel/django@nonrel-1.5
pip install git+https://github.com/django-nonrel/djangotoolbox

put settings into activate script
cat <<EOT >> /home/vagrant/py2/bin/activate
# DJANGO B2NOTE variables:
export MONGODB_NAME='b2notedb'
export MONGODB_USR='b2note'
export MONGODB_PWD='b2note'
export SQLDB_NAME='/home/vagrant/b2note/users.sqlite3'
export SQLDB_USR='b2note'
export SQLDB_PWD='b2note'
export VIRTUOSO_B2NOTE_USR='b2note'
export VIRTUOSO_B2NOTE_PWD='b2note'
export B2NOTE_SECRET_KEY='${B2NOTE_SECRET_KEY}'
export B2NOTE_PREFIX_SW_PATH='/home/vagrant/b2note'
#export EMAIL_SUPPORT_ADDR='b2note.temp@gmail.com'
export EMAIL_SUPPORT_ADDR='b2note-support'
export EMAIL_SUPPORT_PWD='some-password'
export SUPPORT_EMAIL_ADDR='b2note@bsc.es'
export SUPPORT_EMAIL_PWD='some-password'
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
pip uninstall -y bson
pip uninstall -y pymongo
pip install pymongo
PY_ENV=py2
#install sqlite
yum -y install sqlite
#replace sqlite 3.7 to newer sqlite 3.11
cp /vagrant/lib/sqlite-3.11/sqlite3 /usr/bin
cp /vagrant/lib/sqlite-3.11/libsqlite3.so.0.8.6 /usr/lib64
#check sqlite version
python -c "import sqlite3; print(sqlite3.sqlite_version)"

#./manage.py syncdb --noinput
cd /home/vagrant/b2note

./manage.py syncdb --noinput
# sqlite3 users.sqlite3

./manage.py syncdb --database=users --noinput
fi

