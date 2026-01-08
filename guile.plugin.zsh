# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: guile
# Description: Configures environment variables for Guile Scheme programming language.
# Repository: https://github.com/johnstonskj/zsh-guile-plugin
#
# Public variables:
#
# * `GUILE`; plugin-defined global associative array with the following keys:
#   * `_ALIASES`; a list of all aliases defined by the plugin.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
# * `GUILE_LOAD_PATH`; the load path for guile.
# * `GUILE_LOAD_COMPILED_PATH`; the compiled load path for guile.
# * `GUILE_SYSTEM_EXTENSIONS_PATH`; the system extensions path for guile.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA GUILE
GUILE[_PLUGIN_DIR]="${0:h}"
GUILE[_ALIASES]=""
GUILE[_FUNCTIONS]=""

# Save current state for any global environment variables that may be modified
# by the plugin here.

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `GUILE[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.guile_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${GUILE[_FUNCTIONS]}" ]]; then
        GUILE[_FUNCTIONS]="${fn_name}"
    elif [[ ",${GUILE[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        GUILE[_FUNCTIONS]="${GUILE[_FUNCTIONS]},${fn_name}"
    fi
}
.guile_remember_fn .guile_remember_fn

.guile_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${GUILE[_ALIASES]}" ]]; then
        GUILE[_ALIASES]="${alias_name}"
    elif [[ ",${GUILE[_ALIASES]}," != *",${alias_name},"* ]]; then
        GUILE[_ALIASES]="${GUILE[_ALIASES]},${alias_name}"
    fi
}
.guile_remember_fn .guile_remember_alias

#
# This function does the initialization of variables in the global variable
# `GUILE`. It also adds to `path` and `fpath` as necessary.
#
guile_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    local GUILE_VERSION=$(guile --version | head -n1 | cut -d " " -f 4 | cut -d "." -f 1-2)
    local GUILE_PREFIX=$(dirname $(dirname $(readlink -f $(command -v guile))))
    
    export GUILE_LOAD_PATH="${GUILE_PREFIX}/share/guile/site/${GUILE_VERSION}"
    export GUILE_LOAD_COMPILED_PATH="${GUILE_PREFIX}/lib/guile/${GUILE_VERSION}/site-ccache"
    export GUILE_SYSTEM_EXTENSIONS_PATH="${GUILE_PREFIX}/lib/guile/${GUILE_VERSION}/extensions"    
}
.guile_remember_fn guile_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
guile_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${GUILE[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
    
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${GUILE[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done

    # Reset global environment variables .
    unset GUILE_LOAD_PATH
    unset GUILE_LOAD_COMPILED_PATH
    unset GUILE_SYSTEM_EXTENSIONS_PATH
    
    # Remove the global data variable.
    unset GUILE

    # Remove this function.
    unfunction guile_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

guile_plugin_init

true
