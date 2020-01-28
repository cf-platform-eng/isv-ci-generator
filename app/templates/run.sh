#!/usr/bin/env bash

source ./steps.sh

check_needs             || exit 1
show_image_dependencies || exit 1
greet                   || exit 1

echo "<%= testName %> succeeded"
