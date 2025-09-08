#!/bin/bash 
#I have MYIPHONE8_UDID environment (~/.profile, ~/.bashrc)
if [ -n "$MY_IPHONE8_UDID" ]; then
    echo "Variable MY_IPHONE8_UDID is set"
else
    echo "Variable MY_IPHONE8_UDID is not set"
    exit 1
fi

UDID=$MY_IPHONE8_UDID
UDID_NEW=89sd899hkjjkjh8998sd8kkjjkjhds899

# Find all TEXT files containing the old UDID (skips binary files) and replace every occurrence
grep -rIl "$UDID" ./ | while read -r file; do
    sed -i "s@$UDID@$UDID_NEW@g" "$file"
done
