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

    TARGET_ACCOUNT_ALIAS="$1"
    if [ -z "$1" ]; then
        echo "Usage: getcredentials {accountname}"
        return
    fi

    wipe_tokens
    echo "Switching to $TARGET_ACCOUNT_ALIAS"

    if [ "$TARGET_ACCOUNT_ALIAS" = "elesoft" ]; then
        export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "elesoft")
        export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "elesoft")
        export AWS_DEFAULT_REGION="eu-west-2"
    else

        # Use JQ to parse the results of list-accounts and return the ID of the account inputted in $1
        TARGET_ACCOUNT_ID=$(aws organizations list-accounts --profile "elesoft" | jq --arg ACCOUNT "$TARGET_ACCOUNT_ALIAS" --raw-output '.Accounts[] | select(.Name == $ACCOUNT) | {Id} | join("")')
        echo "Successfully found ID for $TARGET_ACCOUNT_ALIAS: $TARGET_ACCOUNT_ID"
        AWS_CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::"$TARGET_ACCOUNT_ID":role/switch-role-admin --role-session-name "$SESSION_NAME" --profile "elesoft")

        if [ -z "$AWS_CREDENTIALS" ]; then
            echo "Failed to get credentials for $TARGET_ACCOUNT_ALIAS"
            return
        else
            # Use JQ to parse the json contained within AWS_CREDENTIALS to get the AccessKeyId value
            AWS_ACCESS_KEY_ID=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.AccessKeyId' | tr -d '"')
            # Use JQ to parse the json contained within AWS_CREDENTIALS to get the SecretAccessKey value
            AWS_SECRET_ACCESS_KEY=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.SecretAccessKey' | tr -d '"')
            # Use JQ to parse the json contained within AWS_CREDENTIALS to get the SessionToken value
            AWS_SESSION_TOKEN=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.SessionToken' | tr -d '"')
            # Assign the default region
            AWS_DEFAULT_REGION=eu-west-1

            # Create a working profile with the above aws credentials:
            aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$SESSION_PROFILE"
            aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$SESSION_PROFILE"
            aws configure set aws_default_region "$AWS_DEFAULT_REGION" --profile "$SESSION_PROFILE"
            aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile "$SESSION_PROFILE"

            # Set environment:
            export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
            export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
            export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
            export AWS_DEFAULT_REGION="eu-west-2"
            echo "Successfully set profile $SESSION_PROFILE with credentials for $TARGET_ACCOUNT_ALIAS"

        fi

    fi
}

# authenticate() {
#     echo "Authenticating with account $1 using $2 and $3"

#     # Use the above returned ACCOUNT_ID to assume role for the requested account
#     AWS_CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::"$1":role/"$2" --role-session-name "$3" --profile "$PROFILE")

#     # error checking
#     # if $AWS_CREDENTIALS is empty, exit the script
#     if [ -z "$AWS_CREDENTIALS" ]; then
#         echo "Error during assume role on $TARGET_ACCOUNT"
#         # return
#     fi

#     # Use JQ to parse the json contained within AWS_CREDENTIALS to get the AccessKeyId value
#     AWS_ACCESS_KEY_ID=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.AccessKeyId' | tr -d '"')
#     # Use JQ to parse the json contained within AWS_CREDENTIALS to get the SecretAccessKey value
#     AWS_SECRET_ACCESS_KEY=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.SecretAccessKey' | tr -d '"')
#     # Use JQ to parse the json contained within AWS_CREDENTIALS to get the SessionToken value
#     # AWS_SESSION_TOKEN=$(echo "$AWS_CREDENTIALS" | jq '.Credentials.SessionToken' | tr -d '"')
#     # Assign the default region
#     AWS_DEFAULT_REGION=eu-west-1

#     # Create a working profile with the above aws credentials:
#     aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$SESSION_PROFILE"
#     aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$SESSION_PROFILE"
#     # aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile "$SESSION_PROFILE"
#     aws configure set aws_default_region "$AWS_DEFAULT_REGION" --profile "$SESSION_PROFILE"

# }

# Utility function used to clear out the
# aws related environment variables
wipe_tokens() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_DEFAULT_REGION
}
