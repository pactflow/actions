#!/usr/bin/env bash

if [ "$version" != "" ] && [ "$latest" != "" ]; then
  echo "ERROR: specify only 'version' or 'latest', not both."
  exit 1
fi

VERSION="--latest"
[ "$version" != "" ] && VERSION="--version $version"
[ "$latest" != "" ] && VERSION="--latest $latest"

MISSING=()
[ ! "$pact_broker" ] && MISSING+=("pact_broker")
[ ! "$pact_broker_token" ] && MISSING+=("pact_broker_token")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$to" ] && MISSING+=("to")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

echo "
  pact_broker: '$pact_broker'
  pact_broker_token: '$pact_broker_token'
  application_name: '$application_name'
  VERSION: '$VERSION'
  to: $to"

docker run --rm \
  -e PACT_BROKER_BASE_URL=$pact_broker \
  -e PACT_BROKER_TOKEN=$pact_broker_token \
  pactfoundation/pact-cli:latest \
  broker can-i-deploy \
  --pacticipant "$application_name" \
  $VERSION \
  --to $to
