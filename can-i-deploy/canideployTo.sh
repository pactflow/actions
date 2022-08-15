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

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

COMMAND=
if [ -z "$to" ] || [ -z "$to_env" ]; then
    if [ -z "$to" ] && [ "$to_env" ]; then
        echo "You set to_env"
        COMMAND="--to-env $to_env"
    elif [ -z "$to_env" ] && [ "$to" ]; then
        echo "You set to"
        COMMAND="--to $to"
    else
        echo "you need to set to, or to_env"
        exit 1
    fi
else
    echo "you can only set to, or to_env"
    exit 1
fi

echo $COMMAND

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
  $COMMAND
