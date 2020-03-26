#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
  echo -e "You must source this script\nsource ${0}" && \
  exit 1

function check_needs {
  mrlog section \
    --name "check needs" \
    --on-failure "Needs check indicated one or more needs were not satisfied" \
    --on-success "Needs check successfully found all the requirements for this test" \
    -- needs check
}

function show_image_dependencies {
  mrlog section \
    --name "show image dependencies" \
    -- cat /root/dependencies.log
}

#function init_helm {
#  mrlog section-start --name "initialize helm"
#
#  kubectl create serviceaccount tiller -n kube-system && \
#  kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller && \
#  helm init --service-account=tiller --wait && \
#  kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
#  result=$?
#  if [[ $result -eq 0 ]] ; then
#    echo "Helm initialized!"
#  else
#    echo "Failed to initialize helm."
#  fi
#
#  mrlog section-end --name "initialize helm" --result=$result
#  return $result
#}

#function remove_helm {
#  mrlog section-start --name "remove helm"
#
#  kubectl delete deployment tiller-deploy -n kube-system && \
#  kubectl delete clusterrolebinding tiller && \
#  kubectl delete serviceaccount tiller -n kube-system
#  result=$?
#  if [[ $result -eq 0 ]] ; then
#    echo "Helm removed!"
#  else
#    echo "Failed to remove helm."
#  fi
#
#  mrlog section-end --name "remove helm" --result=0
#  return $result
#}

function install_helm_chart {
  mrlog section \
    --name "Install helm chart" \
    --on-success "Helm chart '$1' installed!" \
    --on-failure "Failed to install helm chart '$1'" \
    -- helm install "$1" "$2"
}

function delete_helm_chart {
  mrlog section \
    --name "Delete helm chart" \
    --on-success "Helm chart instance '$1' deleted!" \
    --on-failure "Failed to delete helm chart instance '$1'" \
    -- helm delete "$1"
}