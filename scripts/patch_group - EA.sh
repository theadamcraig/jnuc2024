#!/bin/bash

companyName="YourCompanyNameHere"

# Get today's date in YYYY-MM-DD format
current_date=$(date +"%Y-%m-%d")

# Create plist file if it doesn't exist or if current_group key doesn't exist
if [[ ! -f "/Library/Preferences/com.${companyName}.patchgroup.plist" ]] || ! defaults read "/Library/Preferences/com.${companyName}.patchgroup.plist" current_group &>/dev/null; then
    touch "/Library/Preferences/com.${companyName}.patchgroup.plist"
    defaults write "/Library/Preferences/com.${companyName}.patchgroup.plist" current_group -int 0
fi

# Read the last updated date from the plist file
last_updated=$(defaults read "/Library/Preferences/com.${companyName}.patchgroup.plist" last_updated 2>/dev/null)

# If last_updated is today's date, exit the script
if [[ "$last_updated" == "$current_date" ]] && [[ ! $(defaults read "/Library/Preferences/com.${companyName}.patchgroup.plist" current_group) -eq 0 ]]; then
    echo "<result>$(defaults read "/Library/Preferences/com.${companyName}.patchgroup.plist" current_group)</result>"
    exit 0
fi

# Read the current group from the plist file
current_group=$(defaults read "/Library/Preferences/com.${companyName}.patchgroup.plist" current_group)

# If the current group is empty or zero, randomly generate a number between 1-8 to set the value
if [[ -z "$current_group" || "$current_group" -eq 0 ]]; then
    current_group=$(( (RANDOM % 8) + 1 ))
else
    # If it is not empty and the current_group value is less than 8, add 1 and set that as the new value
    if [[ $current_group -lt 8 ]]; then
        current_group=$((current_group + 1))
    elif [[ $current_group -eq 8 ]]; then
        current_group=1
    fi
fi

# Update the plist file with the new current_group value
defaults write "/Library/Preferences/com.${companyName}.patchgroup.plist" current_group -int $current_group

# Update the plist file with the new last_updated date
defaults write "/Library/Preferences/com.${companyName}.patchgroup.plist" last_updated $current_date

echo "<result>$(defaults read "/Library/Preferences/com.${companyName}.patchgroup.plist" current_group)</result>"

exit 0
