#!/bin/bash

_tmux_ide_autocomplete() {
    # Base project directory
    local project_dir="$HOME/Projects"

    # Get current word to complete
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # List directories in the project base directory
    # Use `find` to make sure we're only listing directories
    local projects=$(find "$project_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

    # Provide suggestions that match the current input
    COMPREPLY=( $(compgen -W "$projects" -- "$cur") )
}

# Register the autocomplete function for your script (tmux-ide.sh or dev)
complete -F _tmux_ide_autocomplete dev
