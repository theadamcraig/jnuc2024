#!/bin/bash



function waitForProfileInstall () {
    profileName="${1}"
    if [[ -z "$profileName" ]] ; then
        echo "no profileName Provided"
        exit 1
    fi
    index=0
    while [[ "$(profiles -C -v | grep "$profileName" | awk -F": " '/attribute: name/{print $NF}')" != *"$profileName"* ]] && [ $index -le 25 ] ; do
        echo "Waiting for $profileName configuration profile to install..."
        sleep 5
        (( index++ ))
    done
    
    if [[ "$(profiles -C -v | grep "$profileName" | awk -F": " '/attribute: name/{print $NF}')" ==  *"$profileName"* ]]; then
        echo "$profileName configuration profile has been installed"
    else
        echo "Profile was still not installed. failing."
        #displaynotification "Certificate Profile failed to Install!" "Troubleshooting"
        exit 1
    fi
}