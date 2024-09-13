#!/usr/bin/env bash

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$pactfiles" ] && MISSING+=("pactfiles")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

build_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

echo """
PACT_BROKER_BASE_URL: $PACT_BROKER_BASE_URL
version: $version
pactfiles: $pactfiles
branch: $branch
build_url: $build_url
tag: $tag
"""

BRANCH_COMMAND=
if [ "$branch" ]; then
  echo "You set branch"
  BRANCH_COMMAND="--branch $branch"
fi
TAG_COMMAND=
if [ "$tag" ]; then
  echo "You set tag"
  TAG_COMMAND="--tag $tag"
fi
TAG_WITH_BRANCH_COMMAND=
if [ "$tag_with_git_branch" ]; then
  echo "You set tag_with_git_branch"
  TAG_WITH_BRANCH_COMMAND="--tag-with-git-branch"
fi
VERSION_COMMAND=
if [ "$version" ]; then
  echo "You set set"
  VERSION_COMMAND="--consumer-app-version $version"
else
  VERSION_COMMAND="--consumer-app-version $GITHUB_SHA"
fi

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
  -w ${PWD} \
  -v ${PWD}:${PWD} \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  $PACT_BROKER_TOKEN_ENV_VAR_CMD \
  $PACT_BROKER_USERNAME_ENV_VAR_CMD \
  $PACT_BROKER_PASSWORD_ENV_VAR_CMD \
  -e GITHUB_HEAD_REF=$GITHUB_HEAD_REF \
  -e GITHUB_BASE_REF=$GITHUB_BASE_REF \
  -e GITHUB_REF=$GITHUB_REF \
  -e GITHUB_SHA=$GITHUB_SHA \
  pactfoundation/pact-cli:latest \
  publish \
  $pactfiles \
  --auto-detect-version-properties \
  --build-url $build_url \
  $VERSION_COMMAND \
  $BRANCH_COMMAND \
  $TAG_COMMAND \
  $TAG_WITH_BRANCH_COMMAND
