#!/usr/bin/env bash

source ./steps.sh

if ! requirements_check; then exit 1; fi
if ! log_existing_dependencies; then exit 1; fi
if ! greet; then exit 1; fi

echo "<%= testName %> succeeded"
