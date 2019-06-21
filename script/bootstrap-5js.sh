# install nodejs v >8.x required by aurelia
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
# remove previous nodejs installation
yum -y remove nodejs
yum -y install nodejs
npm install aurelia-cli -g --quiet
