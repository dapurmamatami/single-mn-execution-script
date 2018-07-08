cd
wget https://github.com/zealiumcoin/Zealium/releases/download/v1.0.0.0/Zealium-v1.0.0.0-linux64.tar.gz
tar xvf Zealium-v1.0.0.0-linux64.tar.gz

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
echo -e "masternode=1\masternodeprivkey=$masternodekey" >> /root/.zealium/zealium.conf
