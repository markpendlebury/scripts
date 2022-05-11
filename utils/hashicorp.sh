#!/bin/zsh

hashicorp.version() {
    if [ $# -ne 1 ]; then
        echo "Usage: hashicorp.version <version>"
    else
        curl -s https://hashiversion.elesoft.dev/$1
    fi
}