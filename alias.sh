#!/bin/zsh

BASEDIR=~/.scripts



# Source all the required sub scripts
for FILE in $BASEDIR/utils/*.sh; do 
    source $FILE; 
done


# Source client stuff:
for FILE in $BASEDIR/clients/*.sh; do
    source $FILE;
done


