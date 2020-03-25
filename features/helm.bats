#!/usr/bin/env bats

load temp/test-helpers

FEATURE_FIXTURE_DIR="${BATS_TEST_DIRNAME}/temp/fixture"

setup() {
    unset HELM_CHART

    if [[ ! -d "${FEATURE_FIXTURE_DIR}/helm-project" ]]; then
        run yo isv-ci:helm helm-project --target-dir="${FEATURE_FIXTURE_DIR}"
        status_equals 0
    fi
}

teardown() {
    if [[ "${PRINT_LOGS}" == "true" ]] ; then
        becho "Printing log file..."
        cat ${FEATURE_FIXTURE_DIR}/helm-project/logs/*.log >&3
    fi
}

@test "Missing HELM_CHART" {
    cd "${FEATURE_FIXTURE_DIR}/helm-project"

    run make run
    output_says "HELM_CHART not defined. Set this with the full path to your 'helm install'able chart"
    status_equals 2
}

@test "Happy path" {
    cd "${FEATURE_FIXTURE_DIR}/helm-project"

    export HELM_CHART="${BATS_TEST_DIRNAME}/fixtures/charts/mysql"
    run make run
    status_equals 0
}
