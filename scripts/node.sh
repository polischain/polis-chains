#!/bin/bash

function check() {
if [ $? -eq 0 ]
then
    node --version | grep "cargo" &> /dev/null
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
  echo "Installing Node..."
  curl --silent https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  . ~/.bashrc
  nvm install 14.17.0
}

check