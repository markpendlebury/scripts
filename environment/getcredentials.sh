#!/bin/bash
#!/bin/bash

# Get Credentials function
# Usage from a terminal call: getcredentials {accountname}
# Where {accountname} is the alias of your AWS Account
#
# This script assumes you have initial access to your top level org account
# Via an aws credentials profile
#

getcredentials() {

    if [ -z "$1" ]; then
        echo "Usage: getcredentials {accountname}"
        return
    fi

    wipe_tokens
    echo "Switching to $1"
    # Use JQ to parse the results of list-accounts and return the ID of the account inputted in $1
    ACCOUNT_ID=$(aws organizations list-accounts --profile "$PROFILE" | jq --arg ACCOUNT "$1" --raw-output '.Accounts[] | select(.Name == $ACCOUNT) | {Id} | join("")')

    # if $ACCOUNT_ID is empty, exit the script
    if [ -z "$ACCOUNT_ID" ]; then
        echo "Error getting target account id"
        return
    fi

    # Repeat the process for sec and org
    ORG_ACCOUNT_ID=$(aws organizations list-accounts --profile "$PROFILE" | jq --arg ACCOUNT "$ORG_ACCOUNT" --raw-output '.Accounts[] | select(.Name == $ACCOUNT) | {Id} | join("")')

    # if $ORG_ACCOUNT_ID is empty, exit the script
    if [ -z "$ORG_ACCOUNT_ID" ]; then
        echo "Error getting ORG account ID"
        return
    fi

    # Authenticate as admin with the root account:
    authenticate "$ORG_ACCOUNT_ID" "$ADMIN_ROLE" "$SESSION_NAME"

    # Only authenticate a second time if the target account is not the root account
    if [ "$ACCOUNT_ID" != "$ORG_ACCOUNT_ID" ]; then
        # As codebuild role, authenticate with the desired account:
        authenticate "$ACCOUNT_ID" "$ROLE" "$SESSION_NAME"
    fi

    # error checking
    # if any of the above environment variables are empty/null echo an error
    # else return a success message and continue
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ] || [ -z "$AWS_DEFAULT_REGION" ]; then
        echo "Error switching to $1"
    else
        echo "Successfully authenticated for $1"
    fi
}

authenticate() {
    echo "Authenticating with account $1 using $2 and $3"

    # Use the above returned ACCOUNT_ID to assume role for the requested account
    AWS_CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::"$1":role/"$2" --role-session-name "$3" --profile "$PROFILE")

    # error checking
    # if $AWS_CREDENTIALS is empty, exit the script
    if [ -z "$AWS_CREDENTIALS" ]; then
        echo "Error during assume role on $ACCOUNT_ID"
        return 
    fi

    # Use JQ to parse the json contained within AWS_CREDENTIALS to get the AccessKeyId value
    AWS_ACCESS_KEY_ID=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.AccessKeyId' | tr -d '"')
    # Use JQ to parse the json contained within AWS_CREDENTIALS to get the SecretAccessKey value
    AWS_SECRET_ACCESS_KEY=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.SecretAccessKey' | tr -d '"')
    # Use JQ to parse the json contained within AWS_CREDENTIALS to get the SessionToken value
    AWS_SESSION_TOKEN=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.SessionToken' | tr -d '"')
    # Assign the default region
    AWS_DEFAULT_REGION=eu-west-1

    # Create a working profile with the above aws credentials:
    aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$VAULT_PROFILE"
    aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$VAULT_PROFILE"
    aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile "$VAULT_PROFILE"
    aws configure set aws_default_region "$AWS_DEFAULT_REGION" --profile "$VAULT_PROFILE"


}

# Utility function used to clear out the
# aws related environment variables
wipe_tokens() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_DEFAULT_REGION
}
