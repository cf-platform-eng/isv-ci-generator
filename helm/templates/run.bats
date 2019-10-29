#!/usr/bin/env bats

load temp/test-helpers

# usage: create_empty_file <library-file-name>
# creates an empty file to stand in for `source ./<library-file-name>`
create_empty_file() {
  touch "${BATS_TMPDIR}/$1"
}

# usage: run_isolated_subject <full-path-to-script>
# copies the script into jail and runs it without access to library files
run_isolated_subject() {
  local subject_name

  cp "$1" "${BATS_TMPDIR}"
  cd "${BATS_TMPDIR}" || exit
  subject_name=$(basename -- "$1")
  run "./${subject_name}"
}


setup() {
    export requirements_check="$(mock_bin requirements_check)"
    export log_existing_dependencies="$(mock_bin log_existing_dependencies)"
    export init_helm="$(mock_bin init_helm)"
    export remove_helm="$(mock_bin remove_helm)"
    export install_helm_chart="$(mock_bin install_helm_chart)"
    export delete_helm_chart="$(mock_bin delete_helm_chart)"
    export PATH="${BIN_MOCKS}:${PATH}"
}

teardown() {
    clean_bin_mocks
}

@test "runs all the steps" {
    create_empty_file steps.sh

    run_isolated_subject "${BATS_TEST_DIRNAME}/run.sh"

    status_equals 0

    [ "$(mock_get_call_num "${requirements_check}")" = "1" ]
    [ "$(mock_get_call_args "${requirements_check}")" = "" ]

    [ "$(mock_get_call_num "${log_existing_dependencies}")" = "1" ]
    [ "$(mock_get_call_args "${log_existing_dependencies}")" = "" ]

    [ "$(mock_get_call_num "${init_helm}")" = "1" ]
    [ "$(mock_get_call_args "${init_helm}")" = "" ]

    [ "$(mock_get_call_num "${remove_helm}")" = "1" ]
    [ "$(mock_get_call_args "${remove_helm}")" = "" ]

    [ "$(mock_get_call_num "${install_helm_chart}")" = "1" ]
    [ "$(mock_get_call_args "${install_helm_chart}")" = "/input/helm-chart test-instance" ]

    [ "$(mock_get_call_num "${delete_helm_chart}")" = "1" ]
    [ "$(mock_get_call_args "${delete_helm_chart}")" = "test-instance" ]

    output_equals "<%= testName %> succeeded"
}
