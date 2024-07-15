#!/usr/bin/env bats

setup() {
    # shellcheck source=./test_helper/common_setup.bash
    load 'test_helper/common_setup'
    _common_setup
    # shellcheck source=./../lib/sys.sh
    meta::import sys
    # shellcheck source=./../lib/user.sh
    meta::import user
}

teardown() {
    # executed after each test
    _run_teardown_functions
}

@test "test_has_command" {
    run sys::has_command "bash"
    assert_success

    run sys::has_command probably_not
    assert_failure
}

@test "test_ensure_has_commands" {
    run sys::ensure_has_commands bash ls
    assert_success

    run_stripped sys::ensure_has_commands \
        bash \
        probably_not \
        ls \
        not_this_one_either
    assert_failure
    assert_output "✗ These commands are required but not found: probably_not not_this_one_either"
}

backup_path() {
    declare -g old_path=$PATH
    # shellcheck disable=SC2317 # This will be called dynamically
    restore_path() { export PATH=$old_path; }
    register_teardown restore_path
}

@test "test_is_in_path" {
    run sys::is_in_path "/tmp/_probably_not"
    assert_failure

    run sys::is_in_path probably_not
    assert_failure

    backup_path
    # shellcheck disable=SC2030 # It's okay for this modification to be local
    export PATH="/tmp/well_yes:/tmp/this_too:$PATH:/tmp/and_this"

    run sys::is_in_path /tmp/well_yes
    assert_success
    run sys::is_in_path /tmp/this_too
    assert_success
    run sys::is_in_path /tmp/and_this
    assert_success
}

@test "test_ensure_in_path" {
    backup_path

    # shellcheck disable=SC2030 disable=SC2031 # It's okay for this modification to be local
    export PATH="/tmp/well_yes:/tmp/this_too:$PATH:/tmp/and_this"
    test_ensure_function sys::ensure_in_path \
        --failure \
            "The directory /tmp/not_really is not in the PATH" \
            /tmp/not_really \
        --success \
            "The directory /tmp/well_yes is in the PATH" \
            /tmp/well_yes
}

@test "test_is_debian" {
    skip_unless_root

    if [[ -f /etc/debian_version ]]; then
        mv /etc/debian_version /etc/debian_version.bak
        register_teardown "mv /etc/debian_version.bak /etc/debian_version"
    fi

    run sys::is_debian
    assert_failure

    touch /etc/debian_version
    register_teardown "rm /etc/debian_version"

    run sys::is_debian
    assert_success
}

@test "test_ensure_debian" {
    skip_unless_root

    if [[ -f /etc/debian_version ]]; then
        mv /etc/debian_version /etc/debian_version.bak
        register_teardown "mv /etc/debian_version.bak /etc/debian_version"
    fi

    test_ensure_function sys::ensure_debian \
        --failure \
            "This is intended to run on a Debian-based system" \

    touch /etc/debian_version
    register_teardown "rm /etc/debian_version"

    test_ensure_function sys::ensure_debian \
        --success \
            "This is a Debian-based system"

}


fake_uname() {
    local answer=
    local error=
    if [[ $1 == -m ]]; then
        [[ -n $__test_uname_m_answer ]] || error="No answer for uname -m"
        answer=$__test_uname_m_answer
    elif [[ $1 == -s ]]; then
        [[ -n $__test_uname_s_answer ]] || error="No answer for uname -s"
        answer=$__test_uname_s_answer
    fi
    if [[ -n $error ]]; then
        log_mock_call uname "DEATH: $error" "$@"
        ui::die "$error"
    fi
    log_mock_call uname "$answer" "$@"
    echo "$answer"
}

@test "test get arch" {

    # shellcheck disable=SC2317 # This is mocking the command
    uname() {
        fake_uname "$@"
    }
    export -f uname
    register_teardown "unset -f uname"

    log_step "Linux amd64"
    # shellcheck disable=SC2031,SC2030 # It's okay to be changed within the test subshell
    export __test_uname_m_answer=''
    # shellcheck disable=SC2031,SC2030 # It's okay to be changed within the test subshell
    export __test_uname_s_answer=Linux

    # shellcheck disable=SC2317 # This is mocking the command
    dpkg() {
        log_mock_call dpkg "amd64" "$@"
        echo amd64
    }
    export -f dpkg
    register_teardown "unset -f dpkg"

    run sys::get_arch
    assert_success
    assert_output "amd64"


    log_step "MacOS arm64"

    export __test_uname_s_answer=Darwin
    export __test_uname_m_answer=arm64
    dpkg() {
        ui::die "Should not call dpkg"
    }
    export -f dpkg

    run sys::get_arch
    assert_success
    assert_output "arm64"


    log_step "PotatOS"
    export __test_uname_s_answer=PotatOS
    export __test_uname_m_answer=''
    run sys::get_arch
    assert_death "Unsupported OS: PotatOS"
}

@test "test_get_os" {

    # shellcheck disable=SC2031,SC2030 # It's okay to be changed within the test subshell
    export __test_uname_s_answer=''

    # shellcheck disable=SC2317 # This is mocking the command
    uname() {
        __test_uname_m_answer='' \
        __test_uname_s_answer="$__test_uname_s_answer" \
            fake_uname "$@"

    }
    export -f uname
    register_teardown "unset -f uname"

    export __test_uname_s_answer=Linux
    run sys::get_os
    assert_success
    assert_output "linux"

    export __test_uname_s_answer=Darwin
    run sys::get_os
    assert_success
    assert_output "darwin"

    export __test_uname_s_answer=PotatOS
    run sys::get_os
    assert_death "Unsupported OS: PotatOS"
}

@test "test_is_linux" {

    # shellcheck disable=SC2031,SC2030 # It's okay to be changed within the test subshell
    export __test_uname_m_answer=''

    # shellcheck disable=SC2317 # This is mocking the command
    uname() {
        fake_uname "$@"
    }
    export -f uname
    register_teardown "unset -f uname"

    # shellcheck disable=SC2030,SC2031 # It's okay to be changed within the test subshell
    export __test_uname_s_answer=Linux
    run sys::is_linux
    assert_success

    export __test_uname_s_answer=Darwin
    run sys::is_linux
    assert_failure
}

@test "test_is_macos" {

    # shellcheck disable=SC2031,SC2030 # It's okay to be changed within the test subshell
    export __test_uname_m_answer=''

    # shellcheck disable=SC2317 # This is mocking the command
    uname() {
        fake_uname "$@"
    }
    export -f uname
    register_teardown "unset -f uname"

    # shellcheck disable=SC2030,SC2031 # It's okay to be changed within the test subshell
    export __test_uname_s_answer=Linux
    run sys::is_macos
    assert_failure

    export __test_uname_s_answer=Darwin
    run sys::is_macos
    assert_success
}

@test "test_ensure_linux_macos" {
    # shellcheck disable=SC2317 # This is mocking the command
    uname() {
        fake_uname "$@"
    }
    export -f uname
    register_teardown "unset -f uname"

    # shellcheck disable=SC2031,SC2030 # It's okay to be changed within the test subshell
    export __test_uname_m_answer=''

    log_step "Respond as linux system"
    # shellcheck disable=SC2031,SC2030 # It's okay to be changed within the test subshell
    export __test_uname_s_answer=Linux

    test_ensure_function sys::ensure_linux \
        --success \
            "This is a Linux system"

    test_ensure_function sys::ensure_macos \
        --failure \
            "This is intended to run on a macOS system"

    log_step "Respond as MacOS system"
    __test_uname_s_answer=Darwin
    test_ensure_function sys::ensure_macos \
        --success \
            "This is a macOS system"

    test_ensure_function sys::ensure_linux \
        --failure \
            "This is intended to run on a Linux system"
}

@test "test_is_docker_host" {
    skip_unless_root
    user::group_exists docker && skip "Docker group already exists. This could break things."

    run sys::is_docker_host
    assert_failure

    test_ensure_function sys::ensure_docker_host \
        --failure \
            "This is intended to run on a Docker host"

    docker() { ui::die "Should not call docker"; }
    register_teardown "unset -f docker"
    export -f docker

    run sys::is_docker_host
    assert_failure

    test_ensure_function sys::ensure_docker_host \
        --failure \
            "This is intended to run on a Docker host"

    groupadd docker
    register_teardown "groupdel docker"

    run sys::is_docker_host
    assert_success

    test_ensure_function sys::ensure_docker_host \
        --success \
            "This is a Docker host"
}

@test "test_run_as_same_user" {
    user=$(whoami)
    run sys::run_as "$user" whoami
    assert_success
    assert_output "$user"
}

@test "test_run_as_root" {
    skip_unless_root

    user=test_user

    user::create "$user"
    register_teardown "userdel $user"

    run sys::run_as root whoami
    assert_success
    assert_output "root"

    run sys::run_as "$user" whoami
    assert_success
    assert_output "$user"
}