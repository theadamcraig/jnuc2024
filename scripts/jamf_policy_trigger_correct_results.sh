#!/bin/bash

##########################################################################################/

# written by Adam Caudill

# Script presented in Userproof Onboarding: Backup Plans for Zero Touch for IT JNUC 2022

# https://github.com/theadamcraig/jamf-scripts/tree/master/JNUC2022

##########################################################################################/

# This script allows the "ReRun Policy of Failure" feature to be used to maximum effect

# if a policy runs another policy via unix command it will succeed regardless of the results of the targeted policy

# This policy gets accurate results and exits accordingly, so that the rerun on failure will trigger again if the policy does fail.

##########################################################################################/

# Variables in this script

# $4 is the trigger that installs the application listed in $4

##########################################################################################/


## the policy to install the above application
policyTrigger="${4}"

# Make sure we have the variables we need
if [[ -z "${policyTrigger}" ]] ; then 
	echo "trigger:${policyTrigger} is missing"
	exit 1
fi

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

exit "${exitCode}"
