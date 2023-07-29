#!/usr/bin/env bash

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$PACT_BROKER_TOKEN" ] && MISSING+=("PACT_BROKER_TOKEN")
[ ! "$pactfiles" ] && MISSING+=("pactfiles")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

echo """
PACT_BROKER_BASE_URL: $PACT_BROKER_BASE_URL
PACT_BROKER_TOKEN: $PACT_BROKER_TOKEN
version: $version
pactfiles: $pactfiles
branch: $branch
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
  TAG_COMMAND="--tag-with-git-branch"
fi
VERSION_COMMAND=
if [ "$version" ]; then
  echo "You set set"
  VERSION_COMMAND="--consumer-app-version $version"
else
  VERSION_COMMAND="--consumer-app-version $GITHUB_SHA"
fi

echo $TAG_WITH_BRANCH_COMMAND

docker run --rm \
  -w ${PWD} \
  -v ${PWD}:${PWD} \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  -e PACT_BROKER_TOKEN=$PACT_BROKER_TOKEN \
  -e GITHUB_HEAD_REF=$GITHUB_HEAD_REF \
  -e GITHUB_REF=$GITHUB_REF \
  -e GITHUB_SHA=$GITHUB_SHA \
  pactfoundation/pact-cli:latest \
  publish \
  $pactfiles \
  --auto-detect-version-properties \
  $VERSION_COMMAND \
  $BRANCH_COMMAND \
  $TAG_COMMAND \
  $TAG_WITH_BRANCH_COMMAND
