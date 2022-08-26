#!/bin/bash


# This file contains a collection of functions that will install or update some applications


install.aws(){

    CURRENTDIR=$(pwd)
    echo "Downloading latest aws cli..."
    cd tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip

    echo "Installing..."
    sudo sudo ./aws/install
    
    echo "Cleanup..."
    rm -f awscliv2.zip
    rm -rf aws/

    cd $CURRENTDIR
    echo "Done!"

}


install.vault(){
    echo "Installing Vault..."
    sudo apt update && sudo apt install gpg
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
    gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vault -y
    echo "Done!"
}


install.bw(){
    echo "Installing Bitwarden..."
    sudo snap install bw
    echo "Done!"
}