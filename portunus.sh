#!/usr/bin/env bash

# Download and install commonly used and particularly useful applications

create() {
    chmod u+x ./portunus.sh
    mv ./portunus/portunus.sh /usr/bin/portunus
    mkdir /etc/portunus
    mv ./conf.d /etc/portunus/conf.d
}

#########################################
# Update and upgrade apt package manager
# and verify wget is currently installed.
# Arguments:
#   None
# Outputs:
#   Writes status to stdout
#########################################
prep() {
    echo "Setting things up. . ."
    sudo apt update && sudo apt upgrade
    if ! [ -f "/usr/bin/wget" ]; then
        sudo apt install wget -y
    fi
    echo "Prep complete."
}

#########################################
# Installs Github CLI application
# Arguments:
#   None
# Outputs:
#   None
#########################################
gh() {
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
        sudo apt update &&
        sudo apt install gh -y
}

#########################################
# Installs Oh-my-zsh to automatically
# configure zsh
# Arguments:
#   None
# Outputs:
#   None
#########################################
omz() {
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

#########################################
# Installs Microsoft Visual Studio Code
# Arguments:
#   None
# Outputs:
#   None
#########################################
vscode() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https
    sudo apt update -y
    sudo apt install code
}

#########################################
# Parse the config file and install
# relevant applications.
# Arguments:
#   None
# Outputs:
#   Writes status to stdout
#########################################
deliver() {
    echo "Installing applications..."
    source /etc/conf.d/packages.cfg
    sudo apt install $packages
    gh && vscode && omz
    echo "Installation complete"
}

info() {
    local dt
    dt=$(date)
    local locip
    locip=$(sudo lshw | grep ip= | cut -d "=" -f 7 | cut -d " " -f 1)
    local pubip
    pubip=$(dig +short myip.opendns.com @resolver1.opendns.com)
    local cpu
    cpu=$(sudo hwinfo | grep "model name" | head -1 | cut -d ":" -f 2)
    local gpu
    gpu=$(sudo hwinfo --gfxcard | grep Model | cut -d ":" -f 2)
    local ram
    ram=$(sudo hwinfo --memory | grep Size | cut -d ":" -f 2)
    local netcard
    netcard=$(sudo hwinfo --network | grep File | head -1 | cut -d ":" -f 2)
    local sound
    sound=$(sudo hwinfo --sound | grep Model | cut -d ":" -f 2)
    local disk
    disk=$(sudo hwinfo --disk | grep Model | cut -d ":" -f 2)
    echo "--------------------------------"
    echo "PORTUNUS LOGFILE"
    echo "--------------------------------"
    echo "Portunus completion time: $dt"
    echo "Last run by user:         $USER"
    echo "--------------------------------"
    echo "HARDWARE INFORMATION"
    echo "--------------------------------"
    echo "CPU:                     $cpu"
    echo "GPU:                     $gpu"
    echo "Storage:                 $disk"
    echo "RAM:                     $ram"
    echo "Network Interface:       $netcard"
    echo "Sound:                   $sound"
    echo "--------------------------------"
    echo "NETWORK INFORMATION"
    echo "--------------------------------"
    echo "Local IP:                 $locip"
    echo "Public IP:                $pubip"
}

main() {
    create && prep &&
        deliver && info >/var/log/portunus.log
}

main

# default save location:
#   ./portunus
# where to save each file:
#   portunus.sh - /usr/bin
#   conf.d - /etc/portunus/
#   portunus.log - /var/log
