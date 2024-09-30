#!/bin/bash

##########################################################################################

# written by Adam Caudill

# Script presented in Tick Tock Tech at JNUC 2024

# https://github.com/theadamcraig/jnuc2024/

##########################################################################################

# This function can be used with the ProfileAction extension attribute and configured smart groups to install or remove profiles on demand.

# –install : writes an INSTALL command
# –remove : writes a REMOVE command
# –empty : removes previous commands from this script
# –check : echo out the current commands from this script
# –forceNoRecon : disables inventory update

##########################################################################################


SCRIPT_NAME=$(basename "$0")
PROFILE_ACTION_LOG="/tmp/ProfileActions.log"

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