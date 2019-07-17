# This shell script
# - tries to detect and activate virtualenv in default location
# - and starts b2note api service in development mode

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
cd /home/vagrant/b2note
python b2note_api.py
