#!/usr/bin/env bash

# NOTE: You must ensure additionalProperties in your OAS is set to false on any 
#       response body, to ensure a consumer won't get false positives if they add
#       a new field that isn't actually part of the spec.
echo """
PACT_BROKER: $PACT_BROKER
PACT_BROKER_TOKEN : $PACT_BROKER_TOKEN
participant_name: $participant_name
version: $version
oas_file: $oas_file
resuts_file: $resuts_file
"""

OAS=$(base64 $OASFILE)
RESULTS=$(base64 $RESULTSFILE)

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

URL="$PACT_BROKER/contracts/provider/$participant_name/version/$VERSION"

RESPONSE=$(curl \
  -i \
  -X PUT \
  -H "Authorization: Bearer $PACT_BROKER_TOKEN" \
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