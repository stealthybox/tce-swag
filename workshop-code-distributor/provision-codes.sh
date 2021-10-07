#!/usr/bin/env bash

i=1

for code in $(cat swag-codes); do

cat <<EOF
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: code-${i}
  labels:
    swag_code: "true"
    workshop_session: none
data:
  code: ${code}
EOF

(( i=i+1 ))

done
