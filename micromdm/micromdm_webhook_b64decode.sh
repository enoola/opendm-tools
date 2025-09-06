#!/bin/bash

nc -l 5000 -k | while true; do
    content_length=0
    line=""

    # Read headers
    while IFS= read -r line; do
        header=$(echo "$line" | tr -d '\r')

        [[ -n "$header" ]] && echo "$header"

        if [[ "$header" =~ ^Content-Length:[[:space:]]*([0-9]+) ]]; then
            content_length="${BASH_REMATCH[1]}"
        fi

        [[ -z "$header" ]] && break
    done

    # Read body
    if [[ $content_length -gt 0 ]]; then
        body=$(head -c "$content_length")

        echo "=== JSON Body ==="
        echo "$body"

        echo -e "\n=== DECODED raw_payload ==="
        echo "$body" | \
          jq -r '.checkin_event.raw_payload // .acknowledge_event.raw_payload' | \
          tr -d ' \t\n\r' | \
          base64 -d 2>/dev/null || echo "(Decoding failed)"
        echo "============================"
    else
        echo "(No body to read)"
    fi

    echo
done
