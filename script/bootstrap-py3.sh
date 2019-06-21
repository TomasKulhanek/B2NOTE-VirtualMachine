#!/usr/bin/env bash

B2NOTE_REPO=https://github.com/EUDAT-B2NOTE/b2note.git
B2NOTE_BRANCH=development-py3 # which branch to checkout
B2NOTE_V2=0 # will set b2note v2 specifics
B2NOTE_PY3=1 # configure python 3 env
B2NOTE_PY2=0 # configure python 2 env
B2NOTE_DATASETVIEW=0 # configure b2note datasetview poc 
B2NOTE_SECRET_KEY="some-secret"
. /vagrant/script/bootstrap-1server.sh
#. /vagrant/script/bootstrap-2python2.sh
. /vagrant/script/bootstrap-3python3.sh
. /vagrant/script/bootstrap-4daemon.sh
. /vagrant/script/bootstrap-5js.sh