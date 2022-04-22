#!/usr/bin/env bash
# Using 'bash' to mock 'curl' so it doesn't execute during test.

COMMAND=${1:?"Syntax $0 <command>"}
RESPONSE_STATUS=${2:-"200"}

shopt -s expand_aliases

alias curl="echo response: $RESPONSE_STATUS curl"

source $COMMAND
