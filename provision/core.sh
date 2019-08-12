#!/bin/bash
set -e

echo
sudo apt-get update

sudo apt-get install -y maven build-essential libssl-dev libltdl7 jq

echo
echo "Installing Docker..."
DOCKER_DIST="https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64"
DOCKER_CONTAINER="containerd.io_1.2.2-3_amd64.deb"
DOCKER_CLI="docker-ce-cli_18.09.2~3-0~ubuntu-xenial_amd64.deb"
DOCKER_CE="docker-ce_18.09.2~3-0~ubuntu-xenial_amd64.deb"

if [ ! -f $WORKSPACE/$DOCKER_CONTAINER ]; then
	wget -P $WORKSPACE "$DOCKER_DIST/$DOCKER_CONTAINER"
fi

if [ ! -f $WORKSPACE/$DOCKER_CLI ]; then
	wget -P $WORKSPACE "$DOCKER_DIST/$DOCKER_CLI"
fi

if [ ! -f $WORKSPACE/$DOCKER_CE ]; then
	wget -P $WORKSPACE "$DOCKER_DIST/$DOCKER_CE"
fi

sudo dpkg -i $WORKSPACE/$DOCKER_CONTAINER
sudo dpkg -i $WORKSPACE/$DOCKER_CLI
sudo dpkg -i $WORKSPACE/$DOCKER_CE

echo
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
source $HOME/.nvm/nvm.sh
nvm --version

echo
echo "Installing NPM..."
nvm install 11.6.0

echo
echo "Installing swagger-combine..."
npm install -g swagger-combine

echo

cat <<EOF >> $HOME/.profile
export PATH=$PATH:/vagrant/scripts:
EOF

