#!/bin/bash

none='\033[0m'      # Reset to default color
red='\033[1;31m'    # Red
green='\033[1;32m'  # Green
yellow='\033[1;33m' # Yellow
blue='\033[1;34m'   # Blue
purple='\033[1;35m' # Purple
cyan='\033[1;36m'   # Cyan

_print_color() {
	color=$1
	shift
	echo -e "$color$*$none"
}

_red() { _print_color "$red" "$*"; }
_green() { _print_color "$green" "$*"; }
_yellow() { _print_color "$yellow" "$*"; }
_blue() { _print_color "$blue" "$*"; }
_purple() { _print_color "$purple" "$*"; }
_cyan() { _print_color "$cyan" "$*"; }

# Install Go
_install_go() {
	# Install Go
	if ! command -v go &>/dev/null; then
		_green "Go is not installed, beginning installation..."
		VER="1.22.0"
		# wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
		wget "https://dl.google.com/go/go$VER.linux-amd64.tar.gz"
		sudo rm -rf /usr/local/go
		sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
		rm -rf "go$VER.linux-amd64.tar.gz"
		echo "export PATH=$PATH:/usr/local/go/bin" >>~/.profile
		echo "export GOPATH=/root/goApps" >>~/.profile
		echo "export PATH=$PATH:$GOPATH/bin" >>~/.profile
		source ~/.profile
		export PATH=$PATH:/usr/local/go/bin:~/go/bin
		_green "Go installation complete."
		_yellow "Current Go version: $(go version)"
	else
		_red "Go is already installed."
		_yellow "Current Go version: $(go version)"
	fi
}

# install aut
_install_aut() {
	if ! command -v /root/.local/bin/aut &>/dev/null; then
		apt install pipx -y
		_green "Start install aut"
		pipx install --force git+https://github.com/autonity/aut
		pipx ensurepath
		export PATH="$PATH:/root/.local/bin"
		_green "aut install success: $(aut --version)"
		cat <<EOF >~/.autrc
[aut]
rpc_endpoint=https://rpc1.piccadilly.autonity.org/
EOF
	else
		_red "Already installed aut!"
	fi
}

# install autonity node
_install_autonity() {

	if ! command -v /usr/local/bin/autonity &>/dev/null; then
		_green "Start install autonity node"
		git clone https://github.com/autonity/autonity.git
		cd autonity
		git checkout tags/v0.13.0 -b v0.13.0
		export CGO_CFLAGS="-O -D__BLST_PORTABLE__"
		export CGO_CFLAGS_ALLOW="-O -D__BLST_PORTABLE__"
		_green "Start Build autonity"
		make all
		sudo cp /root/autonity/build/bin/* /usr/local/bin/
		_green "autonity install success: $(autonity version)"

		sed -i 's#rpc_endpoint=.*#rpc_endpoint=http://127.0.0.1:8545/#' ~/.autrc

		cat <<EOF >>"/etc/systemd/system/autonity.service"
[Unit]
Description=Clearmatics Autonity node Server
After=syslog.target network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/autonity --datadir /data/autonity-chaindata --piccadilly --http --http.addr 0.0.0.0 --http.api aut,eth,net,txpool,web3,admin --http.vhosts "*" --ws --ws.addr 0.0.0.0 --ws.api aut,eth,net,txpool,web3,admin --nat extip:$(curl -s eth0.me)
KillMode=process
KillSignal=SIGINT
TimeoutStopSec=5
Restart=on-failure
RestartSec=5
[Install]
Alias=autonity.service
WantedBy=multi-user.target
EOF

		systemctl start autonity.service
	else
		_red "Already installed autonity node!"
	fi
}

_print_Info() {
	cd $HOME
	_red "Please save the following node information:"
	_red "Enode: $(aut node info) | jq"

	_red "Node key: /data/autonity-chaindata/autonity/autonitykeys"
}

_read_input() {
	_blue "Please select an operation:"
	_purple "1. Install Autonity node"
	_purple "2. Check Autonity node status"
	_purple "3. Start Autonity node"
	_purple "4. Restart Autonity node"
	_purple "5. Stop Autonity node"
	_purple "6. View Autonity node log"
	_purple "7. View Autonity node info"
	_purple "8. Exit"
	read -p "Enter your choice (1-7): " choice
}

# Main script
while true; do
	# Logo
	curl -s https://raw.githubusercontent.com/skyMetaverse/nodeHelper/master/logo/logo.sh | bash

	_blue "=	   Autonity Node Manager Script              ="
	_blue "======================================================"
	_read_input
	case $choice in
	1)
		apt-get update -y && apt upgrade -y && apt-get install make build-essential gcc git jq chrony wget curl expect -y
		_install_go
		_install_aut
		_install_autonity
		;;
	2)
		systemctl status autonity.service
		;;
	3)
		systemctl start autonity.service
		;;
	4)
		systemctl restart autonity.service
		;;
	5)
		systemctl stop autonity.service
		;;
	6)
		journalctl -u autonity.service -f
		;;
	7)
		_print_Info
		;;
	8)
		exit 1
		;;
	*)
		_red "Invalid choice. Please select 0 ~ 8."
		;;
	esac
done
