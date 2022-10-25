#!/usr/bin/env bash

# Download and install commonly used and particularly useful applications

export PORTUNUS=/home/$USER/portunus

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
# Parse the config file and install
# relevant applications.
# Arguments:
#   None
# Outputs:
#   Writes status to stdout
#########################################
deliver() {
    echo "Installing applications..."
    source ./conf.d/packages.cfg
    sudo apt install $packages -y
    sudo bash ./conf.d/gh.sh
    sudo bash ./conf.d/vscode.sh
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
    prep && deliver && info >$PORTUNUS/portunus.log
}

main
