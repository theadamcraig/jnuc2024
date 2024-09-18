#!/bin/bash

applicationName="Google Chrome"
updateTrigger="install_chrome"

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

if [[ -z $( pgrep -x "$applicationName" ) ]] ; then
    echo "$applicationName is not running."
    policyTriggerCorrectResults "${updateTrigger}"
    jamf recon
else
    echo "$applicationName is currently running"
    exit 1
fi

exit $exitCode