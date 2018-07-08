# Get a new privatekey by going to console >> debug and typing smartnode genkey
#printf "Masternode GenKey: "
#read _nodePrivateKey

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
sudo apt-get install unzip

wget https://github.com/zealiumcoin/Zealium/releases/download/v1.0.0.0/Zealium-v1.0.0.0-linux64.tar.gz
tar xvf Zealium-v1.0.0.0-linux64.tar.gz
chmod -R 777 Zealium-v1.0.0.0-linux64/

# Make a new directory for zealium daemon
mkdir ~/.zealium/
touch ~/.zealium/zealium.conf

# Change the directory to ~/.zealium
cd ~/.zealium/

# Create the initial zealium.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
listen=0
server=1
daemon=1
masternode=1
masternodeprivkey=88T2Tz6Twh6WifN9FaCNaK2gBXZcKRheWgvH16L9CrzRLapy864
" > zealium.conf



cd Zealium-v1.0.0.0-linux64
./zealiumd
sleep 20s
#Generate New Masternode Privkey and reconfigure zealium.conf
_MNPRIVKEY=$(zealium-cli masternode genkey)
read _MNPRIVKEY
zealium-cli stop
sleep 10s
sed -i '8d' ~/.zealium/zealium.conf

# Change the directory to ~/.zealium
cd ~/.zealium/

echo "masternodeprivkey=${_MNPRIVKEY}" >> /root/.zealium/zealium.conf

# Create the FINAL zealium.conf file
#echo "rpcuser=${_rpcUserName}
#rpcpassword=${_rpcPassword}
#rpcallowip=127.0.0.1
#rpcport=31090
#listen=1
#server=1
#daemon=1
#masternode=1
#masternodeprivkey=${_MNPRIVKEY}
#" > zealium.conf
