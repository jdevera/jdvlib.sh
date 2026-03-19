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

## Configuration

These variables affect the behaviour:

* `JDVLIB_DEBUG`: Set to `true` to enable debug output. There is not a lot of this, though.
    * Deprecation messages will include file and line of the caller.
* `JDVLIB_LOG_DEPRECATIONS`: Set to *something* to log deprecation messages to `~/.jdvlib-deprecations.log`.


## Modules

<!-- MODULES:START -->
### Module `_meta`

Functions that support the library.
This module is the basis for imports, so there should never be an import of this file.

#### Functions

- `meta::for_each_library_module`
- `meta::import`
- `meta::lib_is_compiled`
- `meta::library_path`
- `meta::module_is_running`

### Module `ansi`

ANSI escape code utilities for text styling, cursor control, display
manipulation, and terminal operations. Organized into four functions:
ansi::style, ansi::cursor, ansi::display, and ansi::term.

#### Functions

- `ansi::cursor`
- `ansi::display`
- `ansi::isSupported`
- `ansi::style`
- `ansi::term`

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

- `func::call_first_matching`
- `func::call_first_of`
- `func::ensure`
- `func::exists`
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
- `sys::ensure_docker_running`
- `sys::ensure_has_commands`
- `sys::ensure_in_path`
- `sys::ensure_linux`
- `sys::ensure_macos`
- `sys::get_arch`
- `sys::get_os`
- `sys::has_command`
- `sys::is_debian`
- `sys::is_docker_host`
- `sys::is_docker_running`
- `sys::is_in_path`
- `sys::is_linux`
- `sys::is_macos`
- `sys::macos_code_name`
- `sys::macos_version`
- `sys::run_as`
- `sys::run_first_of`

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
