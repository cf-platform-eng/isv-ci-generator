#!/usr/bin/env bats

load temp/test-helpers

FEATURE_FIXTURE_DIR="${BATS_TEST_DIRNAME}/temp/fixture"

setup() {
    unset GREETING_NAME

    if [[ ! -d "${FEATURE_FIXTURE_DIR}/skeleton-project" ]]; then
        run yo isv-ci skeleton-project --target-dir="${FEATURE_FIXTURE_DIR}"
        status_equals 0
    fi

}

@test "Happy path" {
    cd "${FEATURE_FIXTURE_DIR}/skeleton-project"

    export GREETING_NAME="happy"
    run make run
    output_says "Hello happy"
    status_equals 0
}

@test "Fails if GREETING_NAME not provided" {
    unset GREETING_NAME

    cd "${FEATURE_FIXTURE_DIR}/skeleton-project"

    run make run
    output_says "The requirements in needs.json were not completely met"
    status_equals 2
}
