#!/bin/bash

##########################################################################################

# written by Adam Williams

# Script presented in Tick Tock Tech at JNUC 2024

# https://github.com/theadamcraig/jnuc2024/

##########################################################################################

function waitForProfileRemoval () {
    profileName="${1}"
    if [[ -z "$profileName" ]] ; then
        echo "no profileName Provided"
        exit 1
    fi
    index=0
    while [[ "$(profiles -C -v | grep "$profileName" | awk -F": " '/attribute: name/{print $NF}')" == *"$profileName"* ]] && [ $index -le 25 ] ; do
        echo "Waiting for $profileName configuration profile to remove..."
        sleep 5
        (( index++ ))
    done
    
    if [[ "$(profiles -C -v | grep "$profileName" | awk -F": " '/attribute: name/{print $NF}')" !=  *"$profileName"* ]]; then
        echo "$profileName configuration profile has been Removed"
    else
        echo "Profile was still not removed. failing."
        exit 1
    fi
}