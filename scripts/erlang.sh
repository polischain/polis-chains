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
  apt install openssl libssl-dev fop xsltproc unixodbc-dev libxml2-utils libwxbase3.0-0v5 libwxbase3.0-dev libqt5opengl5-dev libncurses-dev libwxgtk3-3.0-gtk3-dev libwxgtk3-3.0-gtk3-0v5 wx-common -y
	git clone https://github.com/robisonsantos/evm
	cd evm && ./install
	echo 'source $HOME/.evm/scripts/evm' > ~/.bashrc
	. "$HOME"/.evm/scripts/evm
	evm install 23.3.4.1
}

check