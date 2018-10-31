#!/bin/bash
# installing hyperledger-fabric with docker 

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

sudo cp docker /etc/default/
sudo service docker restart
sudo apt-get install -y libsnappy-dev zlib1g-dev libbz2-dev

ARCH=`uname -m`
if [ $ARCH == "aarch64" ]; then
        ARCH="arm64"
elif [ $ARCH == "x86_64" ]; then
        ARCH="amd64"
fi

if ! [ -d "$HL_DATA" ]; then
	mkdir -p $HL_DATA
fi
cd $HL_DATA

GOTAR="go1.10.4.linux-$ARCH.tar.gz"
wget https://storage.googleapis.com/golang/$GOTAR
tar -zxvf $GOTAR
export GOPATH=`pwd`/go
export PATH=$PATH:`pwd`/go/bin

git clone https://github.com/google/leveldb.git
cd leveldb
git checkout v1.20
make
sudo scp out-static/lib* out-shared/lib* /usr/local/lib
sudo scp -r include/leveldb /usr/local/include

cd $HL_DATA/go
mkdir -p src/github.com/hyperledger
cd src/github.com/hyperledger
if [ $ARCH == "arm64" ]; then
    git clone https://github.com/jmj119/fabric.git
	cd fabric
else
    git clone https://github.com/jmj119/fabric.git
	cd fabric
fi
#cp $HL_HOME/hl_core.yaml peer/core.yaml
make native
