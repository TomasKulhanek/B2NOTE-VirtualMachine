# This shell script
# - tries to detect and activate virtualenv in default location
# - and starts unit tests of b2note api service

PIPFROM=`pip -V | cut -d' ' -f4`
if [[ $PIPFROM != /home/vagrant* ]]
then
  if [[ -f /home/vagrant/py3-dev/bin/activate ]]; then
    echo activate py3-dev
    source /home/vagrant/py3-dev/bin/activate
  elif [[ -f /home/vagrant/py3/bin/activate ]]; then
    echo activate py3
    source /home/vagrant/py3/bin/activate
  else
    echo WARNING - default virtualenv for python 3 not detected or found at /home/vagrant/py3-* using python from path
  fi
fi
cd /home/vagrant/b2note/b2note_api
python -m unittest
