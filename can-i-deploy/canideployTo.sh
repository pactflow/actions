#!/usr/bin/env bash

if [ "$version" != "" ] && [ "$latest" != "" ]; then
  echo "ERROR: specify only 'version' or 'latest', not both."
  exit 1
fi

if [ "$version" == "" ]; then
  version=$(git rev-parse HEAD)
fi
[ "$version" != "" ] && VERSION="--version $version"
[ "$latest" != "" ] && VERSION="--latest $latest"

MISSING=()
[ ! "$PACT_BROKER_BASE_URL" ] && MISSING+=("PACT_BROKER_BASE_URL")
[ ! "$application_name" ] && MISSING+=("application_name")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: The following environment variables are not set:"
  printf '\t%s\n' "${MISSING[@]}"
  exit 1
fi

COMMAND=
if [ -z "$to" ] || [ -z "$to_environment" ]; then
  if [ -z "$to" ] && [ "$to_environment" ]; then
    echo "You set to_environment"
    COMMAND="--to-environment $to_environment"
  elif [ -z "$to_environment" ] && [ "$to" ]; then
    echo "You set to"
    COMMAND="--to $to"
  else
    echo "you need to set to, or to_environment"
    exit 1
  fi
else
  echo "you can only set to, or to_environment"
  exit 1
fi

OPTIONS=()
if [ "$retry_while_unknown" ]; then
  case $retry_while_unknown in
      ''|*[!0-9]*) echo 'retry_while_unknown has to be an integer' && exit 1 ;;
      *) OPTIONS+=("--retry-while-unknown $retry_while_unknown") ;;
  esac

  if [ "$retry_interval" ]; then
    case $retry_interval in
        ''|*[!0-9]*) echo 'retry_interval has to be an integer' && exit 1 ;;
        *) OPTIONS+=("--retry-interval $retry_interval") ;;
    esac
  fi
fi

DRY_RUN_COMMAND=
if [ "$dry_run" == "true" ] || [ "$PACT_BROKER_CAN_I_DEPLOY_DRY_RUN" == "true" ]; then
  echo "You set dry run"
  DRY_RUN_COMMAND="--dry-run"
fi

MAIN_BRANCH_COMMAND=
if [ "$main_branch" == "true" ]; then
  echo "You set main-branch"
  MAIN_BRANCH_COMMAND="--main-branch"
fi

BRANCH_COMMAND=
if [ "$branch" ]; then
  echo "You set branch"
  BRANCH_COMMAND="--branch $branch"
fi

IGNORE_COMMAND=
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


echo "
  PACT_BROKER_BASE_URL: '$PACT_BROKER_BASE_URL'
  application_name: '$application_name'
  VERSION: '$VERSION'
  to: '$to'
  COMMAND: '$COMMAND'
  OPTIONS: '${OPTIONS[*]}'"

docker run --rm \
  -e PACT_BROKER_BASE_URL=$PACT_BROKER_BASE_URL \
  $PACT_BROKER_TOKEN_ENV_VAR_CMD \
  $PACT_BROKER_USERNAME_ENV_VAR_CMD \
  $PACT_BROKER_PASSWORD_ENV_VAR_CMD \
  pactfoundation/pact-cli:latest \
  broker can-i-deploy \
  --pacticipant "$application_name" \
  $VERSION \
  $COMMAND \
  $DRY_RUN_COMMAND \
  $MAIN_BRANCH_COMMAND \
  $BRANCH_COMMAND \
  ${OPTIONS[*]}
