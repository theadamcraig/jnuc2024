#!/bin/bash

# more info on Chrome Initial Preferences here
# https://support.google.com/chrome/a/answer/187948?sjid=7463765023064133746-NC
chromeInitialPreferences="/Library/Google/Google Chrome Initial Preferences"
initialPrefPolicy="install_chrome_pref"
chromePolicy="install_chrome"
exitCode=0

policyTriggerCorrectResults() { 
    policyTrigger="${1}"
    echo "Running the jamf policy ${policyTrigger}"
    result=$( jamf policy -event "${policyTrigger}" -forceNoRecon )
    exitCode="$?"
    echo "Result of jamf policy is: ${exitCode}"
    if [[ "$result" == *"No policies were found"* ]] ; then
        echo "$result"
        echo "setting exit code to 1"
        exitCode=1
    fi
    echo "Script result is $result"
    
    if [[ "${exitCode}" = 0 ]] ; then
        echo "Policy run successfully"
    else
        echo "Policy either failed or was not found."
    fi
}

if [[ ! -e "${chromeInitialPreferences}" ]] ; then
    echo "Chrome initialPrefs missing"
    policyTriggerCorrectResults "${initialPrefPolicy}"
fi

if [[ $exitCode == 0 ]] && [[ -e "${chromeInitialPreferences}" ]] ; then
    policyTriggerCorrectResults "${chromePolicy}"
fi
exit $exitCode