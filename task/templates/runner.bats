load temp/bats-mock # docs at https://github.com/grayhemp/bats-mock

setup() {
    export BATS_TMPDIR
    mkdir -p "$BATS_TMPDIR/bin"

    export mock_needs="$(mock_create)"
    ln -sf "${mock_needs}" "${BATS_TMPDIR}/bin/needs"

    chmod a+x "$BATS_TMPDIR/bin"/*
    export PATH="$BATS_TMPDIR/bin:${PATH}"
}

teardown() {
    rm -rf "$BATS_TMPDIR/bin"
}

@test "run fails if the needs check fails" {
    mock_set_status "${mock_needs}" 1
    run ./runner.sh
    [ "$status" -eq 1 ]
}

@test "run passes" {
    run ./runner.sh
    [ "$status" -eq 0 ]
}