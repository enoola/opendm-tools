#!/bin/bash

ENROLL_HOOK="./hook_triggered_on_Enrollment.sh"
CHECKOUT_HOOK="./hook_triggered_on_CheckOut.sh"

# Listen in a loop: one nc per connection
while true; do
    # Start nc for a single connection (remove -k, we handle loop ourselves)
    # Timeout after 10 seconds of silence to avoid hanging
    timeout 30s nc -l -p 5000 | {
        content_length=0
        body=""

        # Read headers
        while IFS= read -r line; do
            # Remove \r
            header=$(echo "$line" | tr -d '\r')
            [[ -z "$header" ]] && break  # end of headers

            # Show header
            echo "$header"

            # Extract Content-Length
            if [[ "$header" =~ ^Content-Length:[[:space:]]*([0-9]+) ]]; then
                content_length="${BASH_REMATCH[1]}"
            fi
        done

        # Read body if Content-Length > 0
        if [[ $content_length -gt 0 ]]; then
            body=$(head -c "$content_length" 2>/dev/null || echo "")

            echo "=== JSON Body ==="
            echo "$body"

            # Extract topic
            topic=$(echo "$body" | jq -r '.topic // empty')

            # Decode raw_payload
            decoded_plist=$(echo "$body" | \
              jq -r '.checkin_event.raw_payload // .acknowledge_event.raw_payload // .raw_payload // empty' | \
              tr -d ' \t\n\r' | \
              base64 -d 2>/dev/null)

            if [[ -n "$decoded_plist" ]]; then
                echo -e "\n=== DECODED raw_payload ==="
                echo "$decoded_plist"
                echo "============================"
            else
                echo -e "\n❌ No valid raw_payload to decode"
            fi

            # Extract UDID from plist
            udid=""
            if [[ "$decoded_plist" == *"<key>UDID</key>"* ]]; then
                udid=$(echo "$decoded_plist" | \
                  sed -n 's/.*<key>UDID<\/key>.*<string>\([^<]*\)<\/string>.*/\1/p' | \
                  head -1)
            fi
            if [[ -z "$udid" ]]; then
                udid=$(echo "$decoded_plist" | grep -oE '[a-fA-F0-9]{40}' | head -1)
            fi

            # Trigger hook
            case "$topic" in
                "mdm.Authenticate")
                    echo -e "\n🚨 TRIGGERING ENROLLMENT HOOK: $ENROLL_HOOK"
                    if [[ -x "$ENROLL_HOOK" ]]; then
                        {
                            echo "UDID=$udid"
                            echo "$decoded_plist"
                        } | "$ENROLL_HOOK"
                    else
                        echo "⚠️ Hook not found or not executable: $ENROLL_HOOK"
                    fi
                    ;;
                "mdm.CheckOut")
                    echo -e "\n🚨 TRIGGERING CHECKOUT HOOK: $CHECKOUT_HOOK"
                    if [[ -x "$CHECKOUT_HOOK" ]]; then
                        {
                            echo "UDID=$udid"
                            echo "$decoded_plist"
                        } | "$CHECKOUT_HOOK"
                    else
                        echo "⚠️ Hook not found or not executable: $CHECKOUT_HOOK"
                    fi
                    ;;
                *)
                    echo "ℹ️ Topic: $topic (no hook configured)"
                    ;;
            esac
        else
            echo "(No body to read)"
        fi

        echo "────────────────────────────"
    }
    # Loop back to accept next connection
done

