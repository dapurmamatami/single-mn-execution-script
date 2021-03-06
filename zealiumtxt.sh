#!/bin/sh
#Version 0.1.1.3
#Info: Installs Chaincoind daemon, Masternode based on privkey, and a simple web monitor.
#Chaincoin Version 0.9.3 or above
#Tested OS: Ubuntu 17.04, 16.04, and 14.04
#TODO: make script less "ubuntu" or add other linux flavors
#TODO: remove dependency on sudo user account to run script (i.e. run as root and specifiy chaincoin user so chaincoin user does not require sudo privileges)
#TODO: add specific dependencies depending on build option (i.e. gui requires QT4)

noflags() {
	echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    echo "Usage: install-chc"
    echo "Example: install-chc"
    echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    exit 1
}

message() {
	echo "╒════════════════════════════════════════════════════════════════════════════════>>"
	echo "| $1"
	echo "╘════════════════════════════════════════════<<<"
}

error() {
	message "An error occured, you must fix it to continue!"
	exit 1
}


prepdependencies() { #TODO: add error detection
	message "Installing dependencies..."
	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
	sudo apt-get install automake libdb++-dev build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libminiupnpc-dev git software-properties-common python-software-properties g++ bsdmainutils libevent-dev -y
	sudo add-apt-repository ppa:bitcoin/bitcoin -y
	sudo apt-get update
	sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
}

createswap() { #TODO: add error detection
	message "Creating 2GB temporary swap file...this may take a few minutes..."
	sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
	sudo mkswap /swapfile
	sudo chown root:root /swapfile
	sudo chmod 0600 /swapfile
	sudo swapon /swapfile

	#make swap permanent
	sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab
}

clonerepo() { #TODO: add error detection
	message "Cloning from github repository..."
  	cd ~/
	wget https://github.com/zealiumcoin/Zealium/releases/download/v1.0.0.0/Zealium-v1.0.0.0-linux64.tar.gz
	tar xvf Zealium-v1.0.0.0-linux64.tar.gz
	chmod -R 777 bin/
	cd bin/
	mv zealiumd zealium-cli zealium-qt zealium-tx  /root/
}

#compile() {
#	cd chaincoin #TODO: squash relative path
#	message "Preparing to build..."
#	./autogen.sh
#	if [ $? -ne 0 ]; then error; fi
#	message "Configuring build options..."
#	./configure $1 --disable-tests
#	if [ $? -ne 0 ]; then error; fi
#	message "Building ChainCoin...this may take a few minutes..."
#	make
#	if [ $? -ne 0 ]; then error; fi
#	message "Installing ChainCoin..."
#	sudo make install
#	if [ $? -ne 0 ]; then error; fi
#}

createconf() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password

	message "Creating zealium.conf..."
	MNPRIVKEY="6FBUPijSGWWDrhbVPDBEoRuJ67WjLDpTEiY1h4wAvexVZH3HnV6"
	CONFDIR=~/.zealium
	CONFILE=$CONFDIR/zealium.conf
	if [ ! -d "$CONFDIR" ]; then mkdir $CONFDIR; fi
	if [ $? -ne 0 ]; then error; fi
	
	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 10 ; echo)
	rpcpass=$(openssl rand -base64 32)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=11995" "externalip=$mnip" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:11994" > $CONFILE

        /root/zealiumd
        message "Wait 10 seconds for daemon to load..."
        sleep 20s
        mnpirvate=$(/root/zealium-cli masternode genkey)
	read mnpirvate
	/root/zealium-cli stop
	message "wait 10 seconds for deamon to stop..."
        sleep 10s
	sudo rm $CONFILE
	message "Updating zealium.conf..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=0" "server=1" "daemon=1" "maxconnections=256" "rpcport=11995" "externalip=$mnip" "bind=$mnip" "masternode=1" "masternodeprivkey=$mnpirvate" "masternodeaddr=$mnip:11994" > $CONFILE

}

#createhttp() {
#	cd ~/
#	mkdir web
#	cd web
#	wget https://raw.githubusercontent.com/chaoabunga/chc-scripts/master/index.html
#	wget https://raw.githubusercontent.com/chaoabunga/chc-scripts/master/stats.txt
#	(crontab -l 2>/dev/null; echo "* * * * * echo MN Count:  > ~/web/stats.txt; /usr/local/bin/chaincoind masternode count >> ~/web/stats.txt; /usr/local/bin/chaincoind getinfo >> ~/web/stats.txt") | crontab -
#	mnip=$(curl -s https://api.ipify.org)
#	sudo python3 -m http.server 8000 --bind $mnip 2>/dev/null &
#	echo "Web Server Started!  You can now access your stats page at http://$mnip:8000"
#}

success() {
	/root/zealiumd
	message "SUCCESS! Your zealiumd has started. Masternode.conf setting below..."
	message "MN $mnip:11994 $MNPRIVKEY TXHASH INDEX"
	exit 0
}

install() {
	prepdependencies
	createswap
	clonerepo
	createconf
	success
}

#main
#default to --without-gui
install --without-gui
