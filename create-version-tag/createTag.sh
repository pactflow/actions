#!/usr/bin/env bash

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$PACT_BROKER_TOKEN" ] && MISSING+=("PACT_BROKER_TOKEN")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$version" ] && MISSING+=("version")
[ ! "$tag" ] && MISSING+=("tag")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

echo """
PACT_BROKER_BASE_URL: $PACT_BROKER_BASE_URL
PACT_BROKER_TOKEN: $PACT_BROKER_TOKEN
application_name: $application_name
version: $version
tag: $tag
"""

docker run --rm \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  -e PACT_BROKER_TOKEN=$PACT_BROKER_TOKEN \
  pactfoundation/pact-cli:latest \
  broker create-version-tag \
  --pacticipant "$application_name" \
  --version "$version" \
  --tag "$tag"
