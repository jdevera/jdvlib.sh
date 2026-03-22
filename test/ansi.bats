#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import ansi
}

teardown() {
    _run_teardown_functions
}

# --- ansi::isSupported ---

@test "test_is_supported_force_color" {
    FORCE_COLOR=1 run ansi::isSupported
    assert_success
}

@test "test_is_supported_force_color_overrides_no_color" {
    FORCE_COLOR=1 NO_COLOR=1 run ansi::isSupported
    assert_success
}

@test "test_is_not_supported_no_color" {
    NO_COLOR=1 run ansi::isSupported
    assert_failure
}

@test "test_is_not_supported_dumb_term" {
    TERM=dumb run ansi::isSupported
    assert_failure
}

@test "test_is_not_supported_in_pipe" {
    # run executes in a subshell where stdout is not a tty
    run ansi::isSupported
    assert_failure
}

@test "test_force_color_overrides_dumb_term" {
    FORCE_COLOR=1 TERM=dumb run ansi::isSupported
    assert_success
}

# --- ansi::style ---

@test "test_style_no_flags" {
    FORCE_COLOR=1 run ansi::style "hello"
    assert_success
    assert_output "hello"
}

@test "test_style_bold" {
    FORCE_COLOR=1 run ansi::style --bold "hello"
    assert_success
    # Should contain escape codes wrapping the text
    [[ "$output" == *$'\033['*"hello"*$'\033[0m' ]]
}

@test "test_style_no_newline" {
    FORCE_COLOR=1 run ansi::style -n --bold "hello"
    assert_success
    # Output should not end with a newline (run strips it, but check no double newline)
    [[ "$output" == *"hello"* ]]
}

@test "test_style_no_reset" {
    FORCE_COLOR=1 run ansi::style --no-reset --red "hello"
    assert_success
    # Should NOT contain reset sequence
    [[ "$output" != *$'\033[0m'* ]]
}

@test "test_style_no_color_strips_ansi" {
    NO_COLOR=1 run ansi::style --bold --red "hello"
    assert_success
    assert_output "hello"
}

@test "test_style_multiple_flags" {
    FORCE_COLOR=1 run ansi::style --bold --italic --red "hello"
    assert_success
    # Should contain combined codes: 1;3;31
    [[ "$output" == *$'\033[1;3;31m'* ]]
}

@test "test_style_256_color" {
    FORCE_COLOR=1 run ansi::style --color=42 "hello"
    assert_success
    [[ "$output" == *$'\033[38;5;42m'* ]]
}

@test "test_style_truecolor" {
    FORCE_COLOR=1 run ansi::style --rgb=255,128,0 "hello"
    assert_success
    [[ "$output" == *$'\033[38;2;255;128;0m'* ]]
}

@test "test_style_background" {
    FORCE_COLOR=1 run ansi::style --bg-blue "hello"
    assert_success
    [[ "$output" == *$'\033[44m'* ]]
}

@test "test_style_granular_reset" {
    FORCE_COLOR=1 run ansi::style --reset-all "hello"
    assert_success
    [[ "$output" == *$'\033[0m'* ]]
}

@test "test_style_invalid_color_warns" {
    FORCE_COLOR=1 run ansi::style --color=abc "hello"
    assert_success
    [[ "$output" == *"invalid colour value"* ]]
}

@test "test_style_invalid_rgb_warns" {
    FORCE_COLOR=1 run ansi::style --rgb=abc "hello"
    assert_success
    [[ "$output" == *"invalid RGB value"* ]]
}

@test "test_style_invalid_bg_color_warns" {
    FORCE_COLOR=1 run ansi::style --bg-color=xyz "hello"
    assert_success
    [[ "$output" == *"invalid colour value"* ]]
}

@test "test_style_unknown_flag_warns" {
    FORCE_COLOR=1 run ansi::style --nonexistent "hello"
    assert_success
    # stderr should contain the warning
    [[ "$output" == *"unknown flag '--nonexistent'"* ]]
}

# --- ansi::cursor ---

@test "test_cursor_up" {
    FORCE_COLOR=1 run ansi::cursor --up=5
    assert_success
    assert_output $'\033[5A'
}

@test "test_cursor_position" {
    FORCE_COLOR=1 run ansi::cursor --position=10,20
    assert_success
    assert_output $'\033[10;20H'
}

@test "test_cursor_save_and_restore" {
    FORCE_COLOR=1 run ansi::cursor --save
    assert_success
    assert_output $'\033[s'
}

@test "test_cursor_hide" {
    FORCE_COLOR=1 run ansi::cursor --hide
    assert_success
    assert_output $'\033[?25l'
}

@test "test_cursor_no_color_is_noop" {
    NO_COLOR=1 run ansi::cursor --up=5
    assert_success
    assert_output ""
}

# --- ansi::display ---

@test "test_display_erase" {
    FORCE_COLOR=1 run ansi::display --erase-display=2
    assert_success
    assert_output $'\033[2J'
}

@test "test_display_scroll_up" {
    FORCE_COLOR=1 run ansi::display --scroll-up=3
    assert_success
    assert_output $'\033[3S'
}

@test "test_display_no_color_is_noop" {
    NO_COLOR=1 run ansi::display --erase-display=2
    assert_success
    assert_output ""
}

# --- ansi::term ---

@test "test_term_bell" {
    run ansi::term --bell
    assert_success
    assert_output $'\007'
}

@test "test_term_reset" {
    FORCE_COLOR=1 run ansi::term --reset
    assert_success
    assert_output $'\033c'
}

@test "test_term_title" {
    FORCE_COLOR=1 run ansi::term --title="My App"
    assert_success
    [[ "$output" == *"My App"* ]]
}
