#!/usr/bin/env bash

OAS=$(base64 $oas_file)
RESULTS=$(base64 $results_file)

# If you're here, then presumably success = true.
PAYLOAD_JSON=$(cat <<EOF
{
  "content": "$OAS",
  "contractType": "oas",
  "contentType": "application/yaml",
  "verificationResults": {
    "success": true,
    "content": "$RESULTS",
    "contentType": "text/plain",
    "verifier": "verifier"
  }
}
EOF
)
PAYLOAD=$(echo "$PAYLOAD_JSON" |tr -d '\n' | tr -d ' ')

URL="$pact_broker/contracts/provider/$participant_name/version/$version"

echo """
URL: $URL
pact_broker_token : $pact_broker_token
oas_file: $oas_file
results_file: $results_file
PAYLOAD: $PAYLOAD
"""

RESPONSE=$(curl \
  -i \
  -X PUT \
  -H "Authorization: Bearer $pact_broker_token" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" $URL)

exitCode=$?

RESPONSE_STATUS=$(echo "$RESPONSE" | awk '{print $2}' | head -1)

echo "RESPONSE: $RESPONSE"
echo "(RESPONSE_STATUS: $RESPONSE_STATUS)"

if [ $RESPONSE_STATUS -ge 300 ]
then
  exit 1
fi

exit $exitCode