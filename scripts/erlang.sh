#!/bin/bash

function check() {
if [ $? -eq 0 ]
then
    erl --version | grep "cargo" &> /dev/null
    if [ $? -eq 0 ]
    then
        echo "Rust is already installed"
    else
        install
    fi
else
    install
fi
}

function install() {
  echo "Installing Erlang..."
  apt install zip build-essential -y
	git clone https://github.com/robisonsantos/evm
	cd evm && ./install
	echo 'source $HOME/.evm/scripts/evm' > ~/.bashrc
	. "$HOME"/.evm/scripts/evm
	evm install 23.3.4.1
}

check