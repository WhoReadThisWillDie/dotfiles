# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/msadkoff/.docker/completions $fpath)
# End of Docker CLI completions

BREW_PATH="$(brew --prefix)"
# Syntax highlighting
source "$BREW_PATH/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
# Autosuggestions
source "$BREW_PATH/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# Autocomplete
source "$BREW_PATH/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
# fzf **
source "$BREW_PATH/opt/fzf/shell/completion.zsh"

export HOMEBREW_NO_AUTO_UPDATE=1

# Tab completion
autoload -Uz compinit && compinit

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=2000
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# Edit in nvim
export VISUAL='nvim'
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^o' edit-command-line

# Prompt
eval "$(starship init zsh)"

autoload -Uz add-zsh-hook

set_terminal_title() {
  print -rn -- $'\e]2;'"${PWD:t}"$'\a'
}

add-zsh-hook precmd set_terminal_title

# fzf keybindings and fuzzy completion
eval "$(fzf --zsh)"
# Fancier cd
eval "$(zoxide init --cmd cd zsh)"
# Node version manager
eval "$(fnm env --use-on-cd --shell zsh)"

export HF_HUB_DISABLE_TELEMETRY=1 

export XDG_CONFIG_HOME=~/.config
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export EZA_CONFIG_DIR=~/.config/eza
export BAT_THEME="Catppuccin Mocha"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Aliases
alias cat=bat
alias ls='eza --icons=auto'
alias find=fd
alias v=nvim
alias gs='git status'
alias gb='git branch'
alias gch='git checkout'
alias gf='git fetch --prune'
alias gl='git pull'
alias gst='git stash'
alias gstp='git stash pop'
alias ga='git add -A'
alias gc='git commit'
alias gp='git push'
alias gpsu='git push origin --set-upstream'
alias dcl='docker container list'
alias dcsr='docker container start'
alias dcsp='docker container stop'
alias nr='npm run'
alias nrd='npm run dev'
alias tch='npx tsc --noEmit'
alias ag='agy'
