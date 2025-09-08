#!/bin/bash

# Path to your hook script
HOOK_SCRIPT="./hook_triggered_on_Enrollment.sh"

nc -l 5000 -k | while true; do
    content_length=0
    line=""
    body=""

    # Read HTTP headers
    while IFS= read -r line; do
        header=$(echo "$line" | tr -d '\r')
        [[ -n "$header" ]] && echo "$header"

        if [[ "$header" =~ ^Content-Length:[[:space:]]*([0-9]+) ]]; then
            content_length="${BASH_REMATCH[1]}"
        fi

        [[ -z "$header" ]] && break
    done

    if [[ $content_length -gt 0 ]]; then
        body=$(head -c "$content_length")

        echo "=== JSON Body ==="
        echo "$body"

        # Extract topic from JSON
        topic=$(echo "$body" | jq -r '.topic // empty')

        # Decode raw_payload (clean Base64)
        decoded_plist=$(echo "$body" | \
          jq -r '.checkin_event.raw_payload // .acknowledge_event.raw_payload // .raw_payload // empty' | \
          tr -d ' \t\n\r' | \
          base64 -d 2>/dev/null)

        if [[ -z "$decoded_plist" ]]; then
            echo -e "\n❌ No valid raw_payload to decode"
        else
            echo -e "\n=== DECODED raw_payload ==="
            echo "$decoded_plist"
            echo "============================"
        fi

        # --- Extract UDID from decoded plist ---
        udid=""
        if [[ "$decoded_plist" == *"<key>UDID</key>"* ]]; then
            # Use regex to extract UDID between <string>...</string> after <key>UDID</key>
            udid=$(echo "$decoded_plist" | \
              sed -n 's/.*<key>UDID<\/key>.*<string>\([^<]*\)<\/string>.*/\1/p' | \
              head -1)
        fi

        # Fallback: try case-insensitive or loose match
        if [[ -z "$udid" ]]; then
            udid=$(echo "$decoded_plist" | grep -i -A1 "udid" | grep -oE '[a-fA-F0-9]{40}' | head -1)
        fi

        # --- Trigger hook if topic is mdm.Authenticate ---
        if [[ "$topic" == "mdm.Authenticate" ]]; then
            echo -e "\n🚨 TRIGGERING ENROLLMENT HOOK: $HOOK_SCRIPT"
            if [[ -x "$HOOK_SCRIPT" ]]; then
                # Pass UDID and full payload to hook
                echo -e "UDID=$udid\nTOPIC=$topic" | "$HOOK_SCRIPT" <<< "$decoded_plist"
            else
                echo "⚠️ Hook script not found or not executable: $HOOK_SCRIPT"
                echo "💡 Run: chmod +x $HOOK_SCRIPT"
            fi
            echo "✅ Hook executed (UDID: $udid)"
        fi
    else
        echo "(No body to read)"
    fi

    echo "────────────────────────────"
done

