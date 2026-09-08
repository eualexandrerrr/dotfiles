# zsh: plugins dos repos oficiais + starship. Sem oh-my-zsh.

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY AUTO_CD

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/compcache"

# Tab progressivo: tenta exato, depois ignorando maiuscula, depois o pedaco digitado como
# prefixo de qualquer trecho separado por . _ -, e por fim como substring em qualquer
# posicao. So passa pro proximo quando o anterior nao acha nada, entao o match exato
# continua ganhando quando existe.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Arquivos ocultos entram no Tab sem precisar digitar o ponto: "dot<Tab>" acha .dotfiles.
# So na completion -- setopt globdots seria global e faria "rm *" pegar oculto tambem.
_comp_options+=(globdots)

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
[[ -f "$HOME/MichiganRoleplay/DeployFiles/deploy.mjs" ]] && \
    alias deploy="noglob node $HOME/MichiganRoleplay/DeployFiles/deploy.mjs"

command -v eza     >/dev/null 2>&1 && alias ls="eza --icons --group-directories-first"
command -v eza     >/dev/null 2>&1 && alias ll="eza -lah --icons --group-directories-first --git"
command -v eza     >/dev/null 2>&1 && alias lt="eza --tree --level=2 --icons"
command -v bat     >/dev/null 2>&1 && alias cat="bat --plain"
command -v lazygit >/dev/null 2>&1 && alias lg="lazygit"
command -v dust    >/dev/null 2>&1 && alias du="dust"
command -v duf     >/dev/null 2>&1 && alias df="duf"
command -v procs   >/dev/null 2>&1 && alias ps="procs"

# yazi que devolve o diretorio onde voce parou, em vez de voltar pro de origem
if command -v yazi >/dev/null 2>&1; then
    y() {
        local tmp cwd
        tmp="$(mktemp -t yazi-cwd.XXXXXX)"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp" 2>/dev/null)" && [[ -n $cwd && $cwd != "$PWD" ]]; then
            builtin cd -- "$cwd" || return
        fi
        rm -f -- "$tmp"
    }
fi
# x: Claude Code sem parar pra pedir permissao a cada ferramenta. Sem --model de
# proposito: assim obedece o "model" do ~/.claude/settings.json (hoje opus[1m],
# Opus 5 com 1M de contexto) e o que for escolhido no /model.
command -v claude  >/dev/null 2>&1 && alias x="claude --dangerously-skip-permissions"
command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v mise    >/dev/null 2>&1 && eval "$(mise activate zsh)"
# Depois do fzf de proposito: o atuin fica com o Ctrl+R, o fzf com o Ctrl+T.
command -v atuin   >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Credenciais e variáveis privadas ficam no dotfiles-private
[[ -f "$HOME/.dotfiles-private/env.sh" ]] && source "$HOME/.dotfiles-private/env.sh"

# Terminal aberto por uma sessão do Claude Code herda CLAUDE_CODE_CHILD_SESSION=1,
# e um `claude` iniciado aqui vira "sessão filha": não grava transcript e some do
# /resume. Num shell interativo essa marca é sempre falsa — limpar.
[[ -o interactive && -n "$CLAUDE_CODE_CHILD_SESSION" ]] && unset CLAUDE_CODE_CHILD_SESSION

# Ctrl+Backspace: o ghostty manda Alt+Backspace (\e\x7f). O keymap emacs ja resolve,
# mas o atuin e o fzf reescrevem bindings, entao amarrar depois deles garante.
bindkey '^[^?' backward-kill-word
bindkey '^H'   backward-kill-word

# Seta pra cima filtra o historico pelo que ja esta escrito: "cd" + seta so passeia pelos
# cd anteriores. Com o cursor no meio de um comando de varias linhas, anda entre as linhas.
# O atuin sobe com --disable-up-arrow justamente pra deixar a seta livre pra isso; o Ctrl+R
# continua sendo dele.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# No menu do Tab com varios candidatos, as setas navegam a lista.
zmodload zsh/complist
bindkey -M menuselect '^[[A' up-line-or-history
bindkey -M menuselect '^[[B' down-line-or-history
bindkey -M menuselect '^[[C' forward-char
bindkey -M menuselect '^[[D' backward-char
