#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
  echo -e "You must source this script\nsource ${0}" && \
  exit 1

function show_image_dependencies() {
  mrlog section --name="show image dependencies" -- cat /root/dependencies.log
}

function check_needs() {
  mrlog section --name="check needs" \
    --on-failure="Needs check indicated one or more needs were not satisfied" \
    --on-success="Needs check successfully found all the requirements for this test" \
    -- needs check
}

function greet {
  mrlog section-start --name greet
  echo "Hello ${GREETING_NAME}"
  mrlog section-end --name greet --result=0
}