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

@test "test_is_owned_by_user" {
    user=$(whoami)
    file="$BATS_TEST_TMPDIR/test_is_owned_by_user"
    touch "$file"
    run fs::is_owned_by_user "$file" "$user"
    assert_success

    run fs::is_owned_by_user "$file" "non_existent_user"
    assert_failure
}

@test "test_ensure_file_exists" {
    file="$BATS_TEST_TMPDIR/test_ensure_file_exists"
    touch "$file"
    run fs::ensure_file_exists "$file"
    assert_success


    reassure=true run_stripped fs::ensure_file_exists "$file"
    assert_success
    assert_output "✔ File $file exists"

    run rm "$file"
    assert_success

    run fs::ensure_file_exists "$file"
    assert_failure
}

@test "test_ensure_dir_exists" {
    dir="$BATS_TEST_TMPDIR/test_ensure_dir_exists"
    mkdir "$dir"
    run fs::ensure_dir_exists "$dir"
    assert_success

    reassure=true run_stripped fs::ensure_dir_exists "$dir"
    assert_success
    assert_output "✔ Directory $dir exists"

    run rm -r "$dir"
    assert_success

    run fs::ensure_dir_exists "$dir"
    assert_failure
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