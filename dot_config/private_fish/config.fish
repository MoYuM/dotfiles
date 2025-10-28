if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

alias lg "lazygit"

set -gx XDG_CONFIG_HOME $HOME/.config

fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/bin
