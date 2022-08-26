#!/bin/bash



# This script is used to manage bitwarden

source ~/.scripts/environment/elesoft/environment_variables.sh

bw_login() {
    bw login --apikey --raw 
    BW_SESSION=$(echo $BW_MASTER | bw unlock --raw)

    export BW_SESSION
    clear
}

# BWGetVaultCredentials() {

#     if [ -z "$BW_SESSION" ]; then
#         bw_login
#     fi

#     if [ -z "$1" ]; then
#         echo "No Client name provided"
#         echo "Usage BWGetVaultCredentials [CLIENTNAME]"
#         return 1
#     fi

#     CLIENT=$1

#     # Use this to get an item from EVERYTHING... because BW Cli is shit
#     export USERNAME=$(bw list items | jq -r '.[] | select(.name=="Vault-$CLIENT")' | jq -r '.login.username')
#     export PASSWORD=$(bw list items | jq -r '.[] | select(.name=="Vault-$CLIENT")' | jq -r '.login.password')
#     export URL=$(bw list items | jq -r '.[] | select(.name=="Vault-$CLIENT")' | jq -r '.login.uri')

#     echo $PASSWORD
# }

bw_login
