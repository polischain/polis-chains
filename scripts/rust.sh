#!/bin/bash

function check() {
if [ $? -eq 0 ]
then
    cargo --version | grep "cargo" &> /dev/null
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
  echo "Installing Rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y
}

check