#!/bin/bash

# Read UDID from first line of stdin
read udid_line
UDID="${udid_line#UDID=}"

# Read the rest (the decoded plist XML)
decoded_plist=$(cat)

# If UDID wasn't passed or empty, extract from plist
if [[ -z "$UDID" || "$UDID" == "UDID" ]]; then
    UDID=$(echo "$decoded_plist" | sed -n 's/.*<key>UDID<\/key>.*<string>\([^<]*\)<\/string>.*/\1/p' | head -1)
fi

# Fallback: extract 40-char hex string
if [[ -z "$UDID" ]]; then
    UDID=$(echo "$decoded_plist" | grep -oE '[a-fA-F0-9]{40}' | head -1)
fi

# Log
log_entry="[$(date)] 🚫 mdm.CheckOut received | UDID: $UDID"
echo "$log_entry"
echo "$log_entry" >> checkout.log

# Optional: remove device file
if [[ -n "$UDID" ]]; then
    rm -f "devices/${UDID}.plist"
fi

echo "✅ CheckOut hook executed for UDID: $UDID"
