#!/bin/bash


function check_rust() {
if [ $? -eq 0 ]
then
    cargo --version | grep "Cargo" &> /dev/null
    if [ $? -eq 0 ]
    then
        echo "Rust is already installed"
    else
        install_rust
    fi
else
    install_docker
fi
}

function install_rust() {
  echo "Installing Rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y
  source ~/.bashrc
}

function check_node() {
  echo ""
}

function install_node() {
  echo ""
}

function check_elixir() {
  echo ""
}

function install_elixir() {
  echo ""
}

function check_erlang() {
  echo ""
}

function install_erlang() {
    echo ""
}

## Docker Check
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
    install_docker
fi
}

## Docker Install
function install_docker() {
    echo "Installing Docker...";
    sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
}

check_rust
