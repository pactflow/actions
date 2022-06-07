#!/usr/bin/env bash

MISSING=()
[ ! "$pact_broker" ] && MISSING+=( "pact_broker" )
[ ! "$pact_broker_token" ] && MISSING+=( "pact_broker_token" )
[ ! "$application_name" ] && MISSING+=( "application_name" )
[ ! "$version" ] && MISSING+=( "version" )
[ ! "$pactfiles" ] && MISSING+=( "pactfiles" )

if [ ${#MISSING[@]} -gt 0 ]
then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

echo """
pact_broker: $pact_broker
pact_broker_token: $pact_broker_token
application_name: $application_name
version: $version
pactfiles: $pactfiles
"""

docker run --rm \
 -w ${PWD} \
 -v ${PWD}:${PWD} \
 -e PACT_BROKER_BASE_URL=$pact_broker \
 -e PACT_BROKER_TOKEN=$pact_broker_token \
  pactfoundation/pact-cli:latest \
  publish \
  $pactfiles \
  --consumer-app-version $version