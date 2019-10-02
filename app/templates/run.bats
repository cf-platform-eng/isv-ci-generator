#!/usr/bin/env bats
#load temp/test-helpers
#
#setup() {
#    # Common mocks
#    # export mock_mrlog="$(mock_bin mrlog)"
#    # export mock_tileinspect="$(mock_bin tileinspect)"
#    export mock_needs="$(mock_bin needs)"
#    export PATH="${BIN_MOCKS}:${PATH}"
#}
#
#teardown() {
#    clean_bin_mocks
#}
#
#@test "run fails if the needs check fails" {
#    mock_set_status "${mock_needs}" 1
#
#    run ${BATS_TEST_DIRNAME}/run.sh
#
#    status_equals 1
#    [ "$(mock_get_call_num "${mock_needs}")" = "1" ]
#    output_equals "Needs check indicated that the test is not ready to execute"
#}
#
#@test "run passes" {
#    mock_set_status "${mock_needs}" 0
#
#    run ${BATS_TEST_DIRNAME}/run.sh
#
#    status_equals 0
#    output_equals "my-test succeeded"
#}