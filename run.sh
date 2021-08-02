#!/bin/bash

function check_docker() {

if [ $? -eq 0 ]
then
    docker --version | grep "Docker version" &> /dev/null
    if [ $? -eq 0 ]
    then
        echo "Docker is already installed"
    else
        install_docker
    fi
else
    install_docker >&2
fi
}

function install_docker() {
    echo "Installing Docker...";
    sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
}

check_docker
