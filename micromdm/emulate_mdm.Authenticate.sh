#!/bin/bash

#simple post request as when we enroll
curl -X POST http://localhost:5000 \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "User-Agent: Go-http-client/1.1" \
  -H "Accept-Encoding: gzip" \
  -d '{
    "topic": "mdm.Authenticate",
    "event_id": "a1b2c3d4-e5f6-7890-g1h2-i3j4k5l6m7n8",
    "created_at": "2025-09-07T15:20:00.000000000Z",
    "checkin_event": {
      "udid": "89sd899hkjjkjh8998sd8kkjjkjhds899",
      "url_params": null,
      "raw_payload": "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdD4KCTxrZXk+QnVpbGRWZXJzaW9uPC9rZXk+Cgk8c3RyaW5nPjIwSDM2MDwvc3RyaW5nPgoJPGtleT5JTUVJPC9rZXk+Cgk8c3RyaW5nPjM1IDYwOTYwOSA3MDYyODMgODwvc3RyaW5nPgoJPGtleT5NRUlEPC9rZXk+Cgk8c3RyaW5nPjM1NjA5NjA5NzA2MjgzPC9zdHJpbmc+Cgk8a2V5Pk1lc3NhZ2VUeXBlPC9rZXk+Cgk8c3RyaW5nPkF1dGhlbnRpY2F0ZTwvc3RyaW5nPgoJPGtleT5PU1ZlcnNpb248L2tleT4KCTxzdHJpbmc+MTYuNy4xMTwvc3RyaW5nPgoJPGtleT5Qcm9kdWN0TmFtZTwva2V5PgoJPHN0cmluZz5pUGhvbmUxMCwxPC9zdHJpbmc+Cgk8a2V5PlNlcmlhbE51bWJlcjwva2V5PgoJPHN0cmluZz5GRk1aUEExTkpDNkc8L3N0cmluZz4KCTxrZXk+VG9waWM8L2tleT4KCTxzdHJpbmc+Y29tLmFwcGxlLm1nbXQuRXh0ZXJuYWwuZTVkNjNkMWQtNzMwYi00NDA2LWExYTQtODY2NTY5MjdkMzQ2PC9zdHJpbmc+Cgk8a2V5PlVESUQ8L2tleT4KCTxzdHJpbmc+ZTdmMjBlY2MxYzk1OWVhOGZmYzZiMTJjMjkwMWUwNDU1YmI0OGI4NTwvc3RyaW5nPgo8L2RpY3Q+CjwvcGxpc3Q+Cg=="
    }
  }'

