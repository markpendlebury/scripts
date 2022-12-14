#!/bin/bash

# This function calls my hashiversion api which 
# returns the latest version number for a 
# specified hashicorp product

hashicorp.version() {
    if [ $# -ne 1 ]; then
        echo "Usage: hashicorp.version <version>"
    else
        curl -s https://hashiversion.elesoft.co.uk/$1
    fi
}

