#!/bin/bash

# Usage:
# This script will accept either vault approle auth or ldap auth.
# To initialise the script and make it available to your terminal session
# run the following:
# source vault.sh
#
#
# Approle auth is desienged to be used via a deployment pipeline and
# requires settings VAULT_ROLE_ID and VAULT_SECRET_ID environment variables,
# once successfully authenticated the script will export
# a valid VAULT_TOKEN environment variable allowing you to use this
# to make additional requests to vault
#
#
# userpass authentication is designed to be used during a local development process
# and requires a VAULT_USERNAME environment variable to be set
# During the process you will be prompted to enter your vault password
#

# This function will export a VAULT_TOKEN from vault via
# the approle auth method
vault.login.approle() {
    # Check we have the required parameter values
    if [[ -z "$VAULT_ROLE_ID" || -z "$VAULT_SECRET_ID" ]]; then
        echo "Missing or invalid Vault role/secret ID"
    else
        # Request client token from vault:
        VAULT_TOKEN=$(vault write auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}" --format=json | jq -r '.auth.client_token')
        # Call the check function
        check
    fi
}

# This function will export a VAULT_TOKEN from vault via
# the userpass auth method
vault.login() {

    # Check we have a username value
    if [[ -z "$VAULT_USERNAME" ]]; then
        echo "Missing or invalid Vault Username"
    else
        echo "Logging into vault with user: $VAULT_USERNAME"
        # Ask the user for their password
        echo -n "Vault password: "
        # Read silently (don't output the password to terminal duh!)
        read -rs VAULT_PASSWORD
        echo ""
        # Request client token from vault:
        VAULT_TOKEN=$(vault login --method=userpass username="$VAULT_USERNAME" password="$VAULT_PASSWORD" --format=json | jq -r '.auth.client_token')
        # Call the check function
        check
    fi
}

# This function uses vaults aws secrets engine to configure an aws profile (~/.aws/credentials)

vault.login.aws.base() {
    if [[ -z $VAULT_TOKEN ]]; then
        echo "Vault token not found, Please authenticate with vault first"
    else
        OUTPUT=$(vault read aws/creds/"$VAULT_ROLE" -format=json) && aws configure set aws_access_key_id "$(echo "$OUTPUT" | jq -r .data.access_key)" --profile "$VAULT_PROFILE" && aws configure set aws_secret_access_key "$(echo "$OUTPUT" | jq -r .data.secret_key)" --profile "$VAULT_PROFILE" && aws configure set aws_session_token "$(echo "$OUTPUT" | jq -r .data.security_token) " --profile "$VAULT_PROFILE"
    fi
}

# Helper function to check variables have been set correctly
check() {
    # Check if VAULT_TOKEN is empty or null
    if [[ -z $VAULT_TOKEN || $VAULT_TOKEN != "null" ]]; then
        echo "Successfully authenticated with vault"
        # Set some additional vault environment variables:
        export VAULT_TOKEN=$VAULT_TOKEN
    else
        echo "Useful error message: Something went wrong..."
    fi
}

# Startup script, here we check if we have vault client installed
# if not, we install it

startup() {
    # init script and check we have vault
    # If not, install it
    if ! vault --version &>/dev/null; then

        if [[ $OSTYPE == "linux-gnu"* ]]; then
            # This is linux, Check which distro we're workin with:
            PREFIX="ID="
            INPUT=$(cat </etc/os-release | grep -w "ID")
            OSID=${INPUT#"$PREFIX"}
            echo "Installing Vault"

            PREFIX="ID="
            INPUT=$(cat </etc/os-release | grep -w "ID" | tr -d '"')
            OSID=${INPUT#"$PREFIX"}

            if [[ "$OSID" == "ubuntu" || "$OSID" == "debian" ]]; then
                PM=apt
            fi
            if [[ "$OSID" == "amzn" ]]; then
                PM=yum
            fi

            $PM update -y &>/dev/null
            $PM install unzip wget -y &>/dev/null
            VAULT_VERSION=$(curl -s https://hashiversion.elesoft.co.uk/vault)
            wget -q https://releases.hashicorp.com/vault/"$VAULT_VERSION"/vault_"$VAULT_VERSION"_linux_amd64.zip -O /tmp/vault.zip &>/dev/null
            unzip /tmp/vault.zip -d /usr/local/bin/ &>/dev/nul
        fi
    fi

}

# This function uses hashicorp vault to generate a random 32bit base64 string
# then asks the user if they want to copy it to their clipboard
# or output to terminal
# depends on xclip: https://github.com/astrand/xclip

vault.generate.random() {

    BYTES=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data "{ \"format\": \"base64\" }" "$VAULT_ADDR"/v1/sys/tools/random/32 | jq -r '.data.random_bytes')

    echo "Copy to clipboard? (y/n) "
    read -r REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$BYTES" | xclip -sel clip
    else
        echo "$BYTES"
    fi
}


startup
