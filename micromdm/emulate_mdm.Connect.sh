#!/bin/bash

curl -X POST http://localhost:5000 \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "mdm.Connect",
    "acknowledge_event": {
      "raw_payload": "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdD4KCTxrZXk+Q29tbWFuZFVVSUQ8L2tleT4KCTxzdHJpbmc+NjMxOTk1N2UtZDQ0Yy00M2QzLWE1YWQtYjYwOWRkY2EyYjkyPC9zdHJpbmc+CjwvZGljdD4KPC9wbGlzdD4K"
    }
  }'
echo "done with POST."
