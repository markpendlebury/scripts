#!/bin/bash

# Display the weather inside your terminal:
alias weather='curl wttr.in/$POSTCODE'

# mkdir and cd into it:
mkcdir() {
        mkdir -p -- "$1" &&
                cd -P -- "$1" || exit
}

# Copy the contents of a file to clipboard using xclip:
clipboard() {
        cat "$1" | xclip -sel clip
        echo "The contents of $1 are now in your clipboard"
}

alias bootwin='sudo efibootmgr --bootnext 1 && sudo reboot'

source $BASEDIR/environment/global_vars.sh

# Fix here for dotnet core 6+ issues with open ssl :
export CLR_OPENSSL_VERSION_OVERRIDE=1.1
