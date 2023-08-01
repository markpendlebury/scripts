#!/bin/bash



# This script is used to manage bitwarden

source ~/.scripts/environment/elesoft/environment_variables.sh

bw_login() {
    bw login --apikey --raw --quiet
    BW_SESSION=$(echo $BW_MASTER | bw unlock --quiet --raw)

    export BW_SESSION
}

bw_login
