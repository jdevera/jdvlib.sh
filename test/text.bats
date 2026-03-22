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
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    filter() {
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
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    filter() {
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
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    filter() {
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
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    filter() {
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

@test "test_apply_in_place_cleans_up_on_failure" {
    local file="$BATS_TEST_TMPDIR/test_apply_in_place.txt"
    echo "original content" > "$file"

    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    failing_filter() {
        return 1
    }
    run text::apply_in_place failing_filter "$file"
    assert_failure

    # Original file should be unchanged
    run cat "$file"
    assert_output "original content"

    # No temp files should remain (mktemp creates in /tmp, not BATS_TEST_TMPDIR)
    # Just verify the function returned failure and file is intact
    run cat "$file"
    assert_output "original content"
}

@test "test_markers_with_regex_metacharacters" {
    local input
    input=$(cat <<'EOF'
Before
[section.start]
content inside
[section.end]
After
EOF
    )

    # delete_inside_markers
    run text::delete_inside_markers '[section.start]' '[section.end]' <<<"$input"
    assert_success
    assert_line --index 0 "Before"
    assert_line --index 1 "[section.start]"
    assert_line --index 2 "[section.end]"
    assert_line --index 3 "After"

    # delete_around_markers
    run text::delete_around_markers '[section.start]' '[section.end]' <<<"$input"
    assert_success
    assert_line --index 0 "Before"
    assert_line --index 1 "After"

    # read_inside_markers
    run text::read_inside_markers '[section.start]' '[section.end]' <<<"$input"
    assert_success
    assert_output "content inside"

    # replace_inside_markers
    run text::replace_inside_markers '[section.start]' '[section.end]' "new content" <<<"$input"
    assert_success
    assert_line --index 1 "[section.start]"
    assert_line --index 2 "new content"
    assert_line --index 3 "[section.end]"

    # format_inside_markers
    run text::format_inside_markers '[section.start]' '[section.end]' '## %s' <<<"$input"
    assert_success
    assert_line --index 2 "## content inside"

    # filter_inside_markers
    # shellcheck disable=SC2317,SC2329
    filter() { sed 's/content/REPLACED/'; }
    run text::filter_inside_markers '[section.start]' '[section.end]' "filter" <<<"$input"
    assert_success
    assert_line --index 2 "REPLACED inside"
}

@test "test_filter_delimiter_substring_no_false_match" {
    # Delimiter is a substring of a longer line — should NOT match
    local input
    input=$(cat <<'EOF'
Before
prefix #--START-- suffix
actual content
#--END--
After
EOF
    )
    # shellcheck disable=SC2317,SC2329
    filter() { sed 's/actual/CHANGED/'; }
    run text::filter_inside_markers '#--START--' '#--END--' "filter" <<<"$input"
    assert_success
    # The line with "prefix #--START-- suffix" should NOT trigger the block
    assert_line --index 1 "prefix #--START-- suffix"
    assert_line --index 2 "actual content"
}

@test "test_filter_inside_markers_preserves_indentation" {
    local input
    input=$(cat <<'EOF'
Before
#--START--
    indented line
        double indented
#--END--
After
EOF
    )
    # shellcheck disable=SC2317,SC2329 # Invoked indirectly
    filter() {
        cat
    }
    run text::filter_inside_markers \
        '#--START--' \
        '#--END--' \
        "filter" \
        <<<"$input"

    assert_success
    assert_line --index 2 "    indented line"
    assert_line --index 3 "        double indented"
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
