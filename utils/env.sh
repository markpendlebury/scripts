#!/usr/bin/bash

# This function is called from alias which is in turn sourced from ~/.zshrc or ~/.bashrc
# It is used to load the environment specific scripts to the current shell

init() {
    # Disable POWERLEVEL9k crapping itsself if we output
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
}

# Here we unload the environment variables
unload() {
    unset VAULT_ADDR
    unset VAULT_TOKEN
    unset VAULT_SKIP_VERIFY
    unset VAULT_PROFILE
    unset VAULT_ADDR
    unset VAULT_ROLE
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_DEFAULT_REGION
    unset ADMIN_ROLE
    unset ROLE
    unset SESSION_NAME
    unset PROFILE
    unset USERNAME
    unset TF_VAR_vault_address
    unset TF_VAR_vault_skip_verify
    unset TF_VAR_vault_profile
    unset TF_VAR_vault_role
    unset BW_USERNAME
    unset BW_PASSWORD
    unset SEEDBOX_VPN_PASSWORD
    unset CLIENT
}

# Unload existing variables:
unload
init
