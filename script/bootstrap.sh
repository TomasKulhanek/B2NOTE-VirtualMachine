#!/usr/bin/env bash

# Prepares VM with web server, opens ports on firewall
# B2NOTE_REPO = https://github.com/EUDAT-B2NOTE/b2note.git
# B2NOTE_BRANCH = master # which branch to checkout
# B2NOTE_PY3 = 1 # configure python 3 env
# B2NOTE_PY2 = 1 # configure python 2 env
# B2NOTE_V2=1 # will set b2note v2 specifics
# B2NOTE_DATASETVIEW = 1 # configure b2note datasetview poc 

# define following variables in order to configure b2note with b2access/google oauth
# GAUTH_CLIENT_ID=''
# GAUTH_CLIENT_SECRET=''
# GAUTH_B2NOTE_SECRET_KEY=''
# B2ACCESS_CLIENT_ID=''
# B2ACCESS_CLIENT_SECRET=''
# B2ACCESS_REDIRECT_URI=''
yum -y install dos2unix
dos2unix /vagrant/script/*.sh
. /vagrant/script/bootstrap-1server.sh
. /vagrant/script/bootstrap-2python2.sh
. /vagrant/script/bootstrap-3python3.sh
. /vagrant/script/bootstrap-4daemon.sh
. /vagrant/script/bootstrap-5js.sh
