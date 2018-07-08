# Get a new privatekey by going to console >> debug and typing smartnode genkey
#printf "Masternode GenKey: "
#read _nodePrivateKey

#Generate New Masternode Privkey and reconfigure zealium.conf
_MNPRIVKEY=$(zealium-cli masternode genkey)
read _MNPRIVKEY
zealium-cli stop
sleep 10s
sed -i '5d' ~/.zealium/zealium.conf

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
