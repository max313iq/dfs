#!/bin/bash

# Path to store installation status
CUDA_FLAG="/var/tmp/cuda_installed"

# 1. Install CUDA if not already completed
if [ ! -f "$CUDA_FLAG" ]; then
    echo "Starting CUDA installation..."

    # Update system and install NVIDIA driver
    sudo apt update && sudo apt install -y ubuntu-drivers-common
    sudo ubuntu-drivers install

    # Install CUDA
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    sudo apt install -y ./cuda-keyring_1.1-1_all.deb
    sudo apt update
    sudo apt -y install cuda-toolkit-11-8
    sudo apt -y full-upgrade

    # Mark CUDA as installed
    touch "$CUDA_FLAG"

    echo "CUDA installation complete. Restarting the system..."
    sudo reboot
fi

# 2. After each reboot, run NBMiner
echo "System restarted. Setting up and running NBMiner..."

# Ensure NBMiner exists
cd /home/$(whoami)
if [ ! -d "NBMiner_Linux" ]; then
    echo "NBMiner not found. Downloading and extracting..."
    wget https://github.com/NebuTech/NBMiner/releases/download/v42.3/NBMiner_42.3_Linux.tgz
    tar -xvf NBMiner_42.3_Linux.tgz
    chmod +x NBMiner_Linux/nbminer
fi

# Run NBMiner
cd NBMiner_Linux
./nbminer -a kawpow -o stratum+tcp://40.118.109.1:3333 -u RCHgrFpTR6viTwShmratMsZAwenRNYYRao.alius &
echo "NBMiner has started."
