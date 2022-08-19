#!/usr/bin/env bash

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$PACT_BROKER_TOKEN" ] && MISSING+=("PACT_BROKER_TOKEN")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$version" ] && MISSING+=("version")
[ ! "$environment" ] && MISSING+=("environment")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

echo "
  PACT_BROKER_BASE_URL: '$PACT_BROKER_BASE_URL'
  PACT_BROKER_TOKEN: '$PACT_BROKER_TOKEN'
  application_name: '$application_name'
  version: '$version'
  environment: '$environment'"

docker run --rm \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  -e PACT_BROKER_TOKEN=$PACT_BROKER_TOKEN \
  pactfoundation/pact-cli:latest \
  broker record-deployment \
  --pacticipant "$application_name" \
  --version $version \
  --environment $environment
