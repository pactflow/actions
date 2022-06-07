#!/usr/bin/env bash

MISSING=()
[ ! "$pact_broker" ] && MISSING+=("pact_broker")
[ ! "$pact_broker_token" ] && MISSING+=("pact_broker_token")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$version" ] && MISSING+=("version")
[ ! "$oas_file" ] && MISSING+=("oas_file")
[ ! "$results_file" ] && MISSING+=("results_file")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

EXIT_CODE=0
REPORT_FILE_CONTENT_TYPE=${REPORT_FILE_CONTENT_TYPE:-'text/plain'}
VERIFIER_TOOL=${VERIFIER_TOOL:-'github-actions'}
BRANCH=${GITHUB_REF#refs/heads/}

echo """
URL: $URL
pact_broker_token : $pact_broker_token
oas_file: $oas_file
results_file: $results_file
EXIT_CODE: $EXIT_CODE
BRANCH: $BRANCH
"""

docker run --rm \
  -w ${PWD} \
  -v ${PWD}:${PWD} \
  -e PACT_BROKER_BASE_URL=$pact_broker \
  -e PACT_BROKER_TOKEN=$pact_broker_token \
  pactfoundation/pact-cli:latest \
  pactflow publish-provider-contract \
  $oas_file \
  --provider $application_name \
  --provider-app-version $version \
  --branch $BRANCH \
  --content-type application/yaml \
  --verification-exit-code=$EXIT_CODE \
  --verification-results $results_file \
  --verification-results-content-type $REPORT_FILE_CONTENT_TYPE \
  --verifier $VERIFIER_TOOL
