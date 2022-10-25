#!/bin/bash

# A script to set up your linux machine the way logank would want it set up
export portunus=/home/$USER/portunus

function prep {
    echo "Setting things up. . ."
    # Update apt sources
    sudo apt update && sudo apt upgrade
# Ensure wget is installed before beginning install process
    if ! [ -f "/usr/bin/wget" ] ; then
        sudo apt install wget -y
        fi
    echo "Prep complete."
}

# Install basic applications and dependencies via apt
function deliver {
    echo "Installing applications..."
    sudo apt install $(cat $portunus/.conf) -y
    sudo bash ./conf.d/gh.sh
    sudo bash ./conf.d/vscode.sh
    echo "Installation complete"
    clear
}

function info {
    dt=$(date)
    locip=$(sudo lshw | grep ip= | cut -d "=" -f 7 | cut -d " " -f 1)
    pubip=$(dig +short myip.opendns.com @resolver1.opendns.com)
    cpu=$(sudo hwinfo | grep "model name" | head -1 | cut -d ":" -f 2)
    gpu=$(sudo hwinfo --gfxcard | grep Model | cut -d ":" -f 2)
    ram=$(sudo hwinfo --memory | grep Size | cut -d ":" -f 2)
    netcard=$(sudo hwinfo --network | grep File | head -1 | cut -d ":" -f 2)
    sound=$(sudo hwinfo --sound | grep Model | cut -d ":" -f 2)
    disk=$(sudo hwinfo --disk | grep Model | cut -d ":" -f 2)
    clear
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

prep && deliver && info > $portunus/portunus.log
