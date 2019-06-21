#!/usr/bin/env bash

# Prepares VM with web server, opens ports on firewall
# B2NOTE_REPO = https://github.com/EUDAT-B2NOTE/b2note.git
# B2NOTE_BRANCH = master # which branch to checkout
# B2NOTE_PY3 = 1 # configure python 3 env
# B2NOTE_PY2 = 1 # configure python 2 env
# B2NOTE_V2=1 # will set b2note v2 specifics
# B2NOTE_DATASETVIEW = 1 # configure b2note datasetview poc 

. ./bootstrap-1server.sh
. ./bootstrap-2python2.sh
. ./bootstrap-3python3.sh
. ./bootstrap-4daemon.sh
. ./bootstrap-5js.sh
