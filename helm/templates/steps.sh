#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
  echo -e "You must source this script\nsource ${0}" && \
  exit 1

function requirements_check {
  mrlog section-start --name "requirements check"

  needs check
  result=$?

  if [[ $result -eq 0 ]] ; then
    echo "The requirements in needs.json were met"
  else
    echo "The requirements in needs.json were not completely met"
  fi

  mrlog section-end --name "requirements check" --result=1

  return $result
}

function log_existing_dependencies {
  mrlog section-start --name "log existing dependencies"

  cat "${DEPENDENCIES_FILE}"
  result=$?

  mrlog section-end --name "log existing dependencies" --result=0
  return $result
}

function init_helm {
  mrlog section-start --name "initialize helm"

  helm init
  result=$?
  if [[ $result -eq 0 ]] ; then
    echo "Helm initialized!"
  else
    echo "Failed to initialize helm."
  fi

  mrlog section-end --name "initialize helm" --result=0
  return $result
}

function remove_helm {
  mrlog section-start --name "remove helm"

  kubectl delete deployment tiller-deploy -n kube-system 
  result=$?
  if [[ $result -eq 0 ]] ; then
    echo "Helm removed!"
  else
    echo "Failed to remove helm."
  fi

  mrlog section-end --name "remove helm" --result=0
  return $result

}
