#!/usr/bin/env bash

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$contract" ] && MISSING+=("contract")
[ ! "$verification_results" ] && MISSING+=("verification_results")

if [ "$version" == "" ]; then
  version=$(git rev-parse HEAD)
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

CONTRACT_FILE_CONTENT_TYPE=${contract_content_type:-"application/yml"}
VERIFICATION_RESULTS_CONTENT_TYPE=${verification_results_content_type:-"text/plain"}
SPECIFICATION=${specification:-"oas"}
verification_exit_code=${verification_exit_code:-0}

verifier=${verifier:-'github-actions'}
VERIFICATION_RESULTS_FORMAT=${verification_results_format:-'text'}

if [ "$branch" = "" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD)
fi

TAG_COMMAND=
if [ "$tag" ]; then
  echo "You set tag"
  TAG_COMMAND="--tag $tag"
fi

BUILD_URL_COMMAND=
if [ "$build_url" ]; then
  echo "You set build_url"
  BUILD_URL_COMMAND="--build-url $build_url"
fi

VERIFIER_VERSION_COMMAND=
if [ "$verifier_version" ]; then
  echo "You set verifier_version"
  VERIFIER_VERSION_COMMAND="--verifier-version $verifier_version"
fi


echo """
PACT_BROKER_BASE_URL: $PACT_BROKER_BASE_URL
contract: $contract
verification_results: $verification_results
verification_exit_code: $verification_exit_code
branch: $branch
build_url: $build_url
"""

docker run --rm \
  -w ${PWD} \
  -v ${PWD}:${PWD} \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  -e PACT_BROKER_TOKEN=$PACT_BROKER_TOKEN \
  pactfoundation/pact-cli:latest \
  pactflow publish-provider-contract \
  $contract \
  --provider $application_name \
  --provider-app-version $version \
  --branch $branch \
  --specification $SPECIFICATION \
  --content-type $CONTRACT_FILE_CONTENT_TYPE \
  --verification-exit-code=$verification_exit_code \
  --verification-results $verification_results \
  --verification-results-content-type $VERIFICATION_RESULTS_CONTENT_TYPE \
  --verification-results-format $VERIFICATION_RESULTS_FORMAT \
  --verifier $VERIFIER_TOOL \
  $TAG_COMMAND \
  $BUILD_URL_COMMAND \
  $VERIFIER_VERSION_COMMAND
