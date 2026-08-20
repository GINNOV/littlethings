#!/bin/bash

# STEP ONE - execute a command and catch its output
output=$(ls .)

stringToSearch="json"

# grep the output for the selected word(s)
if echo "$output" | grep -q "$stringToSearch"; then
	PURPLE='\033[0;35m'
	NC='\033[0m' # No Color
	echo -e "${PURPLE} FOUND IT! ${NC}\n"
  # execute here something nice :-)
fi
