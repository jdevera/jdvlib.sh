#!/usr/bin/env bats

setup() {
    load 'test_helper/common_setup'
    _common_setup
    meta::import text
}

teardown() {
    # executed after each test
    :
}

dedent() {
    sed -e 's/^ *//'
}

@test "test_delete_inside_markers" {
    local start_delim="#--SETUP-START--"
    local end_delim="#--SETUP-END--"
    local file="$BATS_TEST_TMPDIR/test_delete_inside_markers.txt"
    dedent <<EOF > "$file"
        Previous content
        #--SETUP-START--
        # This is a comment
        #--SETUP-END--
        After content
EOF

    expected=$(dedent <<EOF
        Previous content
        #--SETUP-START--
        #--SETUP-END--
        After content
EOF
)
    run text::delete_inside_markers "$start_delim" "$end_delim" < "$file"
    assert_success
    assert_output "$expected"
}

@test "test_delete_around_markers" {
    local start_delim="#--SETUP-START--"
    local end_delim="#--SETUP-END--"
    local file="$BATS_TEST_TMPDIR/test_delete_inside_markers.txt"
    dedent <<EOF > "$file"
        Previous content
        #--SETUP-START--
        # This is a comment
        #--SETUP-END--
        After content
EOF

    expected=$(dedent <<EOF
        Previous content
        After content
EOF
    )
    run text::delete_around_markers "$start_delim" "$end_delim" < "$file"
    assert_success
    assert_output "$expected"
}

@test "test_replace_inside_markers" {
    local file="$BATS_TEST_TMPDIR/test_replace_inside_markers.txt"
    dedent <<EOF > "$file"
        Previous content
        #--SETUP-START--
        # This is a comment
        #--SETUP-END--
        After content
EOF

    local new_content="# This is a new comment"
    run text::replace_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "$new_content" < "$file"
    assert_success
    assert_output "$(dedent <<EOF
        Previous content
        #--SETUP-START--
        # This is a new comment
        #--SETUP-END--
        After content
EOF
    )"
}

@test "test_replace_inside_markers_no_end" {
    local file="$BATS_TEST_TMPDIR/test_replace_inside_markers_no_end.txt"
    dedent <<EOF > "$file"
        Previous content
        #--SETUP-START--
        # This is a comment
        content
        no end
EOF

    local new_content="# This is a new comment\nAnd a second line"
    run text::replace_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "$new_content" < "$file"
    assert_success
    assert_output "$(dedent <<EOF
        Previous content
        #--SETUP-START--
        # This is a new comment
        And a second line
EOF
    )"
}

@test "test_replace_inside_markers_no_start_appends" {
    local file="$BATS_TEST_TMPDIR/test_replace_inside_markers_no_start.txt"
    dedent <<EOF > "$file"
        Previous content
        # This is a comment
        #--SETUP-END--
        After content
EOF

    local new_content="# This is a new comment\nAnd a second line"
    run text::replace_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "$new_content" < "$file"
    assert_success
    assert_output "$(dedent <<EOF
        Previous content
        # This is a comment
        #--SETUP-END--
        After content
        #--SETUP-START--
        # This is a new comment
        And a second line
        #--SETUP-END--
EOF
    )"
}

@test "test_replace_inside_markers_no_start_no_end_appends" {
    local file="$BATS_TEST_TMPDIR/test_replace_inside_markers_no_start_no_end.txt"
    dedent <<EOF > "$file"
        Previous content
        # This is a comment
        After content
EOF

        local new_content="# This is a new comment\nAnd a second line"
        run text::replace_inside_markers \
            '#--SETUP-START--' \
            '#--SETUP-END--' \
            "$new_content" < "$file"
        assert_success
        assert_output "$(dedent <<EOF
            Previous content
            # This is a comment
            After content
            #--SETUP-START--
            # This is a new comment
            And a second line
            #--SETUP-END--
EOF
        )"
}


@test "test_replace_inside_markers_multiline" {
    local file="$BATS_TEST_TMPDIR/test_replace_inside_markers_multiline.txt"
    dedent <<EOF > "$file"
        Previous content
        #--SETUP-START--
        # This is a comment
        #--SETUP-END--
        After content
EOF

    local new_content
    new_content="$(dedent <<EOF
        # This is a new comment
        And a second line
EOF
    )"
    run text::replace_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "$new_content" < "$file"
    assert_success
    assert_output "$(dedent <<EOF
        Previous content
        #--SETUP-START--
        # This is a new comment
        And a second line
        #--SETUP-END--
        After content
EOF
    )"
}

@test "test_format_inside_markers" {
    local file="$BATS_TEST_TMPDIR/test_format_inside_markers.txt"
    dedent <<EOF >"$file"
        Previous content
        #--SETUP-START--
        This should be commented out
        #--SETUP-END--
        After content
EOF
    run text::format_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        '## %s' \
        <"$file"
    assert_success
    assert_output "$(
        dedent <<EOF
        Previous content
        #--SETUP-START--
        ## This should be commented out
        #--SETUP-END--
        After content
EOF
    )"
}

@test "test_filter_inside_markers" {
    local file="$BATS_TEST_TMPDIR/test_filter_inside_markers.txt"
    dedent <<EOF >"$file"
        Previous content
        #--SETUP-START--
        This should be changed
        #--SETUP-END--
        After content
EOF
    filter() {
        # shellcheck disable=SC2317 # This will be used indirectly
        sed 's/This should be/That is/'
    }
    run text::filter_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "filter" \
        <"$file"

    assert_success
    assert_output "$(
        dedent <<EOF
        Previous content
        #--SETUP-START--
        That is changed
        #--SETUP-END--
        After content
EOF
    )"
}

@test "test_filter_inside_markers_stdin" {
    local input
    input=$(dedent <<EOF
        Previous content
        #--SETUP-START--
        This should be changed
        #--SETUP-END--
        After content
EOF
    )
    filter() {
        # shellcheck disable=SC2317 # This will be used indirectly
        sed 's/This should be/That is/'
    }
    run text::filter_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "filter" \
        <<<"$input"

    assert_success
    assert_output "$(
        dedent <<EOF
        Previous content
        #--SETUP-START--
        That is changed
        #--SETUP-END--
        After content
EOF
    )"
}

@test "test_filter_inside_markers_no_end" {
    local file="$BATS_TEST_TMPDIR/test_filter_inside_markers_no_end.txt"
    dedent <<EOF >"$file"
        Previous content
        #--SETUP-START--
        This should be changed
        no end
EOF
    filter() {
        # shellcheck disable=SC2317 # This will be used indirectly
        sed 's/\(.*\)/--\1--/'
    }
    run text::filter_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "filter" \
        <"$file"

    assert_success
    assert_output "$(
        dedent <<EOF
        Previous content
        #--SETUP-START--
        --This should be changed--
        --no end--
EOF
    )"
}

@test "test_filter_inside_markers_no_start_does_nothing" {
    local file="$BATS_TEST_TMPDIR/test_filter_inside_markers_no_start.txt"
    dedent <<EOF >"$file"
        Previous content
        This should not be changed
        #--SETUP-END--
        After content
EOF
    filter() {
        # shellcheck disable=SC2317 # This will be used indirectly
        sed 's/This should be/That is/'
    }
    run text::filter_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "filter" \
        <"$file"

    assert_success
    assert_output "$(
        dedent <<EOF
        Previous content
        This should not be changed
        #--SETUP-END--
        After content
EOF
    )"
}

@test "test_filter_inside_markers_line_removal" {
    local file="$BATS_TEST_TMPDIR/test_filter_line_removal.txt"
    dedent <<EOF >"$file"
        Previous content
        #--SETUP-START--
        This should be removed
        This should be kept
        #--SETUP-END--
        After content
EOF
    filter() {
        grep -v removed
    }
    run text::filter_inside_markers \
        '#--SETUP-START--' \
        '#--SETUP-END--' \
        "filter" \
        <"$file"

    assert_success
    assert_output "$(
        dedent <<EOF
        Previous content
        #--SETUP-START--
        This should be kept
        #--SETUP-END--
        After content
EOF
    )"
}

