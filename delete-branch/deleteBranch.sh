#!/usr/bin/env bash


MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$PACT_BROKER_TOKEN" ] && MISSING+=("PACT_BROKER_TOKEN")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$branch" ] && MISSING+=("branch")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

OPTIONS=
if [ -z "${error_when_not_found}" ]; then
  if [ "${error_when_not_found}" = "true" ]; then
    OPTIONS="--error-when-not-found"
  elif [ "${error_when_not_found}" = "false" ]; then
    OPTIONS="--no-error-when-not-found"
  else
    echo "error_when_not_found was expected to be either 'true' or 'false' but was '${error_when_not_found}'"
    exit 1
  fi
fi

echo "
  PACT_BROKER_BASE_URL: '$PACT_BROKER_BASE_URL'
  PACT_BROKER_TOKEN: '$PACT_BROKER_TOKEN'
  application_name: '$application_name'
  branch: '$branch'
  error_when_not_found: $error_when_not_found"

docker run --rm \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  -e PACT_BROKER_TOKEN=$PACT_BROKER_TOKEN \
  pactfoundation/pact-cli:latest \
  broker delete-branch \
  --pacticipant "$application_name" \
  --branch "$branch" \
  $OPTIONS \
