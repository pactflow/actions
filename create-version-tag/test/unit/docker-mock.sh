#!/usr/bin/env bash
# Using 'bash' to mock 'docker' so it doesn't execute during test.

COMMAND=${1:?"Syntax $0 <command>"}
shopt -s expand_aliases
alias docker="echo docker"
source $COMMAND
