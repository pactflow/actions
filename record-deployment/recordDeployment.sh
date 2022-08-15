#!/usr/bin/env bash

MISSING=()
[ ! "$pact_broker" ] && MISSING+=("pact_broker")
[ ! "$pact_broker_token" ] && MISSING+=("pact_broker_token")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$version" ] && MISSING+=("version")
[ ! "$environment" ] && MISSING+=("environment")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

echo "
  pact_broker: '$pact_broker'
  pact_broker_token: '$pact_broker_token'
  application_name: '$application_name'
  version: '$version'
  environment: '$environment'"

docker run --rm \
  -e PACT_BROKER_BASE_URL=$pact_broker \
  -e PACT_BROKER_TOKEN=$pact_broker_token \
  pactfoundation/pact-cli:latest \
  broker record-deployment \
  --pacticipant "$application_name" \
  --version $version \
  --environment $environment
