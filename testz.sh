cd
wget https://github.com/zealiumcoin/Zealium/releases/download/v1.0.0.0/Zealium-v1.0.0.0-linux64.tar.gz
tar xvf Zealium-v1.0.0.0-linux64.tar.gz

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get the IP address of your vps which will be hosting the smartnode
_nodeIpAddress=$(ip route get 1 | awk '{print $NF;exit}')

# Make a new directory for zealium daemon
mkdir ~/.zealium/
touch ~/.zealium/zealium.conf
cd ~/.zealium/

echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
listen=0
server=1
daemon=1
" > zealium.conf
cd

cd bin/
./zealiumd
sleep 10s
masternodekey=$(./zealium-cli masternode genkey)
./zealium-cli stop
sleep 10s
echo -e "masternode=1" >> /root/.zealium/zealium.conf
echo -e "masternodeprivkey=$masternodekey" >> /root/.zealium/zealium.conf

cd
cd bin/
./zealiumd
echo "VPS setup is completed"
sleep 10s
./zealium-cli getinfo
