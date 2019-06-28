# install nodejs v >8.x required by aurelia
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
# remove previous nodejs installation
yum -y remove nodejs
yum -y install nodejs
npm install aurelia-cli -g --quiet

echo Testing B2Note. If all tests PASS, then B2NOTE is installed correctly
cd /home/vagrant/b2note/b2note_api
python -m unittest
echo Frontend APP UI unit tests
cd ..
cd b2note_app
npm install -s
au test
#echo Frontend APP UI e2e tests
#au run & sleep 10; au teste2e
#killall au

