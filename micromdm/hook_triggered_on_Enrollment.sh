#!/bin/bash

MICROMDM_ENV_PATH=/usr/share/mobilutils/micromdm.env
export MICROMDM_ENV_PATH
source "$MICROMDM_ENV_PATH"

PATH_PROFILE_TO_APPLY=/usr/share/mobilutils/opendm-tools/Profiles/FirstRestrictions.mobileconfig
PATH_PUSH_PROFILE_CMD=/home/ubuntu/micromdm/tools/api/commands/install_profile
# Read UDID from first line
read udid_line
UDID="${udid_line#UDID=}"

# Read decoded plist
decoded_plist=$(cat)

# Extract UDID if not passed
if [[ -z "$UDID" ]]; then
    UDID=$(echo "$decoded_plist" | sed -n 's/.*<key>UDID<\/key>.*<string>\([^<]*\)<\/string>.*/\1/p' | head -1)
fi
if [[ -z "$UDID" ]]; then
    UDID=$(echo "$decoded_plist" | grep -oE '[a-fA-F0-9]{40}' | head -1)
fi

# Log
log_entry="[$(date)] 🔐 mdm.Authenticate received | UDID: $UDID"
echo "$log_entry"
echo "$log_entry" >> enrollment.log

# Save device info
if [[ -n "$UDID" ]]; then
    mkdir -p devices
    safe_udid=$(echo "$UDID" | tr -d '[:space:]')
    echo "💡 We will apply profile $PATH_PROFILE_TO_APPLY"
    echo "cmd:  $PATH_PUSH_PROFILE_CMD $UDID $PATH_PROFILE_TO_APPLY"
    echo "will execute: $PATH_PUSH_PROFILE_CMD $UDID $PATH_PROFILE_TO_APPLY"
    echo "After a 5seconds sleep 🤓"
    sleep 5
    $PATH_PUSH_PROFILE_CMD $UDID $PATH_PROFILE_TO_APPLY
    #/home/ubuntu/micromdm/tools/api/commands/install_profile 89sd899hkjjkjh8998sd8kkjjkjhds899 /usr/share/mobilutils/First\ Restrictions.mobileconfig
fi

echo "✅ Enrollment hook executed for UDID: $UDID"

