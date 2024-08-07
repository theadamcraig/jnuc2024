#!/bin/bash

applicationName="Google Chrome"
updateTrigger="install_chrome"


if [[ -z $( pgrep -x "$applicationName" ) ]] ; then
    echo "$applicationName is not running."
    jamf policy -event $updateTrigger -forceNoRecon
    jamf recon
else
    echo "$applicationName is currently running"
    exit 1
fi

exit 0