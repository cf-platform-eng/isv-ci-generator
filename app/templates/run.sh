#!/usr/bin/env bash

source ./steps.sh

if ! needs_check; then exit 1 ; fi

echo "<%= appName %> succeeded"