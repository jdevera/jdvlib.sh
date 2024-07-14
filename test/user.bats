#!/usr/bin/env bats

setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import user
    PATH="$BATS_TEST_DIRNAME/scripts:$PATH"
}

teardown() {
    # executed after each test
    :
}


@test "test_user_is_root" {
    skip_unless_docker_container
    run user::is_root
    assert_success
}
