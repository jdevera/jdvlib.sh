# jdvlib.sh: Jacobo de Vera's Bash Library

> Look, you don't have to like it.

## How to use

Run `make` to bundle the library into a single file
`build/jdvlib.sh`.

Copy that file to your project and source it in your scripts.

```bash
# shellcheck source=./jdvlib.sh
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/jdvlib.sh"
```

## Vendored code:

* https://github.com/fidian/ansi -> ansi.sh

## Modules

<!-- MODULES:START -->
### Module `ansi`

Functions related to ANSI escape codes. This code is vendored in from
[Tyler Akins' ansi project](https://github.com/fidian/ansi).

#### Functions

<details>
<summary>Click to expand (118 functions)</summary>

- `ansi::ansi`
- `ansi::backward`
- `ansi::bell`
- `ansi::bgBlack`
- `ansi::bgBlackIntense`
- `ansi::bgBlue`
- `ansi::bgBlueIntense`
- `ansi::bgColor`
- `ansi::bgCyan`
- `ansi::bgCyanIntense`
- `ansi::bgGreen`
- `ansi::bgGreenIntense`
- `ansi::bgMagenta`
- `ansi::bgMagentaIntense`
- `ansi::bgRed`
- `ansi::bgRedIntense`
- `ansi::bgRgb`
- `ansi::bgWhite`
- `ansi::bgWhiteIntense`
- `ansi::bgYellow`
- `ansi::bgYellowIntense`
- `ansi::black`
- `ansi::blackIntense`
- `ansi::blink`
- `ansi::blue`
- `ansi::blueIntense`
- `ansi::bold`
- `ansi::color`
- `ansi::colorCodePatch`
- `ansi::colorCodes`
- `ansi::colorTable`
- `ansi::colorTableLine`
- `ansi::column`
- `ansi::columnRelative`
- `ansi::cyan`
- `ansi::cyanIntense`
- `ansi::deleteChars`
- `ansi::deleteLines`
- `ansi::doubleUnderline`
- `ansi::down`
- `ansi::encircle`
- `ansi::eraseChars`
- `ansi::eraseDisplay`
- `ansi::eraseLine`
- `ansi::faint`
- `ansi::font`
- `ansi::forward`
- `ansi::fraktur`
- `ansi::frame`
- `ansi::green`
- `ansi::greenIntense`
- `ansi::hideCursor`
- `ansi::icon`
- `ansi::ideogramLeft`
- `ansi::ideogramLeftDouble`
- `ansi::ideogramRight`
- `ansi::ideogramRightDouble`
- `ansi::ideogramStress`
- `ansi::insertChars`
- `ansi::insertLines`
- `ansi::inverse`
- `ansi::invisible`
- `ansi::isAnsiSupported`
- `ansi::italic`
- `ansi::line`
- `ansi::lineRelative`
- `ansi::magenta`
- `ansi::magentaIntense`
- `ansi::nextLine`
- `ansi::noBlink`
- `ansi::noBorder`
- `ansi::noInverse`
- `ansi::noOverline`
- `ansi::noStrike`
- `ansi::noUnderline`
- `ansi::normal`
- `ansi::overline`
- `ansi::plain`
- `ansi::position`
- `ansi::previousLine`
- `ansi::rapidBlink`
- `ansi::red`
- `ansi::redIntense`
- `ansi::repeat`
- `ansi::report`
- `ansi::reportIcon`
- `ansi::reportPosition`
- `ansi::reportScreenChars`
- `ansi::reportTitle`
- `ansi::reportWindowChars`
- `ansi::reportWindowPixels`
- `ansi::reportWindowPosition`
- `ansi::reportWindowState`
- `ansi::reset`
- `ansi::resetAttributes`
- `ansi::resetBackground`
- `ansi::resetColor`
- `ansi::resetFont`
- `ansi::resetForeground`
- `ansi::resetIdeogram`
- `ansi::restoreCursor`
- `ansi::rgb`
- `ansi::saveCursor`
- `ansi::scrollDown`
- `ansi::scrollUp`
- `ansi::showCursor`
- `ansi::showHelp`
- `ansi::strike`
- `ansi::tabBackward`
- `ansi::tabForward`
- `ansi::title`
- `ansi::underline`
- `ansi::up`
- `ansi::visible`
- `ansi::white`
- `ansi::whiteIntense`
- `ansi::yellow`
- `ansi::yellowIntense`

</details>

### Module `args`

Functions to help with parsing and validation of command line arguments.

#### Functions

- `args::check_help_arg`
- `args::ensure_num_args`
- `args::ensure_num_args_between`
- `args::flag_value`
- `args::get_flag_value`

### Module `code`

Functions that relate to the code itself, where it is located, and how it is used.

#### Functions

- `code::is_sourced`
- `code::script_dir`

### Module `compat`

This is a compatibility layer for deprecated functions.  It is intended to be
used when refactoring code to use the new functions.  It will be removed in the
future.

#### Functions

<details>
<summary>Click to expand (38 functions)</summary>

- `ask`
- `can_user_write_to_dir`
- `check_help_arg`
- `deco_message`
- `die`
- `dotenv_delete`
- `dotenv_load`
- `dotenv_save`
- `echo_step`
- `ensure_debian`
- `ensure_dir_exists`
- `ensure_docker_host`
- `ensure_file_exists`
- `ensure_has_commands`
- `ensure_in_path`
- `ensure_in_remote_mount`
- `ensure_num_args`
- `ensure_pve`
- `ensure_root`
- `ensure_var_is_set`
- `fail`
- `flag_value`
- `get_arch`
- `get_os`
- `has_command`
- `info`
- `is_in_remote_mount`
- `is_linux`
- `is_lxc`
- `is_macos`
- `is_owned_by_user`
- `load_env`
- `noop`
- `ok`
- `print_aligned`
- `replace_between_markers`
- `run_as`
- `script_dir`

</details>

### Module `env`

Functions used to manage environment variables.

#### Functions

- `env::dotenv_delete`
- `env::dotenv_load`
- `env::dotenv_save`
- `env::ensure_is_set`

### Module `fs`

Functions related to the filesystem. Existance, permissions, etc.

#### Functions

- `fs::can_user_write_to_dir`
- `fs::ensure_dir_exists`
- `fs::ensure_file_exists`
- `fs::ensure_in_remote_mount`
- `fs::is_in_remote_mount`
- `fs::is_owned_by_user`

### Module `func`

Functions related to functions and function management.

#### Functions

- `func::ensure`
- `func::list_functions_in_file`

### Module `pve`

Functions related to Proxmox Virtual Environment (PVE).

#### Functions

- `pve::ensure_lxc`
- `pve::ensure_pve`
- `pve::is_lxc`
- `pve::is_pve`

### Module `sys`

Functions related to the system, its attributes and capabilities.

#### Functions

- `sys::ensure_debian`
- `sys::ensure_docker_host`
- `sys::ensure_has_commands`
- `sys::ensure_in_path`
- `sys::ensure_linux`
- `sys::ensure_macos`
- `sys::get_arch`
- `sys::get_os`
- `sys::has_command`
- `sys::is_debian`
- `sys::is_docker_host`
- `sys::is_in_path`
- `sys::is_linux`
- `sys::is_macos`
- `sys::run_as`

### Module `text`

Functions that relate to text manipulation.

#### Functions

- `text::apply_in_place`
- `text::comment_out_inside_markers`
- `text::delete_around_markers`
- `text::delete_inside_markers`
- `text::filter_inside_markers`
- `text::format_inside_markers`
- `text::print_aligned`
- `text::read_inside_markers`
- `text::replace_between_markers_legacy`
- `text::replace_inside_markers`

### Module `ui`

Functions to interact with the user.

#### Functions

- `ui::ask`
- `ui::deco_message`
- `ui::deprecate`
- `ui::die`
- `ui::echo_step`
- `ui::fail`
- `ui::info`
- `ui::noop`
- `ui::ok`
- `ui::reassurance_required`
- `ui::reassure`

### Module `user`

Functions related to users and groups.

#### Functions

- `user::add_to_groups`
- `user::create`
- `user::ensure_exists`
- `user::ensure_group_exists`
- `user::ensure_in_group`
- `user::ensure_root`
- `user::exists`
- `user::group_exists`
- `user::is_in_group`
- `user::is_root`
<!-- MODULES:END -->
