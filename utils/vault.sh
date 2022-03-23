#!/bin/zsh

vault.login.elesoft() {
    unset VAULT_TOKEN
    export VAULT_ADDR=https://vault.$PROFILE.dev
    export VAULT_TOKEN=$(vault login --method=userpass username=$USERNAME --format=json | jq -r '.auth.client_token')
}
