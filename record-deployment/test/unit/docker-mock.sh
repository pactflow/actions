#!/usr/bin/env bash
# Using 'bash' to mock 'docker' so it doesn't execute during test.

echo ">>>> 0.1"
COMMAND=${1:?"Syntax $0 <command>"}
echo ">>>> 0.2"
shopt -s expand_aliases
echo ">>>> 0.3"
alias docker="echo docker"
echo ">>>> 0.4"
source $COMMAND
