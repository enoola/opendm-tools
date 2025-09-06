
#!/bin/bash

nc -l 5000 -k | while true; do
    content_length=0
    line=""

    # Read headers until \r\n\r\n
    while IFS= read -r line; do
        # Remove trailing \r
        header=$(echo "$line" | tr -d '\r')

        # Print header for debugging
        [[ -n "$header" ]] && echo "$header"

        # Extract Content-Length (after removing \r)
        if [[ "$header" =~ ^Content-Length:[[:space:]]*([0-9]+) ]]; then
            content_length="${BASH_REMATCH[1]}"
        fi

        # Break at empty line (end of headers)
        [[ -z "$header" ]] && break
    done

    # Read exactly 'content_length' bytes if available
    if [[ $content_length -gt 0 ]]; then
        body=$(head -c "$content_length")

        echo "=== JSON Body ==="

echo "$body" | \
  jq -r '.checkin_event.raw_payload' | \
  tr -d ' \t\n\r' | \
  base64 -d 2>/dev/null || echo "(Decoding failed)"

        #echo "$body"

        echo -e "\n=== DECODED raw_payload ==="
        #echo "$body" | jq -r '.acknowledge_event.raw_payload' | base64 -d 2>/dev/null || echo "(Decoding failed)"
        echo "============================"
    else
        echo "(No Content-Length found or zero)"
    fi

    echo  # separator
done
