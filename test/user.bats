#!/usr/bin/env bats

setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import user
    PATH="$BATS_TEST_DIRNAME/scripts:$PATH"
}

teardown() {
    # executed after each test
    _run_teardown_functions
}


@test "test_user_is_root" {
    skip_unless_root
    run user::is_root
    assert_success
}

@test "test_ensure_root" {
    skip_unless_root
    run user::ensure_root
    assert_success
    assert_output ""
}

@test "test_ensure_root_reassured" {
    skip_unless_root
    reassure=true run_stripped user::ensure_root
    assert_success
    assert_output "✔ Running as root"
}

@test "test_user_exists" {
    skip_unless_root
    run user::exists root
    assert_success

    run user::exists non_existent_user
    assert_failure
}

@test "test_ensure_exists" {
    skip_unless_root
    run user::ensure_exists root
    assert_success
    assert_output ""

    run_stripped user::ensure_exists non_existent_user
    assert_failure
    assert_output "✗ User non_existent_user does not exist"
}

@test "test_group_exists" {
    skip_unless_root
    run user::group_exists root
    assert_success

    run user::group_exists non_existent_group
    assert_failure

    # create the group
    groupadd non_existent_group
    register_teardown "groupdel non_existent_group"
    run user::group_exists non_existent_group
    assert_success
}

@test "test_is_in_group" {
    skip_unless_root
    run user::is_in_group root root
    assert_success

    run user::is_in_group root non_existent_group
    assert_failure

    groupadd non_existent_group
    register_teardown "groupdel non_existent_group"
    # add root to this group:
    usermod -aG non_existent_group root
    register_teardown "gpasswd -d root non_existent_group"

    run user::is_in_group root non_existent_group
    assert_success
}

@test "test_add_to_groups" {
    skip_unless_root
    group="test_group"

    groupadd $group
    register_teardown "groupdel $group"

    run user::is_in_group root $group
    assert_failure

    run user::add_to_groups root $group
    assert_success

    run user::is_in_group root $group
    assert_success
}

@test "test_create_user" {
    skip_unless_root

    user="test_user"
    run user::exists $user
    assert_failure

    run user::create $user
    assert_success
    register_teardown "userdel -f $user"

    run user::exists $user
    assert_success
}