#!/bin/bash
# Add Client To Static Group
# Tested with macOS Ventura, macOS Sonoma
# API Permissions: Update Static Computer Groups, Read Computers, Read Static Computer Groups

# Variables

client_id="$4"
client_secret="$5"
static_id="$6"
jss_url=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
jss_url=${jss_url%/} # Removes the trailing slash

# Verify Variables

if [[ -z "$client_id" || -z "$client_secret" || -z "$jss_url" ]]; then
    echo "You must provide all of the variables. Exiting..."
    exit 1
fi

# Functions

getAccessToken() {
	response=$(curl --silent --location --request POST "${jss_url}/api/oauth/token" \
 	 	--header "Content-Type: application/x-www-form-urlencoded" \
 		--data-urlencode "client_id=${client_id}" \
 		--data-urlencode "grant_type=client_credentials" \
 		--data-urlencode "client_secret=${client_secret}")
 	access_token=$(echo "$response" | plutil -extract access_token raw -)
 	token_expires_in=$(echo "$response" | plutil -extract expires_in raw -)
 	token_expiration_epoch=$(($current_epoch + $token_expires_in - 1))
}

checkTokenExpiration() {
 	current_epoch=$(date +%s)
    if [[ token_expiration_epoch -ge current_epoch ]]
    then
        echo "Token valid until the following epoch time: " "$token_expiration_epoch"
    else
        echo "No valid token available, getting new token"
        getAccessToken
    fi
}

invalidateToken() {
	responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${access_token}" ${jss_url}/api/v1/auth/invalidate-token -X POST -s -o /dev/null)
	if [[ ${responseCode} == 204 ]]
	then
		echo "Token successfully invalidated"
		access_token=""
		token_expiration_epoch="0"
	elif [[ ${responseCode} == 401 ]]
	then
		echo "Token already invalid"
	else
		echo "An unknown error occurred invalidating the token"
	fi
}

# Function to remove a computer from a static group in Jamf Pro using its serial number

add_to_static_group() {
    # Input parameter
    local group_id="$1"          # Static group ID

    # Get the serial number of the Mac
    local serial_number=$(system_profiler SPHardwareDataType | grep Serial |  awk '{print $NF}')

    # Fetch computer ID using the serial number
    local api_endpoint="/JSSResource/computers/serialnumber/${serial_number}"

    # Update API endpoint for static group
    api_endpoint="/JSSResource/computergroups/id/${group_id}"

    # Create XML
    local updated_xml="<computer_group><computer_additions><computer><serial_number>${serial_number}</serial_number></computer></computer_additions></computer_group>"

    # Update the static group using the created XML
    curl -s -X PUT -H "Authorization: Bearer ${access_token}" "${jss_url}${api_endpoint}" \
         -H "Content-Type: text/xml" \
         -d "${updated_xml}" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "Error: Failed to update static group."
    else
        echo "Success: Successfully updated static group."
    fi
}

# Get Access Token

checkTokenExpiration
curl -H "Authorization: Bearer $access_token" ${jss_url}/api/v1/jamf-pro-version -X GET > /dev/null
checkTokenExpiration

# Usage example:
# add_to_static_group $static_id

add_to_static_group ${static_id}

# Invalidate the token

invalidateToken
curl -H "Authorization: Bearer $access_token" ${jss_url}/api/v1/jamf-pro-version -X GET > /dev/null

exit 0