#!/usr/bin/bash

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
    unset CODEBUILD_ROLE
    unset SESSION_NAME
    unset PROFILE
    unset USERNAME
    unset SESSION_PROFILE
    unset ORG_ACCOUNT
    unset BW_USERNAME
    unset BW_PASSWORD
    unset TF_VAR_vault_approle_role_id
    unset TF_VAR_vault_approle_secret_id
}