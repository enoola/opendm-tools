#!/bin/bash

# Define hook scripts
ENROLL_HOOK="./hook_triggered_on_Enrollment.sh"
CHECKOUT_HOOK="./hook_triggered_on_CheckOut.sh"

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
            udid=$(echo "$decoded_plist" | \
              sed -n 's/.*<key>UDID<\/key>.*<string>\([^<]*\)<\/string>.*/\1/p' | \
              head -1)
        fi

        # Fallback: extract 40-char hex string (common for UDID)
        if [[ -z "$udid" ]]; then
            udid=$(echo "$decoded_plist" | grep -oE '[a-fA-F0-9]{40}' | head -1)
        fi

        # --- Trigger appropriate hook based on topic ---
        case "$topic" in
            "mdm.Authenticate")
                echo -e "\n🚨 TRIGGERING ENROLLMENT HOOK: $ENROLL_HOOK"
                if [[ -x "$ENROLL_HOOK" ]]; then
                    echo "UDID=$udid" | "$ENROLL_HOOK" <<< "$decoded_plist"
                    echo "✅ Enrollment hook executed (UDID: $udid)"
                else
                    echo "⚠️ Hook not found or not executable: $ENROLL_HOOK"
                    echo "💡 Run: chmod +x $ENROLL_HOOK"
                fi
                ;;
            "mdm.CheckOut")
                echo -e "\n🚨 TRIGGERING CHECKOUT HOOK: $CHECKOUT_HOOK"
                if [[ -x "$CHECKOUT_HOOK" ]]; then
                    echo "UDID=$udid" | "$CHECKOUT_HOOK" <<< "$decoded_plist"
                    echo "✅ CheckOut hook executed (UDID: $udid)"
                else
                    echo "⚠️ Hook not found or not executable: $CHECKOUT_HOOK"
                    echo "💡 Run: chmod +x $CHECKOUT_HOOK"
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
done

