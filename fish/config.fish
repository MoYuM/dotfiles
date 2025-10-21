if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"

set -gx XDG_CONFIG_HOME $HOME/.config

fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/bin
