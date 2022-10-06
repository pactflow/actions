#!/usr/bin/env bash

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$PACT_BROKER_TOKEN" ] && MISSING+=("PACT_BROKER_TOKEN")
[ ! "$version" ] && MISSING+=("version")
[ ! "$pactfiles" ] && MISSING+=("pactfiles")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)

echo """
PACT_BROKER_BASE_URL: $PACT_BROKER_BASE_URL
PACT_BROKER_TOKEN: $PACT_BROKER_TOKEN
version: $version
pactfiles: $pactfiles
branch: $branch
"""

docker run --rm \
  -w ${PWD} \
  -v ${PWD}:${PWD} \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  -e PACT_BROKER_TOKEN=$PACT_BROKER_TOKEN \
  pactfoundation/pact-cli:latest \
  publish \
  $pactfiles \
  --consumer-app-version $version \
  --branch $branch
