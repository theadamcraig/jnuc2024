#!/bin/bash
# Remove Client from Static Group
# Tested with macOS Ventura, macOS Sonoma
# API Permissions: Update Static Computer Groups, Read Computers, Read Static Computer Groups

# Variables
jamf_url=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url)
jamf_url=${jamf_url%%/} # Removes the trailing /
api_user="${4}"
api_pass="${5}"
static_id="${6}"

if [ -z "$jamf_url" ] || [ -z "$api_user" ] || [ -z "$api_pass" ] || [ -z "$static_id" ]; then
    echo "One or more parameters are missing!"
    exit 1
fi

# Functions


request_auth_token() {
    ## Request Auth Token
    authToken=$( /usr/bin/curl \
    --request POST \
    --silent \
    --url "$jamf_url/api/v1/auth/token" \
    --user "$api_user:$api_pass" )

    echo "$authToken"

    # parse auth token
    token=$( /usr/bin/plutil \
    -extract token raw - <<< "$authToken" )

    tokenExpiration=$( /usr/bin/plutil \
    -extract expires raw - <<< "$authToken" )

    localTokenExpirationEpoch=$( TZ=GMT /bin/date -j \
    -f "%Y-%m-%dT%T" "$tokenExpiration" \
    +"%s" 2> /dev/null )

    echo Token: "$token"
    echo Expiration: "$tokenExpiration"
    echo Expiration epoch: "$localTokenExpirationEpoch"
}


# Function to remove a computer from a static group in Jamf Pro using its serial number
remove_from_static_group() {
    # Input parameter
    local group_id="$1"          # Static group ID

    # Get the serial number of the Mac
    local serial_number=$(system_profiler SPHardwareDataType | grep Serial |  awk '{print $NF}')

    # Fetch computer ID using the serial number
    local api_endpoint="/JSSResource/computers/serialnumber/${serial_number}"

    # Update API endpoint for static group
    api_endpoint="/JSSResource/computergroups/id/${group_id}"

    # Create XML
    local updated_xml="<computer_group><computer_deletions><computer><serial_number>${serial_number}</serial_number></computer></computer_deletions></computer_group>"

    # Update the static group using the created XML
    curl -s -X PUT -H "Authorization: Bearer ${token}" "${jamf_url}${api_endpoint}" \
         -H "Content-Type: text/xml" \
         -d "${updated_xml}" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "Error: Failed to update static group."
    else
        echo "Success: Successfully updated static group."
    fi
}

# Usage example:
# remove_from_static_group $static_id


expire_auth_token() {
    # expire auth token
    /usr/bin/curl \
    --header "Authorization: Bearer $token" \
    --request POST \
    --silent \
    --url "$jamf_url/api/v1/auth/invalidate-token"

    # verify auth token is valid
    checkToken=$( /usr/bin/curl \
    --header "Authorization: Bearer $token" \
    --silent \
    --url "$jamf_url/api/v1/auth" \
    --write-out "%{http_code}" )

    tokenStatus=${checkToken: -3}
    # Token status should be 401
    echo "Token status: $tokenStatus"
}

request_auth_token

remove_from_static_group ${static_id}

expire_auth_token

exit 0