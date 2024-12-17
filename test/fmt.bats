#!/usr/bin/env bats

setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import fmt
}

teardown() {
    # executed after each test
    _run_teardown_functions
}

@test "test_bytes_to_human_readable" {
    local unit
    local amount
    local new_amount
    for unit in "${__BYTES_UNITS[@]}"; do
        amount=${__BYTES_CONVERSION_TABLE[$unit]}
        run fmt::bytes "$amount"
        assert_output "1.00 $unit"

        new_amount=$(echo "$amount * 1.671" | bc)
        run fmt::bytes "$new_amount"
        assert_output "1.67 $unit"
    done

    run fmt::bytes 0
    assert_output "0.00 B"

    run fmt::bytes 1
    assert_output "1.00 B"
}

@test "test_bytes_to_human_readable_max_unit" {
    local unit prev_unit amount i
    for i in "${!__BYTES_UNITS[@]}"; do
        [[ $i -eq 0 ]] && continue
        unit=${__BYTES_UNITS[$i]}
        prev_unit=${__BYTES_UNITS[$((i - 1))]}
        amount=${__BYTES_CONVERSION_TABLE[$unit]}
        run fmt::bytes "$amount" "$prev_unit"
        assert_output "1024.00 $prev_unit"
    done
}

@test "test_bytes_to_unit" {
    run fmt::bytes_to 1 B
    assert_output "1.00 B"

    run fmt::bytes_to 1024 B
    assert_output "1024.00 B"

    run fmt::bytes_to 1024 KB
    assert_output "1.00 KB"

    run fmt::bytes_to 37989870872 MB
    assert_output "36229.96 MB"
}