#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
  echo -e "You must source this script\nsource ${0}" && \
  exit 1

function needs_check {
    mrlog section-start --name="checking test needs" # todo "input requirements" ?

    needs check
    result=$?
    mrlog section-end --name="checking test needs" --result=${result}

    if [[ $result -ne 0 ]] ; then
        echo "Needs check indicated that the test is not ready to execute" >&2
    fi
    return $result
}
