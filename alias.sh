#!/bin/bash

BASEDIR=~/.scripts

for FILE in "$BASEDIR"/utils/*.sh; do
    source "$FILE"
done