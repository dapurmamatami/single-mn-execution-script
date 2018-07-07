#!/bin/bash
# install.sh
# Installs smartnode on Ubuntu 16.04 LTS x64
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

while true; do
 if [ -d ~/.zealium ]; then
   printf "~/.zealium/ already exists! The installer will delete this folder. Continue anyway?(Y/n)"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      pID=$(ps -ef | grep zealiumd | awk '{print $2}')
      kill ${pID}
      rm -rf ~/.zealium/
      break
   else
      if [ ${REPLY} == "n" ]; then
        exit
      fi
   fi
 else
   break
 fi
done

# Warning that the script will reboot the server
#echo "WARNING: This script will reboot the server when it's finished."
#printf "Press Ctrl+C to cancel or Enter to continue: "
#read IGNORE

cd
# Changing the SSH Port to a custom number is a good security measure against DDOS attacks
#printf "Custom SSH Port(Enter to ignore): "
#read VARIABLE
#_sshPortNumber=${VARIABLE:-22}

# Get a new privatekey by going to console >> debug and typing smartnode genkey
printf "Masternode GenKey: "
read _nodePrivateKey

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get the IP address of your vps which will be hosting the smartnode
_nodeIpAddress=$(ip route get 1 | awk '{print $NF;exit}')

echo "Creating 2GB temporary swap file...this may take a few minutes..."
sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
sudo mkswap /swapfile
sudo chown root:root /swapfile
sudo chmod 0600 /swapfile
sudo swapon /swapfile

#make swap permanent
sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab

# Install pre-reqs using apt-get
sudo apt update -y
sudo apt upgrade -y
sudo apt-get install git -y
sudo apt-get install build-essential -y
sudo apt-get install libtool -y
sudo apt-get install autotools-dev -y
sudo apt-get install automake -y
sudo apt-get install autoconf -y
sudo apt-get install pkg-config -y
sudo apt-get install libssl-dev -y
sudo apt-get install libevent-dev -y
sudo apt-get install bsdmainutils -y
sudo apt-get install libboost-system-dev -y
sudo apt-get install libboost-filesystem-dev -y
sudo apt-get install libboost-chrono-dev -y
sudo apt-get install libboost-program-options-dev -y
sudo apt-get install libboost-test-dev -y
sudo apt-get install libboost-thread-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

# Install zealiumd 
git clone https://github.com/zealiumcoin/Zealium.git
chmod -R 777 Zealium/
cd Zealium #TODO: squash relative path
echo "Preparing to build..."
./autogen.sh
if [ $? -ne 0 ]; then error; fi
echo "Configuring build options..."
./configure 
if [ $? -ne 0 ]; then error; fi
echo "Building ZealiumCoin...this may take a few minutes..."
make
if [ $? -ne 0 ]; then error; fi
echo "Installing ZealiumCoin..."
sudo make install
if [ $? -ne 0 ]; then error; fi

# Make a new directory for zealium daemon
mkdir ~/.zealium/
touch ~/.zealium/zealium.conf

# Change the directory to ~/.zealium
cd ~/.zealium/

# Create the initial chaincoin.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
masternode=1
masternodeprivkey=${_nodePrivateKey}
" > zealium.conf

# Change the SSH port
#sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

# Firewall security measures

#apt install ufw -y
#ufw disable
#ufw allow 9678
#ufw allow "$_sshPortNumber"/tcp
#ufw limit "$_sshPortNumber"/tcp
#ufw logging on
#ufw default deny incoming
#ufw default allow outgoing
#ufw --force enable

cd Zealium/src
zealiumd
echo "SUCCESS! Your zealiumd has started. Your local masternode.conf entry is below..."
echo "MN ${_nodeIpAddress}:11994 ${_nodePrivateKey} TXHASH INDEX"
