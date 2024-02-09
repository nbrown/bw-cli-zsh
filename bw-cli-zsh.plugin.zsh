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
    # Temp workaround to disable punycode deprecation logging to stderr
    # https://github.com/bitwarden/clients/issues/6689
    alias bw='NODE_OPTIONS="--no-deprecation" bw'

    local bw_comp_script="${0:h}/completions/_bw"
    if [[ ! -f "$bw_comp_script" ]]; then
        if [[ ! -d "${bw_comp_script:h}" ]]; then
            mkdir -p "${bw_comp_script:h}"
        fi
        bw completion --shell zsh >> "$bw_comp_script"
    fi
    fpath+=( ${bw_comp_script:h} )
    unset bw_comp_script


    if command -v jq > /dev/null; then
        function bw-unlock() {
            local bw_status="$(print $(bw status | jq '.status'))"
            if [[ "${(Q)bw_status}" == 'locked' ]]; then
                print "Bitwarden is locked"
                 if BW_SESSION=$(bw unlock --raw); then
                     export BW_SESSION="$BW_SESSION"
                 else
                     return 1
                 fi
            else
                print "Bitwarden is unlocked"
            fi
            unset bw_status
        }

        function fzf-bw-items() {
            bw-unlock

            bwitems=$(bw list items | jq -c '.[] | .["name"] + "," + .["id"] | split(",")' )
            typeset -A bwitems_arr=(${(f)bwitems})

            echo $bwitems | sed 's/[][]//g' |
                fzf --preview-window=:nohidden \
                --preview 'echo {} | sed "s/^.*,//" | xargs bw get item|jq' \
                -d ',' --with-nth 1 | \
                sed 's/^.*,//'

        }
    fi

fi

autoload -Uz template-script

# Use alternate vim marks [[[ and ]]] as the original ones can
# confuse nested substitutions, e.g.: ${${${VAR}}}

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
