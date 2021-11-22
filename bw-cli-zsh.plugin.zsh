# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2021 Nate Brown

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0=${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}
0=${${(M)0:#/*}:-$PWD/$0}

# Then ${0:h} to get plugin's directory

if [[ ${zsh_loaded_plugins[-1]} != */bw-cli-zsh && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}

# Standard hash for plugins, to not pollute the namespace
typeset -gA Plugins
Plugins[BW_CLI_ZSH_DIR]="${0:h}"

if command -v bw > /dev/null; then
    local bw_comp_script="${0:h}/completions/_bw"
    if [[ ! -f "$bw_comp_script" ]]; then
        if [[ ! -d "${bw_comp_script:h}" ]]; then
            mkdir -p "${bw_comp_script:h}"
        fi
        bw completion --shell zsh >> "$bw_comp_script"
    fi
    fpath+=( ${bw_comp_script:h} )
    unset bw_comp_script
fi

autoload -Uz template-script

# Use alternate vim marks [[[ and ]]] as the original ones can
# confuse nested substitutions, e.g.: ${${${VAR}}}

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
