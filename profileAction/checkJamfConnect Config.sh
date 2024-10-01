#!/bin/bash

##########################################################################################

# written by Adam Caudill

# Script presented in Tick Tock Tech at JNUC 2024

# https://github.com/theadamcraig/jnuc2024/

##########################################################################################

# This script is an example of:
#    using the profileAction function
#    using the waitForProfileRemoval function
#    removing and reinstalling a profile if there is an outdated value 
#        In this example replacing a Jamf Connect Profile if the username label is "Username" instead of "Email"

##########################################################################################


SCRIPT_NAME=$(basename "$0")
PROFILE_ACTION_LOG="/tmp/ProfileActions.log"
profileName="Jamf Connect - Full Deployment"

profileAction() {
    local check
    local empty
    local recon=true
    local action
    local profileName
    while test $# -gt 0 ; do
        case "$1" in 
            -c|--check) check=true
            ;;
            -e|--empty) empty=true
            ;;
            -f|--forceNoRecon) recon=false
            ;;
            -i|--install) local action="INSTALL"
                shift
                profileName="$1"
            ;;
            -r|--remove) local action="REMOVE"
                shift
                profileName="$1"
            ;;
        esac
        shift
    done
    
    if [ $empty ] ; then
        echo "ProfileAction EMPTY"
        #Removing previous entries of this
        sed -i '' '/'"$SCRIPT_NAME"'/d' "$PROFILE_ACTION_LOG"
    fi
    
    if [ -n "$action" ] && [ -n "$profileName" ] ; then
        echo "ProfileAction $action: $profileName"
        echo "$(date +'%m-%d-%Y %r')" SCRIPT: "$SCRIPT_NAME" "$action": "$profileName" >> "$PROFILE_ACTION_LOG"
    fi
    
    if [ $check ] ; then
        result="$(grep -e "$SCRIPT_NAME" ${PROFILE_ACTION_LOG} | sed 's/.*SCRIPT: //' )"
        echo "${result}"
    fi
    
    if [ $recon ] ; then
        jamf recon >> /dev/null 2>&1
    fi
}

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

## check Jamf Connect Config

UsernameLabel=$( defaults read /Library/Managed\ Preferences/com.jamf.connect.plist  | grep "UsernameLabel" )

if [[ -z "${UsernameLabel}" ]] || [[ "${UsernameLabel}" == "UsernameLabel = Username" ]] ; then
    echo "Profile is out of date"
    profileAction --remove "$profileName"
    waitForProfileRemoval "$profileName"
    profileAction --empty
fi
exit 0
