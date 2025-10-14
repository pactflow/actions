#!/usr/bin/env bash

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$application_name" ] && MISSING+=("application_name")
[ ! "$tag" ] && MISSING+=("tag")

if [ "$version" == "" ]; then
  version=$(git rev-parse HEAD)
fi
if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

PACT_CLI_IMAGE_TAG=${pact_cli_image_tag:-"latest"}

PACT_CLI_IMAGE=
if [ "$pact_cli_image" ]; then
    echo "INFO: using user-specified CLI image: ${pact_cli_image}:${PACT_CLI_IMAGE_TAG}"
    PACT_CLI_IMAGE="${pact_cli_image}:${PACT_CLI_IMAGE_TAG}"
else
    PACT_CLI_IMAGE="pactfoundation/pact-cli:${PACT_CLI_IMAGE_TAG}"
fi

AUTO_CREATE_VERSION_COMMAND=
if [ "$auto_create_version" ]; then
  echo "You set auto_create_version"
  AUTO_CREATE_VERSION_COMMAND="--auto-create-version"
fi


TAG_WITH_GIT_BRANCH_COMMAND=
if [ "$tag_with_git_branch" ]; then
  echo "You set ignore"
  TAG_WITH_GIT_BRANCH_COMMAND="--tag-with-git-branch"
fi


echo """
PACT_BROKER_BASE_URL: $PACT_BROKER_BASE_URL
pact_cli_image: $pact_cli_image
application_name: $application_name
version: $version
tag: $tag
"""


if [ "$PACT_BROKER_TOKEN" ]; then
  echo "You set token"
  PACT_BROKER_TOKEN_ENV_VAR_CMD="-e PACT_BROKER_TOKEN=$PACT_BROKER_TOKEN"
fi

if [ "$PACT_BROKER_USERNAME" ]; then
  echo "You set username"
  PACT_BROKER_USERNAME_ENV_VAR_CMD="-e PACT_BROKER_USERNAME=$PACT_BROKER_USERNAME"
fi

if [ "$PACT_BROKER_PASSWORD" ]; then
  echo "You set password"
  PACT_BROKER_PASSWORD_ENV_VAR_CMD="-e PACT_BROKER_PASSWORD=$PACT_BROKER_PASSWORD"
fi

pact-broker-cli \
  create-version-tag \
  --pacticipant "$application_name" \
  --version "$version" \
  --tag "$tag" \
  $AUTO_CREATE_VERSION_COMMAND \
  $TAG_WITH_GIT_BRANCH_COMMAND

