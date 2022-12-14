#!/bin/bash



# This script is used to manage bitwarden

source ~/.scripts/environment/elesoft/environment_variables.sh

bw_login() {
    bw login --apikey --raw 
    BW_SESSION=$(echo $BW_MASTER | bw unlock --raw)

    export BW_SESSION
    clear
}

bw_login
