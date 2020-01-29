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


@test "Happy path" {
    cd "${FEATURE_FIXTURE_DIR}/helm-project"

    export HELM_CHART="${BATS_TEST_DIRNAME}/fixtures/charts/mysql"
    run make run
    status_equals 0
}

@test "Missing HELM_CHART" {
    cd "${FEATURE_FIXTURE_DIR}/helm-project"

    run make run
    output_says "Needs check indicated one or more needs were not satisfied"
    status_equals 2
}

