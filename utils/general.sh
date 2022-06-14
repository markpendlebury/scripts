#!/bin/bash

# Display the weather inside your terminal:
alias weather='curl wttr.in/$POSTCODE'

# mkdir and cd into it:
mkcdir() {
        mkdir -p -- "$1" &&
        cd -P -- "$1" || exit
}

# Copy text to clipboard using xclip:
clipboard() {
        cat "$1" | xclip -sel clip
        echo "The contents of $1 are now in your clipboard"
}

alias bootwin='sudo efibootmgr --bootnext 0 && sudo reboot'
