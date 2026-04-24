if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

alias lg "lazygit"
alias ca "cursor-agent"
alias cc "claude --dangerously-skip-permissions"
alias cz "chezmoi"

set -gx XDG_CONFIG_HOME $HOME/.config

fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/bin

# pnpm
set -gx PNPM_HOME "/Users/moyum/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

export EDITOR="nvim"

