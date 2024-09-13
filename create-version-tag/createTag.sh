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

docker run --rm \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  $PACT_BROKER_TOKEN_ENV_VAR_CMD \
  $PACT_BROKER_USERNAME_ENV_VAR_CMD \
  $PACT_BROKER_PASSWORD_ENV_VAR_CMD \
  -e GITHUB_HEAD_REF=$GITHUB_HEAD_REF \
  -e GITHUB_BASE_REF=$GITHUB_BASE_REF \
  -e GITHUB_REF=$GITHUB_REF \
  -e GITHUB_SHA=$GITHUB_SHA \
  pactfoundation/pact-cli:latest \
  broker create-version-tag \
  --pacticipant "$application_name" \
  --version "$version" \
  --tag "$tag" \
  $AUTO_CREATE_VERSION_COMMAND \
  $TAG_WITH_GIT_BRANCH_COMMAND

