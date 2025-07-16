#!/bin/bash

# Function to update the mining pool and restart the container if the pool changes
update_and_restart() {
    new_pool_url=$(curl -s https://raw.githubusercontent.com/anhacvai11/bash/refs/heads/main/ip) # Read new pool from URL
    if [ "$new_pool_url" != "$POOL_URL" ]; then
        echo "Updating POOL_URL to: $new_pool_url"
        export POOL_URL=$new_pool_url

        # Stop & remove the old container before running a new one
        docker stop rvn-test 2>/dev/null
        docker rm rvn-test 2>/dev/null

        # Run a new container with GPU (WALLET and POOL are already in the Dockerfile)
        docker run --gpus all -d --restart unless-stopped --name rvn-test riccorg/aitraining:v3
    else
        echo "No updates found."
    fi
}

# Install Docker if not installed
install_docker() {
    apt-get update --fix-missing
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update --fix-missing
    apt-get install -y docker-ce docker-ce-cli containerd.io
}

# Check GPU before starting mining
echo "Checking GPU..."
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Check and install Docker if not installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing Docker..."
    install_docker
else
    echo "Docker is already installed."
fi

# Stop & remove the old container if running
docker stop rvn-test 2>/dev/null
docker rm rvn-test 2>/dev/null

# Run the mining Docker container with GPU (WALLET and POOL are already in the Dockerfile)
docker run --gpus all -d --restart unless-stopped --name rvn-test riccorg/imagegenv4:latest

# Wait a moment before entering the monitoring loop
sleep 10

# Continuous monitoring loop (updates pool every 20 minutes)
while true; do
    sleep 1200  # Check every 20 minutes
    update_and_restart
done
