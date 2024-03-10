#!/bin/bash

set -e

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
    echo -e "${color}$*${none}"
}

_red() { _print_color "${red}" "$*"; }
_green() { _print_color "${green}" "$*"; }
_yellow() { _print_color "${yellow}" "$*"; }
_blue() { _print_color "${blue}" "$*"; }
_purple() { _print_color "${purple}" "$*"; }
_cyan() { _print_color "${cyan}" "$*"; }

# Logo
curl -s https://raw.githubusercontent.com/skyMetaverse/nodeHelper/master/logo/logo.sh | bash

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    _red "This script requires root privileges, please run as root."
    exit 1
fi

# User interaction for selecting installation
_read_input() {
    _red "Select the installation option:"
    _purple "0. Install Go"
    _purple "1. Install Rust"
    _purple "2. Uninstall Go"
    _purple "3. Uninstall Rust"
    read -p "Enter your choice: " choice
}

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

# Install Rust
_install_rust() {
    # Install Rust
    if ! command -v cargo &>/dev/null; then
        _green "Rust is not installed, beginning installation..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
        _green "Rust installation complete."
        _yellow "Current Rust version: $(rustc --version)"
    else
        _red "Rust is already installed."
        _yellow "Current Rust version: $(rustc --version)"
    fi
}

_uninstall_go() {
    # Uninstall Go
    if [ -x "$(command -v go)" ]; then
        _yellow "Uninstalling Go..."
        sudo rm -rf /usr/local/go
        sed -i '/\/usr\/local\/go\/bin/d' ~/.bashrc
        _green "Go has been uninstalled."
    else
        _red "Go is not installed."
    fi
}
_uninstall_rust() {
    # Uninstall Rust
    if [ -x "$(command -v rustup)" ]; then
        _yellow "Uninstalling Rust..."
        echo "y" | rustup self uninstall
        _green "Rust has been uninstalled."
    else
        _red "Rust is not installed."
    fi
}
# Main script
while true; do
    _read_input
    case $choice in
    0)
        _install_go
        break
        ;;
    1)
        _install_rust
        break
        ;;
    2)
        _uninstall_go
        break
        ;;
    3)
        _uninstall_rust
        break
        ;;
    *)
        _red "Invalid choice. Please select 0 ~ 3."
        ;;
    esac
done
