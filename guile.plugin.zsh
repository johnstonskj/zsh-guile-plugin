# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name guile
# @brief Configures environment variables for Guile Scheme programming language.
# @repository https://github.com/johnstonskj/zsh-guile-plugin
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

guile_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save guile GUILE_VERSION
    local GUILE_VERSION=$(guile --version | head -n1 | cut -d " " -f 4 | cut -d "." -f 1-2)

    @zplugins_envvar_save guile GUILE_PREFIX
    local GUILE_PREFIX=$(dirname $(dirname $(readlink -f $(command -v guile))))
    
    @zplugins_envvar_save guile GUILE_LOAD_PATH
    export GUILE_LOAD_PATH="${GUILE_PREFIX}/share/guile/site/${GUILE_VERSION}"

    @zplugins_envvar_save guile GUILE_LOAD_COMPILED_PATH
    export GUILE_LOAD_COMPILED_PATH="${GUILE_PREFIX}/lib/guile/${GUILE_VERSION}/site-ccache"

    @zplugins_envvar_save guile GUILE_SYSTEM_EXTENSIONS_PATH
    export GUILE_SYSTEM_EXTENSIONS_PATH="${GUILE_PREFIX}/lib/guile/${GUILE_VERSION}/extensions"    
}

guile_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore guile GUILE_VERSION
    @zplugins_envvar_restore guile GUILE_PREFIX
    @zplugins_envvar_restore guile GUILE_LOAD_PATH
    @zplugins_envvar_restore guile GUILE_LOAD_COMPILED_PATH
    @zplugins_envvar_restore guile GUILE_SYSTEM_EXTENSIONS_PATH
}
