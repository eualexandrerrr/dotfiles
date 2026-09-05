# zsh: plugins dos repos oficiais + starship. Sem oh-my-zsh.

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY AUTO_CD

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]]   && source /usr/share/fzf/completion.zsh

export BROWSER="google-chrome-stable"
export TERMINAL="ghostty"
export EDITOR="nano"

# Aliases
alias poweroff="sudo poweroff"
alias reboot="sudo reboot"
alias pacman="sudo pacman"
alias pacman-key="sudo pacman-key"
alias mkinitcpio="sudo mkinitcpio"
alias systemctl="sudo systemctl"
alias rsync="sudo rsync"
alias dd="sudo dd"

# Deploy do servidor Michigan Roleplay. `noglob` deixa passar os alvos do script
# sem aspas: deploy [peds], deploy alx_*, deploy ALL configs --ler
[[ -f "$HOME/Downloads/MichiganRoleplay/DeployFiles/deploy.mjs" ]] && \
    alias deploy="noglob node $HOME/Downloads/MichiganRoleplay/DeployFiles/deploy.mjs"

command -v eza     >/dev/null 2>&1 && alias ls="eza --icons --group-directories-first"
command -v bat     >/dev/null 2>&1 && alias cat="bat --plain"
# x: Claude Code sem parar pra pedir permissao a cada ferramenta, sempre no Fable.
# "fable" e apelido pro Fable mais novo; pra fixar na versao exata seria claude-fable-5-1.
command -v claude  >/dev/null 2>&1 && alias x="claude --dangerously-skip-permissions --model fable"
command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Credenciais e variáveis privadas ficam no dotfiles-private
[[ -f "$HOME/.dotfiles-private/env.sh" ]] && source "$HOME/.dotfiles-private/env.sh"
