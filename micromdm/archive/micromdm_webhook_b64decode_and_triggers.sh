#!/bin/bash

# Path to your hook script (make sure it's executable)
HOOK_SCRIPT="./hook_triggered_on_Enrollment.sh"

nc -l 5000 -k | while true; do
    content_length=0
    line=""
    body=""

    # Read HTTP headers
    while IFS= read -r line; do
        header=$(echo "$line" | tr -d '\r')
        [[ -n "$header" ]] && echo "$header"

        # Extract Content-Length
        if [[ "$header" =~ ^Content-Length:[[:space:]]*([0-9]+) ]]; then
            content_length="${BASH_REMATCH[1]}"
        fi

        # End of headers
        [[ -z "$header" ]] && break
    done

    # Read body if Content-Length > 0
    if [[ $content_length -gt 0 ]]; then
        body=$(head -c "$content_length")

        echo "=== JSON Body ==="
        echo "$body"

        # Extract topic
        topic=$(echo "$body" | jq -r '.topic // empty')

        # Check if topic is mdm.Authenticate
        if [[ "$topic" == "mdm.Authenticate" ]]; then
            echo -e "\n🚨 TRIGGERING ENROLLMENT HOOK: $HOOK_SCRIPT"
            if [[ -x "$HOOK_SCRIPT" ]]; then
                # Optionally pass body or UDID to the script
                echo "$body" | "$HOOK_SCRIPT"
            else
                echo "⚠️ Hook script not found or not executable: $HOOK_SCRIPT"
                echo "💡 Run: chmod +x $HOOK_SCRIPT"
            fi
            echo "✅ Hook execution attempted."
        fi

        # Decode raw_payload (for all topics)
        echo -e "\n=== DECODED raw_payload ==="
        echo "$body" | \
          jq -r '.checkin_event.raw_payload // .acknowledge_event.raw_payload // empty' | \
          tr -d ' \t\n\r' | \
          base64 -d 2>/dev/null || echo "(No or invalid raw_payload)"
        echo "============================"
    else
        echo "(No body to read)"
    fi

    echo "────────────────────────────"  # Separator
done

