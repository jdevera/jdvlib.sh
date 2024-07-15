#!/usr/bin/env bats

setup() {
    # shellcheck source=./test_helper/common_setup.bash
    load 'test_helper/common_setup'
    _common_setup
    # shellcheck source=./../lib/fs.sh
    meta::import fs
}

teardown() {
    # executed after each test
    _run_teardown_functions
}

@test "test_can_user_write_to_dir" {
    skip_unless_docker_container

    user_name='test_writer'

    # shellcheck source=./../lib/user.sh
    meta::import user

    user::create "$user_name"
    register_teardown "userdel $user_name"
    run user::exists "$user_name"
    assert_success

    dir="$(mktemp -d "/tmp/test_dir.XXXXXX")"
    register_teardown "rm -r $dir"
    chmod 700 "$dir"
    run fs::can_user_write_to_dir "$user_name" "$dir"
    assert_failure

    chown "$user_name" "$dir"
    run fs::can_user_write_to_dir "$user_name" "$dir"
    assert_success

}
