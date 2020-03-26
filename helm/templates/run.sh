#!/usr/bin/env bash

source ./steps.sh

if ! show_image_dependencies                           ; then exit 1; fi
if ! check_needs                                       ; then exit 1; fi
if ! install_helm_chart test-instance /input/helm-chart; then exit 1; fi

# The helm chart is now installed with the instance named 'test-instance'
# Add your test steps here.

if ! delete_helm_chart test-instance; then exit 1; fi

echo "<%= testName %> succeeded"
