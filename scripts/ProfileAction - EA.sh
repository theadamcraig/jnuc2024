#!/bin/bash
#EA to read ProfileActions.log entries

PROFILE_ACTION_LOG="/tmp/ProfileActions.log"

result=''

if [[ -f "${PROFILE_ACTION_LOG}" ]] ; then
	result=""
    if [[ -n $(grep -e "INSTALL:" ${PROFILE_ACTION_LOG}) ]]; then
        result="$(grep -e "INSTALL:" ${PROFILE_ACTION_LOG} | sed 's/.*SCRIPT: //')"
    fi
    if [[ -n $(grep -e "REMOVE:" ${PROFILE_ACTION_LOG}) ]]; then
        result="$(grep -e "REMOVE:" ${PROFILE_ACTION_LOG} | sed 's/.*SCRIPT: //')
        ${result}"
    fi
else
	result="None"
fi

echo "<result>${result}</result>"
exit 0

