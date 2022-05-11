#!/usr/bin/bash

vault.login.elesoft() {
    unset VAULT_TOKEN
    export VAULT_ADDR=https://vault.$PROFILE.dev
    export VAULT_TOKEN=$(vault login --method=userpass username=$USERNAME --format=json | jq -r '.auth.client_token')
}



vault.generate.random() {

    # requires xclip: https://github.com/astrand/xclip
    # Uses hashicorp vault to generate a random 32bit base64 string
    # then asks the user if they want to copy it to their clipboard
    # or output to terminal
    
    BYTES=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data "{ \"format\": \"base64\" }" https://vault.elesoft.dev/v1/sys/tools/random/32 | jq -r '.data.random_bytes')

    echo "Copy to clipboard? (y/n) "
    read -r REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$BYTES" | xclip -sel clip;
    else
        echo "$BYTES"
    fi
}
