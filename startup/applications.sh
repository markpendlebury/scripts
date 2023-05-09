#!/bin/bash


# This script helps with opening application on a schedule,
# For example, only open slack on a week day during working hours

# Globals
CURRENT_TIME=$(date +%H:%M)

startup() {
    # Is today a weekday?
     if [[ $(date +%u) -lt 6 ]]; then
        # Is the current time between 6am and 4pm?
        if [[ "$CURRENT_TIME" > "06:00" ]] && [[ "$CURRENT_TIME" < "16:00" ]]; then
            # Load the work profile
            work
        fi
     fi
}

work(){
    # open slack
    /usr/bin/slack -u %U
}

startup