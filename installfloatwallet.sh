#!/bin/bash

# This code is licensed under the MIT software license
# This header information may not be removed
# This source code is provided as is; with no warranty implied or otherwise
# copyright IceBurst 2017 member of the Burst Development Team
# Copyright 2017 Float Coin Developers
#   v.1b - Initial release, Ubuntu tool

GIT=`which git`
JAVA=`which javac`
OS=`uname -a`
CWD=`pwd`

# Check for all dependancies and get as required

if [[ $UID != 0 ]]; then
  echo "please rerun the command with sudo ex: sudo ${0}"
exit 1
fi

# remove any old version
rm -rf ${CWD}/floatwallet

if [[ "$OS" == *"Ubuntu"* ]]
then
echo "Determined this is Ubuntu, proceeding"

USER=`logname`

if [[ -z ${GIT} ]]
then
  echo "Installing Git"
  apt-get install -yqq git
fi

if [[ -z ${JAVA} ]]
then
  echo "Installing JAVA Components"
  apt-get install -yqq default-jre default-jdk
fi

# Get and Build the Float Wallet
git clone https://github.com/floatbeta/FLOAT floatwallet
cd ${CWD}/floatwallet
./compile.sh
# modify some constants
sed -i 's@rebroadcastAfter=4@rebroadcastAfter=12@' ${CWD}/floatwallet/conf/nxt-default.properties
sed -i 's@rebroadcastEvery=2@rebroadcastEvery=6@' ${CWD}/floatwallet/conf/nxt-default.properties

cd ${CWD}
chown -R ${USER}:${USER} ${CWD}/floatwallet
#Setup all the services
JAVA=`which java`
rm -f /etc/systemd/system/floatwallet.service
cat >> /etc/systemd/system/floatwallet.service << WALLET

Description=Floatwallet
After=network-online.target
Requires=network-online.target

[Service]
User=${USER}
WorkingDirectory=${CWD}/floatwallet
ExecStart=${JAVA} -cp float.jar:lib/*:conf nxt.Nxt
Restart=always
WALLET

systemctl daemon-reload
systemctl enable floatwallet.service
systemctl start floatwallet.service
systemctl status floatwallet.service
fi
