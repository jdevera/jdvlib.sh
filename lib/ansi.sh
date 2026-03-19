#!/usr/bin/env bash

: <<'jdvlib:doc'
ANSI escape code utilities for text styling, cursor control, display
manipulation, and terminal operations. Organized into four functions:
ansi::style, ansi::cursor, ansi::display, and ansi::term.
jdvlib:doc

# jdvlib: --- BEGIN IMPORTS ---
#
# NOTICE: This block exists so the library is usable when not compiled into a
# single file.  When compiled, this block is commented out since all the
# files are included in the compiled file.
#
# shellcheck source=./_meta.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/_meta.sh"

# jdvlib: --- END IMPORTS ---

# @section ansi
# @description ANSI escape code utilities for text styling, cursor control, display manipulation, and terminal operations.

__ANSI_ESC=$'\033'
__ANSI_CSI="${__ANSI_ESC}["
__ANSI_OSC="${__ANSI_ESC}]"
__ANSI_ST="${__ANSI_ESC}\\"

# @description Check if the terminal supports ANSI escape codes.
#
#     Respects the FORCE_COLOR and NO_COLOR environment variables:
#
#     - `FORCE_COLOR` (non-empty): always enable ANSI, overrides everything.
#       See https://force-color.org/
#     - `NO_COLOR` (non-empty): disable ANSI.
#       See https://no-color.org/
#     - `FORCE_COLOR` takes precedence over `NO_COLOR`.
#
# @noargs
# @env FORCE_COLOR string Force ANSI support when non-empty.
# @env NO_COLOR string Disable ANSI support when non-empty.
# @exitcode 0 If ANSI is supported.
# @exitcode 1 If ANSI is not supported.
ansi::isSupported() {
    [[ -n "${FORCE_COLOR:-}" ]] && return 0
    [[ -n "${NO_COLOR:-}" ]] && return 1
    [[ -t 1 ]] || return 1
    [[ "${TERM:-}" != "dumb" ]] || return 1
    return 0
}

# @description Format text with ANSI colors and attributes.
#     Applies the specified styling flags to the given text and automatically
#     resets all attributes after the text is printed.
#
#     Multiple flags can be combined. Text arguments are concatenated with spaces.
#
#     **Attributes:** `--bold`, `--faint`, `--italic`, `--underline`,
#     `--double-underline`, `--blink`, `--inverse`, `--invisible`, `--strike`,
#     `--overline`
#
#     **Foreground colors:** `--black`, `--red`, `--green`, `--yellow`, `--blue`,
#     `--magenta`, `--cyan`, `--white`, plus `--<color>-intense` variants.
#     `--color=N` for 256-color, `--rgb=R,G,B` for truecolor.
#
#     **Background colors:** `--bg-<color>`, `--bg-<color>-intense`,
#     `--bg-color=N`, `--bg-rgb=R,G,B`
#
# @arg $@ string Flags followed by text to style.
#
# @option --bold           Bold text.
# @option --faint          Dim/faint text.
# @option --italic         Italic text.
# @option --underline      Underlined text.
# @option --double-underline  Double underline.
# @option --blink          Blinking text.
# @option --inverse        Swap foreground/background.
# @option --invisible      Hidden text.
# @option --strike         Strikethrough text.
# @option --overline       Overlined text.
# @option --black          Black foreground.
# @option --red            Red foreground.
# @option --green          Green foreground.
# @option --yellow         Yellow foreground.
# @option --blue           Blue foreground.
# @option --magenta        Magenta foreground.
# @option --cyan           Cyan foreground.
# @option --white          White foreground.
# @option --black-intense  Bright black foreground (also for other colors).
# @option --color=<N>      256-color foreground (0-255).
# @option --rgb=<R,G,B>    Truecolor foreground.
# @option --bg-black       Black background (also for other colors).
# @option --bg-black-intense  Bright black background (also for other colors).
# @option --bg-color=<N>   256-color background.
# @option --bg-rgb=<R,G,B> Truecolor background.
# @option --normal            Reset bold/faint.
# @option --no-italic         Reset italic.
# @option --no-underline      Reset underline.
# @option --no-blink          Reset blink.
# @option --no-inverse        Reset inverse.
# @option --visible           Reset invisible.
# @option --no-strike         Reset strikethrough.
# @option --reset-foreground  Reset foreground color.
# @option --reset-background  Reset background color.
# @option --no-overline       Reset overline.
# @option --reset-all         Reset all attributes.
# @option -n | --no-newline   Suppress trailing newline.
# @option --no-reset          Do not auto-reset attributes after text.
#
# @stdout Styled text with ANSI escape sequences.
#
# @example
#   ansi::style --bold --red "Error:" "something went wrong"
#   ansi::style --italic --cyan "Note"
#   ansi::style --rgb=255,128,0 "Orange text"
#   ansi::style --bg-blue --white --bold "Highlighted"
ansi::style() {
    local -a codes=()
    local text="" newline=true do_reset=true r g b
    local supported=true
    ansi::isSupported || supported=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            # Attributes
            --bold)             codes+=(1) ;;
            --faint)            codes+=(2) ;;
            --italic)           codes+=(3) ;;
            --underline)        codes+=(4) ;;
            --blink)            codes+=(5) ;;
            --inverse)          codes+=(7) ;;
            --invisible)        codes+=(8) ;;
            --strike)           codes+=(9) ;;
            --double-underline) codes+=(21) ;;
            --overline)         codes+=(53) ;;

            # Foreground colors
            --black)            codes+=(30) ;;
            --red)              codes+=(31) ;;
            --green)            codes+=(32) ;;
            --yellow)           codes+=(33) ;;
            --blue)             codes+=(34) ;;
            --magenta)          codes+=(35) ;;
            --cyan)             codes+=(36) ;;
            --white)            codes+=(37) ;;
            --black-intense)    codes+=(90) ;;
            --red-intense)      codes+=(91) ;;
            --green-intense)    codes+=(92) ;;
            --yellow-intense)   codes+=(93) ;;
            --blue-intense)     codes+=(94) ;;
            --magenta-intense)  codes+=(95) ;;
            --cyan-intense)     codes+=(96) ;;
            --white-intense)    codes+=(97) ;;

            # 256-color foreground
            --color=*)          codes+=(38 5 "${1#*=}") ;;

            # Truecolor foreground
            --rgb=*)
                r=${1#*=}; b=${r##*,}; g=${r#*,}; g=${g%,*}; r=${r%%,*}
                codes+=(38 2 "$r" "$g" "$b")
                ;;

            # Background colors
            --bg-black)            codes+=(40) ;;
            --bg-red)              codes+=(41) ;;
            --bg-green)            codes+=(42) ;;
            --bg-yellow)           codes+=(43) ;;
            --bg-blue)             codes+=(44) ;;
            --bg-magenta)          codes+=(45) ;;
            --bg-cyan)             codes+=(46) ;;
            --bg-white)            codes+=(47) ;;
            --bg-black-intense)    codes+=(100) ;;
            --bg-red-intense)      codes+=(101) ;;
            --bg-green-intense)    codes+=(102) ;;
            --bg-yellow-intense)   codes+=(103) ;;
            --bg-blue-intense)     codes+=(104) ;;
            --bg-magenta-intense)  codes+=(105) ;;
            --bg-cyan-intense)     codes+=(106) ;;
            --bg-white-intense)    codes+=(107) ;;

            # 256-color background
            --bg-color=*)       codes+=(48 5 "${1#*=}") ;;

            # Truecolor background
            --bg-rgb=*)
                r=${1#*=}; b=${r##*,}; g=${r#*,}; g=${g%,*}; r=${r%%,*}
                codes+=(48 2 "$r" "$g" "$b")
                ;;

            # Granular resets
            --normal)              codes+=(22) ;; # reset bold/faint
            --no-italic)           codes+=(23) ;; # reset italic
            --no-underline)        codes+=(24) ;; # reset underline
            --no-blink)            codes+=(25) ;; # reset blink
            --no-inverse)          codes+=(27) ;; # reset inverse
            --visible)             codes+=(28) ;; # reset invisible
            --no-strike)           codes+=(29) ;; # reset strike
            --reset-foreground)    codes+=(39) ;; # reset fg color
            --reset-background)    codes+=(49) ;; # reset bg color
            --no-overline)         codes+=(55) ;; # reset overline
            --reset-all)           codes+=(0) ;;  # reset everything

            # Output control
            -n|--no-newline)    newline=false ;;
            --no-reset)         do_reset=false ;;

            # End of flags
            --)                 shift; text+="$*"; break ;;
            -*)                 ;; # ignore unknown flags
            *)                  text+="$*"; break ;;
        esac
        shift
    done

    if $supported && [[ ${#codes[@]} -gt 0 ]]; then
        local IFS=';'
        printf '%s%sm' "$__ANSI_CSI" "${codes[*]}"
    fi

    printf '%s' "$text"

    if $supported && $do_reset && [[ ${#codes[@]} -gt 0 ]]; then
        printf '%s0m' "$__ANSI_CSI"
    fi

    if $newline; then
        printf '\n'
    fi
}

# @description Move or control the terminal cursor.
#
#     Supports movement, absolute positioning, save/restore, and visibility.
#     Multiple commands can be combined in a single call.
#
# @option --up=<N>           Move cursor up N lines (default: 1).
# @option --down=<N>         Move cursor down N lines.
# @option --forward=<N>      Move cursor forward N columns.
# @option --backward=<N>     Move cursor backward N columns.
# @option --next-line=<N>    Move to beginning of Nth next line.
# @option --prev-line=<N>    Move to beginning of Nth previous line.
# @option --column=<N>       Move to absolute column N.
# @option --position=<L,C>   Move to line L, column C.
# @option --save             Save cursor position.
# @option --restore          Restore cursor position.
# @option --hide             Hide cursor.
# @option --show             Show cursor.
#
# @example
#   ansi::cursor --up=5
#   ansi::cursor --position=10,20
#   ansi::cursor --hide
#   ansi::cursor --save --up=3 --forward=10
ansi::cursor() {
    ansi::isSupported || return 0
    local l c
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --up)          printf '%s%sA' "$__ANSI_CSI" 1 ;;
            --up=*)        printf '%s%sA' "$__ANSI_CSI" "${1#*=}" ;;
            --down)        printf '%s%sB' "$__ANSI_CSI" 1 ;;
            --down=*)      printf '%s%sB' "$__ANSI_CSI" "${1#*=}" ;;
            --forward)     printf '%s%sC' "$__ANSI_CSI" 1 ;;
            --forward=*)   printf '%s%sC' "$__ANSI_CSI" "${1#*=}" ;;
            --backward)    printf '%s%sD' "$__ANSI_CSI" 1 ;;
            --backward=*)  printf '%s%sD' "$__ANSI_CSI" "${1#*=}" ;;
            --next-line)   printf '%s%sE' "$__ANSI_CSI" 1 ;;
            --next-line=*) printf '%s%sE' "$__ANSI_CSI" "${1#*=}" ;;
            --prev-line)   printf '%s%sF' "$__ANSI_CSI" 1 ;;
            --prev-line=*) printf '%s%sF' "$__ANSI_CSI" "${1#*=}" ;;
            --column)      printf '%s%sG' "$__ANSI_CSI" 1 ;;
            --column=*)    printf '%s%sG' "$__ANSI_CSI" "${1#*=}" ;;
            --position=*)
                l=${1#*=}; c=${l#*,}; l=${l%%,*}
                printf '%s%s;%sH' "$__ANSI_CSI" "$l" "$c"
                ;;
            --save)        printf '%ss' "$__ANSI_CSI" ;;
            --restore)     printf '%su' "$__ANSI_CSI" ;;
            --hide)        printf '%s?25l' "$__ANSI_CSI" ;;
            --show)        printf '%s?25h' "$__ANSI_CSI" ;;
            *)             return 1 ;;
        esac
        shift
    done
}

# @description Manipulate the terminal display.
#
#     Erase content, scroll the viewport, or insert/delete lines and characters.
#     Multiple commands can be combined in a single call.
#
# @option --erase-display=<N>  Erase display. 0=below, 1=above, 2=all, 3=scrollback.
# @option --erase-line=<N>     Erase line. 0=right, 1=left, 2=all.
# @option --erase-chars=<N>    Erase N characters.
# @option --scroll-up=<N>      Scroll viewport up N lines.
# @option --scroll-down=<N>    Scroll viewport down N lines.
# @option --insert-lines=<N>   Insert N blank lines.
# @option --delete-lines=<N>   Delete N lines.
# @option --insert-chars=<N>   Insert N blank characters.
# @option --delete-chars=<N>   Delete N characters.
#
# @example
#   ansi::display --erase-display=2
#   ansi::display --scroll-up=3
#   ansi::display --erase-line
ansi::display() {
    ansi::isSupported || return 0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --erase-display)    printf '%s%sJ' "$__ANSI_CSI" 0 ;;
            --erase-display=*)  printf '%s%sJ' "$__ANSI_CSI" "${1#*=}" ;;
            --erase-line)       printf '%s%sK' "$__ANSI_CSI" 0 ;;
            --erase-line=*)     printf '%s%sK' "$__ANSI_CSI" "${1#*=}" ;;
            --erase-chars)      printf '%s%sX' "$__ANSI_CSI" 1 ;;
            --erase-chars=*)    printf '%s%sX' "$__ANSI_CSI" "${1#*=}" ;;
            --scroll-up)        printf '%s%sS' "$__ANSI_CSI" 1 ;;
            --scroll-up=*)      printf '%s%sS' "$__ANSI_CSI" "${1#*=}" ;;
            --scroll-down)      printf '%s%sT' "$__ANSI_CSI" 1 ;;
            --scroll-down=*)    printf '%s%sT' "$__ANSI_CSI" "${1#*=}" ;;
            --insert-lines)     printf '%s%sL' "$__ANSI_CSI" 1 ;;
            --insert-lines=*)   printf '%s%sL' "$__ANSI_CSI" "${1#*=}" ;;
            --delete-lines)     printf '%s%sM' "$__ANSI_CSI" 1 ;;
            --delete-lines=*)   printf '%s%sM' "$__ANSI_CSI" "${1#*=}" ;;
            --insert-chars)     printf '%s%s@' "$__ANSI_CSI" 1 ;;
            --insert-chars=*)   printf '%s%s@' "$__ANSI_CSI" "${1#*=}" ;;
            --delete-chars)     printf '%s%sP' "$__ANSI_CSI" 1 ;;
            --delete-chars=*)   printf '%s%sP' "$__ANSI_CSI" "${1#*=}" ;;
            *)                  return 1 ;;
        esac
        shift
    done
}

# @description Perform terminal-level operations.
#
#     Set window title, icon name, ring the bell, or reset the terminal.
#
# @option --title=<text>  Set the terminal window title.
# @option --icon=<text>   Set the terminal icon name.
# @option --bell          Ring the terminal bell.
# @option --reset         Full terminal reset (clears screen, resets all).
#
# @example
#   ansi::term --title="My Script - Running"
#   ansi::term --bell
#   ansi::term --reset
ansi::term() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title=*)
                ansi::isSupported || { shift; continue; }
                printf '%s2;%s%s' "$__ANSI_OSC" "${1#*=}" "$__ANSI_ST"
                ;;
            --icon=*)
                ansi::isSupported || { shift; continue; }
                printf '%s1;%s%s' "$__ANSI_OSC" "${1#*=}" "$__ANSI_ST"
                ;;
            --bell)
                printf '%s' $'\007'
                ;;
            --reset)
                ansi::isSupported || { shift; continue; }
                printf '%sc' "$__ANSI_ESC"
                ;;
            *)
                return 1
                ;;
        esac
        shift
    done
}

if meta::module_is_running; then
    case "${1:-}" in
        style|cursor|display|term)
            "ansi::$1" "${@:2}" || exit $?
            ;;
        *)
            cat <<'EOF'
Usage: ansi.sh <command> [options]

Commands:
  style    Format text with colors and attributes
  cursor   Move or control the terminal cursor
  display  Manipulate the terminal display
  term     Terminal title, icon, bell, and reset

Examples:
  ansi.sh style --bold --red "Error"
  ansi.sh cursor --up=5
  ansi.sh display --erase-display=2
  ansi.sh term --title="My App"
EOF
            exit 1
            ;;
    esac
fi
