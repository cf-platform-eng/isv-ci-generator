#!/usr/bin/env bash

source ./steps.sh

if ! requirements_check; then exit 1; fi
if ! log_existing_dependencies; then exit 1; fi
if ! init_helm; then exit; fi
if ! install_helm_chart /input/helm-chart test-instance; then exit; fi

# The helm chart is now installed with the instance named 'test-instance'
# Add your test steps here.

if ! delete_helm_chart test-instance; then exit; fi
if ! remove_helm; then exit; fi

echo "<%= testName %> succeeded"
